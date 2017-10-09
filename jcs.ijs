NB. J client server - built on zmq

jcst__=:   jcst_jcs_
jcsc__=:   jcsc_jcs_
jcss__=:   jcss_jcs_
jcs__=:    jcs_jcs_

NB.! debug task start problems
(LF,~(18":6!:9''),'  ',(10{.'jcs-load'),'  ',8":2!:6'') fappend '~temp/zmq/',(":2!:6''),'.log'
(LF,~(18":6!:9''),'  ',(10{.'jcs-uname'),'  ',(8":2!:6''),'  ',UNAME) fappend '~temp/zmq/',(":2!:6''),'.log'


require'~addons/net/zmq/zmq.ijs'

(LF,~(18":6!:9''),'  ',(10{.'zmq-loaded'),'  ',8":2!:6'') fappend '~temp/zmq/',(":2!:6''),'.log'

coclass'jcs'
coinsert'jzmq'

PORTS=: 65100+i.200 NB. jcs port range

help=: 0 : 0
c=: jcst 65201         - create server task / client locale for localhost:65201
    run__c'i.2 3'      - run sentence on server
    runa__c'6!:3[9'    - run - no wait
    runz__c''          - get runa result
    runsu__c s         - run as superuser - su in client/server locales must match
    run__c'notdef'     - ". differs from imex - 0$0 instead of value error
    kill__c''          - kill server task and destroy client local

c=: jcst '*:65201'     - create server task / client locale - bind any
c=: jcss 65201         - create server locale - bind localhost
c=: jcss '*:65201'     - create server locale - bind any
c=: jscc 65201         - create client locale

    destroy__c''       - destroy client or server locale
    jcs''              - jcs locale report
    lse__c             - last server error
    lzmqc_jcs_         - last zmq command
    lzmqe_jcs_         - last zmq error string on zmq error
c=: loc_jcs_ 65201     - locale from port
    servers_jcs_''     - server ports+pids for jcs port range
    servers_jcs_ p...  - server ports+pids for port(s)
    killp_jcs_ p...    - kill server for port(s) p and destroy locale
    killall_jcs_''     - kill all servers, destroy all client/server locales, and do ctx_term

    poll_jcs_ timeout;'';<tasks - timeout milliseconds ; 0 immediate ; _1 forever
    poll_jcs_ 0;'';<{."1 jcs''  - '' could be extended to ZMQ_POLLIN, etc flags

jcs port range: 65100+i.200
jd  port range: 65100+i.100
~jd port range: 65200+i.100

65201 '65201' 'localhost:65201' '192.168.0.23:65201' '*:65201'
)

jcst=: 3 : 0
'server'vaddress y
jc=. jpath'~bin/',('/usr/share/j/'-:13{.jpath'~install'){::'jconsole';'ijconsole'
d=. ('"','"',~hostpathsep jc),' ~addons/net/jcs/jcs.ijs  -js "serverinit_jcs_ ''',(":y),'''"'
if. IFWIN do. winserver d else. fork_jtask_ d,' > /dev/null 2>&1' end.
jcsc y-.'*'
)

jcsc=: 3 : 0
c=. 'jcs'conew~'client'vaddress y
)

jcss=: 3 : 0
'jcs'conew~'server'vaddress y
)

jcs=: 3 : 0
t=. ;:'PORT IP S TYPE'
r=. (0,#t)$''
for_i. conl 1 do.
 if. (<'jcs')e.copath i do.
  r=. r,d=.  i,(<PORT__i),(<IP__i),(<TYPE__i)
 end.
end.
(/:1{"1 r){r
)

NB. ZMQ_LINGER - free port at task end
create=: 3 : 0
'TYPE IP PORT'=: y
address=. IP,':',":PORT
S=: 0
su=: ''
ctx_new''
if. TYPE-:'server' do.
 S=: socket ZMQ_REP
 setsockopt S;ZMQ_LINGER;0
 try.
   bind S;'tcp://',address
 catch.
  e=. 'bind ',address,' failed (',lzmqe,')'
  destroy''
  e assert 0
 end.
else.
 access=: ''
 S=: socket ZMQ_REQ
 setsockopt S;ZMQ_LINGER;0
 connect S;'tcp://',address
end.
)

destroy=: 3 : 0
if. 0=nc<'S' do.
 if. S~:0 do. close S end.
end.
codestroy''
)

vaddress=: 4 : 0
address=. deb ":y
'blanks not allowed in address'assert 0=+/' '=address
if. -.':'e.address do. address=. 'localhost:',address end.
address=. address rplc 'localhost';localhost
'bad address'assert 1=+/address=':'
'ip port'=. <;._2 address,':'
ip=. ;(ip-:''){ip;localhost
'bad port' assert 0<#port
port=. 0".port
'bad port' assert (0<port)*.65536>port
'port already in use in this task' assert -.port e.>1{"1 jcs''

if. -.(ip-:,'*')*.x-:'server' do.
 n=. ;_".each<;._2 ip,'.'
 'bad ip'assert (4=#n)*.(0<:<./n)*.255>:>./n
end.

x;ip;port
)

runserver=: 3 : 0
'jcs-run'zmqlogx''
while. 1 do.
 'f1 f2'=. recvmsg'' NB. issues with break
 try.
  r=. rpc 3!:2 f2
  sendmsg 3!:1 r
 catchd.
  'error'sendmsg 13!:12''
 end. 
end.
)

sendmsg=: 3 : 0
'' sendmsg y
:
d=. deb(":#y),' ',x
send S;d;(#d);ZMQ_SNDMORE NB. count options - 1st frame
send S;y;(#y);0           NB. data          - 2nd frame
)

recvmsg=: 3 : 0
f1=. recv S;(1000$' ');1000;0 NB. count options - first frame
i=. f1 i. ' '
cnt=. 0".i{.f1
f1=. (>:i)}.f1
'bad recvmsg getsockopt'assert 1=r=. getsockopt S;13
f2=. recv S;(cnt$' ');cnt;0   NB. data          - 2nd frame
'bad recvmsg getsockopt'assert 0=r=. getsockopt S;13
f1;f2
)

run=: 3 : 0
runa y
runz''
)

runsu=: 3 : 0
t=. access
access=: su
runa y
r=. runz''
access=: t
r
)

runa=: 3 : 0
sendmsg 3!:1 (<access),<y
i.0 0
)

runz=: 3 : 0
'f1 f2'=. recvmsg''
if. 'error'-:f1 do.
 lse=: f2
 'server error' assert 0
end.
r=. 3!:2 f2 NB. empty boolean for value errr or for abc=:def
r
)

poll=: 3 : 0
poll_jzmq_ y
)

NB. kill server and destroy locale
kill=: 3 : 0
access=: su
runa'exit 0'
destroy''
i.0 0
)

rpcjd=: 3 : 0
'access d'=: y
if. su-:access do.
 do__ d
else.
 jdaccess__' intask',~access
 jd__ d
end.
)

rpcdo=: 3 : 'do__ >{:y'

killall=: 3 : 0
killp servers'' NB. kill all jcs server tasks
t=. {."1 jcs''
for_n. t do. destroy__n'' end.
'orphaned sockets'assert 0=#sockets_jzmq_
ctx_term''
i.0 0
)

killp=: 3 : 0 "0
'do not kill yourself!'assert y~:2!:6''
d=. servers y
i=. y i.~{."1 d
if. i<#d do.
 pid=. ":{:i{d
 if. IFWIN do.
  shell'taskkill /F /PID ',pid
 else.
  2!:0 'kill ',pid
 end.
 try.
  c=. loc y
  destroy__c''
 catch.
 end.
end.
i.0 0
)

loc=: 3 : 0
t=. jcs''
i=. y i.~>1{"1 t
'port not in jcs'assert i<#t
<":;{.i{t
)

servers=: 3 : 0
p=. ;(y-:''){y;PORTS
select. UNAME
case. 'Linux' do.
 t=. jpath'~temp/fuser.txt'
 try.
  d=. 2!:1'fuser -n tcp ',(":p),' > "',t,'" 2>&1'
 catch.
  0 2$0
  return.
 end.
 d=. fread t
 d=. d-. '/tcp:'
 d=. d rplc LF,' '
 d=. 0".d
 d=. (2,~2%~#d)$d
case. 'Darwin' do.
 d=. <;._2 [ 2!:0 'netstat -anv'
 b=. ;(<'tcp')-:each 3{.each d
 d=. deb each b#d
 d=. ><;._2 each d,each' '
 d=. ( (<'LISTEN')=5{"1 d )#d
 a=. 3{"1 d
 a=. ;0".each(>:;a i: each'.')}.each a
 d=. a,.;0".each 8{"1 d
 d=. (({."1 d) e. p)#d
case. 'Win' do.
 d=.  CR-.~each deb each <;._2 shell'netstat -ano -p tcp'
 b=. ;(<'TCP')-:each 3{.each d
 d=. b#d
 d=. ><;._2 each d,each' '
 d=. ( (<'LISTENING')=3{"1 d )#d
 a=. 1{"1 d
 a=. ;0".each(>:;a i: each':')}.each a
 d=. a,.;0".each 4{"1 d
 d=. (({."1 d) e. p)#d
end.
 d/:{."1 d
)

NB. windows createprocess - borrowed from jum
NB. fork leaves stdin/stdout hooked up and does not work
NB. the following should be refactored into jtasks
NB. /S strips leading " and last " and leaves others alone
winserver=: 3 : 0
CloseHandle=. 'kernel32 CloseHandle i x'&cd"0
CreateProcess=. 'kernel32 CreateProcessW i x *w x x i  i x x *c *c'&cd
f=. 16b08000000
c=. uucp 'cmd /S /C "',y,'"'
si=. (68{a.),67${.a.
pi=. 16${.a.
'r i1 c i2 i3 i4 f i5 i6 si pi'=. CreateProcess 0;c;0;0;0;f;0;0;si;pi
'createprocess failed'assert 0~:r
CloseHandle _2 ic 4{.pi
)

NB. y is port to serve - run by fork -js to start
serverinit=: 3 : 0
'jcs-init'zmqlogx y
if. -.IFWIN do. (' setsid x',~unxlib'c')cd'' end. NB. so we don't get parents ctrl+c
SERVER__=: s=. jcss y
rpc__s=: rpcdo
runserver__s''
)

NB. debugging stuff
logfile=: '~temp/jcs.log'

log=: 3 : 0
(y,LF) fappend logfile
)

