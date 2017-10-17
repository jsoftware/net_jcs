NB. J client server - built on zmq

jcst__=:   jcst_jcs_
jcsc__=:   jcsc_jcs_
jcss__=:   jcss_jcs_
jcs__=:    jcs_jcs_

require'~addons/net/zmq/zmq.ijs'

coclass'jcs'
coinsert'jzmq'

PORTS=: 65100+i.200 NB. jcs port range

help=: 0 : 0
c=: jcst 65201         - create server task / client locale for localhost:65201
    run__c'i.2 3'      - run sentence on server
    runa__c'6!:3[9'    - run - no wait
    runz__c 0          - get runa result - no timeout
    runz__c 2000       - 2 second timeout
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
    killp_jcs_ p...    - kill server/client for port(s) p
    killp_jcs_ ''      - kill all ports
    killall_jcs_''     - kill all ports and do ctx_term

    poll_jcs_ timeout;'';<tasks - timeout milliseconds ; 0 immediate ; _1 forever
    poll_jcs_ 0;'';<{."1 jcs''  - '' could be extended to ZMQ_POLLIN, etc flags

jcs port range: 65100+i.200
jd  port range: 65100+i.100
~jd port range: 65200+i.100

65201 '65201' 'localhost:65201' '192.168.0.23:65201' '*:65201'
)

doin=: 4 : '(<x)(4 : ''do__y x'')each<"0 y' NB. run sentence in each locale

starttask=: 3 : 0 
'server'vaddress y
jc=. jpath'~bin/',('/usr/share/j/'-:13{.jpath'~install'){::'jconsole';'ijconsole'
d=. ('"','"',~hostpathsep jc),' ~addons/net/jcs/start.ijs  -js "start_jcs_ ''',(":y),'''"'
if. IFWIN do. winserver d else. fork_jtask_ d,' > /dev/null 2>&1' end.
jcsc y-.'*'
)

NB. log jcst failures
logjcst=: 4 : 0
t=. (12{.x),' ',":y
echo t
1!:5 :: [ <jpath'~temp/zmq'
(LF,~(isotimestamp 6!:0''),'  ',t) fappend '~temp/zmq/jcst.log'
)

NB. start 1 or more server tasks
NB. jcst 65201 -  jcst 65201 65202 - jcst '*:65202' - jcts 65201;'*:65202'
jcst=: 3 : 0
r=. (<'server')vaddress each y NB. validate arg
p=. >{:"1 >r
'duplicate port'assert (#p)-:#~.p
c=. >starttask each y
return.
validatetasks c
)

NB. possible bug (windows?) - start server task can fail
NB. validate new tasks - timeout getpid and jcs/jzmq names defined
validatetasks=: 3 : 0
c=.y
bad=. 0
a=. nl_jcs_''
b=. nl_jzmq_''
for_n. c do.
 try.
  runa__n'2!:6'''''
  PID__n=: runz__n 2000
  d=. a-.(run__n'nl_jcs_''''')-.<'start'
  if. #d do. 
   'jcs-missing'logjcst (;n),' ',(":PORT__n,PID__n),' ',;d,each' '
   bad=. >:bad
  end. 
  fd=. b-.run__n'nl_jzmq_'''''
  if. #d do.
   'jzmq-missing'logjcst (;n),' ',(":PORT__n,PID__n),' ',;d,each' '
   bad=. >:bad
  end. 
 catch.
  'timeout'logjcst (;n),' ',":PORT__n
  bad=. >:bad
 end.
end.
'task(s) did not start properly (~temp/zmq/jcst.log)'assert bad=0
c
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
  r=. r,d=.  i,(<PORT__i),(<IP__i),(<TYPE__i),<PID__i
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
 PID=: 0
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
 PID=: 2!:6''
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
runz 0
)

runsu=: 3 : 0
t=. access
access=: su
runa y
r=. runz 0
access=: t
r
)

runa=: 3 : 0
sendmsg 3!:1 (<access),<y
i.0 0
)

NB. y is timeout millis - 0 for infinite
runz=: 3 : 0
if. 0~:y do.
 c=. coname''
 'rc reads writes errors'=. poll y;'';<c
 if. _1=rc do. ('poll error: ',strerror) assert 0 end.
 'timeout - did not get response'assert c e. reads
end.
'f1 f2'=. recvmsg''
if. 'error'-:f1 do.
 lse=: f2
 'server error' assert 0
end.
r=. 3!:2 f2 NB. empty boolean for value errr or for abc=:def
r
)

runzx=: 3 : 0
c=. coname''
'rc reads writes errors'=. poll y;'';<c
if. _1=rc do. ('poll error: ',strerror) assert 0 end.
'timeout - did not get response'assert c e. reads
runz''
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
killp''
'orphaned sockets'assert 0=#sockets_jzmq_
ctx_term''
i.0 0
)

NB. killp port(s)
killp=: 3 : 0
a=. y
if. a-:'' do.
 a=. >1{"1 jcs'' NB. all ports in jcs
end.
for_n. a do.
 try.
  c=. loc n
  destroy__c''
 catch.
 end.
end. 
s=. servers''
if.  ''-:y do. y=. {."1 s end.
p=. {."1 s
y=. y#~y e. p NB. remove ports not in use by servers
pids=. 1{"1 s#~p e. y
if. 0=#pids do. return. end.
if. IFWIN do.
 shell 'taskkill /f ', ;(<' /pid '),each":each<"0 pids
else.
 2!:0 'kill ',":pids
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

NB. windows createprocess
NB. fork_jtask_ leaves stdin/stdout hooked up
NB. following should be refactored into jtasks
NB. /S strips leading " and last " and leaves others alone
NB. win32 requires 104->68 ; 16->24 ; _2 ic 8{.pi -> _3 ic 16{.pi
winserver=: 3 : 0
'only valid on win64'assert IF64
CloseHandle=. 'kernel32 CloseHandle i x'&cd"0
CreateProcess=. 'kernel32 CreateProcessW i x *w x x i  i x x *c *c'&cd
f=. 16b08000000
c=. uucp 'cmd /S /C "',y,'"'
si=. (104{a.),104${.a.
pi=. 24${.a.
'r i1 c i2 i3 i4 f i5 i6 si pi'=. CreateProcess 0;c;0;0;0;f;0;0;si;pi
'createprocess failed'assert 0~:r
CloseHandle _3 ic 16{.pi
)

NB. y is port to serve - run by fork -js to start
serverinit=: 3 : 0
if. -.IFWIN do. (' setsid x',~unxlib'c')cd'' end. NB. so we don't get parents ctrl+c
SERVER__=: s=. jcss y
rpc__s=: rpcdo
runserver__s''
)

0 : 0
timing mystery
 loop to create task and get pid is SLOW (nearly 40 times slower)
 loop to create tasks and loop to get pids is FAST  

 do timings with testa, testb, and testc 

task start mystery
 occasionally a task does not start properly - the script loads are damaged and there is an error
)

test=: 3 : 0
killp_jcs_''
a=. timex'testa y'
killp_jcs_''
b=. timex'testb y'
killp_jcs_''
c=. timex'testb y'
'3 timings to do the same thing: ',":a,b,c
)


NB. SLOW - create task and get pid in loop
testa=: 3 : 0
cs=. ''
ps=. ''
for_i. i.y do.
 c=. jcst 65201+i
 p=. run__c '2!:6'''''
 cs=. cs,c
 ps=. ps,<p
end.
pids__=: ps
)

NB. FAST - create tasks in loop and the get pids in loop
testb=: 3 : 0
cs=. ''
ps=. ''
for_i. i.y do.
 c=. jcst 65201+i
 cs=. cs,c
end.
for_i. i.y do.
 c=. i{cs
 p=. run__c '2!:6'''''
 ps=. ps,<p
end.
pids__=: ps
)

NB. FAST - same as fast with less code - 2 loops
testc=: 3 : 0
c=. >jcst each 65201+i.y
'run''2!:6 '''''''' '' ' doin c
)
