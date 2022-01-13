NB. J client server - built on zmq

NB. to avoid name clutter,  only the most common names are put in base
jcst__=:   jcst_jcs_
jcsc__=:   jcsc_jcs_
jcss__=:   jcss_jcs_
jcs__=:    jcs_jcs_

require'~addons/net/zmq/zmq.ijs'

coclass'jcs'
coinsert'jzmq'

3 : 0 '' NB. one time init on load
if. _1=nc <'petasks' do. peports=: petasks=: '' end.
)

PORTBASE=:   65100
PORTS=:      PORTBASE+i.200 NB. jcs port range
Debug=:      0   NB. display jconsole messages

help=: 0 : 0
see help_warning_jcs_ for critical info on programming servers

see help_pe_jcs_ for help on parallel each

c=: jcst 65201         - create server task / client locale for localhost:65201
    run__c'i.2 3'      - run sentence on server
    run__c'2+jcs_p0+jcs_p1';4 5;i.2 3 - run sentence with data
    runa__c'6!:3[9'    - run - no wait
    runz__c 0          - get runa result - no timeout
    runz__c 2000       - 2 second timeout
    runsu__c s         - run as superuser - su in client/server locales must match
    run__c'notdef'     - ". differs from imex - 0$0 instead of value error
    kill__c''          - kill server task and destroy client local

c=: jcst '*:65201'     - create server task / client locale - bind any
c=: jcss 65201         - create server locale - bind localhost
c=: jcss '*:65201'     - create server locale - bind any
c=: jcsc 65201         - create client locale
c=: jcscraw 65220      - create server locale - serve normal sockets (ZMQ_STREAM)

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
    killpids_jcs_ ...  - kill pids

    poll_jcs_ time;'';<tasks - time - timeout milliseconds ; 0 immediate ; _1 forever
    poll_jcs_ 0;'';<{."1 jcs''  - '' tests each port for ready for read (2), write(4), or read+write(6)
    poll_jcs_ 0;1 2 3;<tasks - test first for read, second for write, and third for read+write
    
    
    jcstvalidate c     - validate jcst tasks started properly
    
    nct_jcs_''         - return cores,cores*threads

jcs port range: 65100+i.200

65201 '65201' 'localhost:65201' '192.168.0.23:65201' '*:65201'
)

help_pe=: 0 : 0
parallel each - also used for running job queue
tasks are initialized only once - init and script loads are overhead

   peinit_jcs_ ports NB. ports to init for pe
   pekill_jcs_''     NB. kill pe locales and tasks
   petasks_jcs_      NB. pe locales
   peports_jcs_      NB. pe ports
   peservers_jcs_    NB. locales,.ports,.pids (PID set in locale when started)
   peset_jcs_  s     NB. run sentence s in each pe task
   peload_jcs_ ijs   NB. load script ijs in each pe task
   pe_jcs_ s;<right  NB. s each right
   pe_jcs_ s;(<left),<right NB. left s each right
)

help_warning=: 0 : 0
WARNING:
 multiple J tasks introduce new programming concerns
 in particular, there are conflicts with tasks writing the same file
 as fwrite/fappend/... run without interlocks
 
 tasks appending log records to the same file will seem to work
 until there is a mishmash of complete and partial records
 
 a task writing, then reading could get data written by another task
 or, extra confusing, partial data as the read happened mid write

 a possible solution is to add pid (2!:6'') to file names

 a possible solution for ~temp is to add pid to the ~temp path 

 different tasks must either use different names for writing files
 or use a lock mechanism such as semaphore, mutex, or file lock
 
 Jsoftware tries to ensure there are no multiple task conflicts
 in the standard profile or initializing standard front ends
 
 you need to handle conflicts in startup.ijs and other scripts
 you may want startup.ijs to do nothing in a server (check ARGV)
)

doin=: 4 : '(<x)(4 : ''do__y x'')each<"0 y' NB. run sentence in each locale

starttask=: 3 : 0 
'server'vaddress y
jc=. jpath'~bin/',(1 e. '/share/j/' E. jpath'~install'){::'jconsole';'ijconsole'
d=. ('"','"',~hostpathsep jc),' ~addons/net/jcs/start.ijs  -js "start_jcs_ ''',(":y),'''"'
if. IFWIN do. winserver d else. fork_jtask_ d,(-.Debug)#' > /dev/null 2>&1' end.
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
)

NB. jcst failures are hard to debug - jcstvalidate might help
jcstvalidate=: 3 : 0
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

jcssraw=: 3 : 0
'jcs'conew~'serverraw'vaddress y
)

jcs=: 3 : 0
t=. ;:'PORT IP S TYPE'
r=. (0,#t)$''
for_i. conl 1 do.
 if. (<'jcs')={.copath i do.
  r=. r,d=.  i,(<PORT__i),(<IP__i),<TYPE__i
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
select. TYPE

case.'server';'serverraw' do.
 STYPE=: TYPE
 S=: socket (TYPE-:'serverraw'){ZMQ_REP,ZMQ_STREAM
 setsockopt S;ZMQ_LINGER;0
 jcsserverobject__ =: 0&". > coname''  NB. sentences are executed in base.  This gives a path to the jcs object
 try.
   bind S;'tcp://',address
 catch.
  e=. 'bind ',address,' failed (',lzmqe,')'
  destroy''
  e assert 0
 end.

case.'client' do. 
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

pipelined =: 0
NB. startpipe firstpiperesult
NB. Enters pipeline mode, in which each msg immediately returns the result of
NB. the previous msg, and then starts executing the current msg.
NB. The immediate result of startpipe is 'Pipeline started', and the result of the next msg
NB. is the y arg
NB. Executed as startpipe__jcsserverobject and thus runs in instance locale
startpipe =: 3 : 0
pipelined_jcs_ =: 1
piperesult_jcs_=:y
'Pipeline started'
)
NB. stoppipe ''
NB. Leaves pipeline mode, returning the result of the previous msg
NB. Executed as stoppipe__jcsserverobject and thus runs in instance locale
stoppipe =: 3 : 0
pipelined_jcs_ =: 0
''  NB. This will free the memory of the last piperesult
)

NB. Runs in instance locale on the server
runserver=: 3 : 0
while. 1 do.
 'f1 f2'=. recvmsg'' NB. issues with break
 try.
  if. pipelined_jcs_ do.
   sendmsg 3!:1 piperesult_jcs_
   piperesult_jcs_ =: rpc 3!:2 f2
  else.
   r=. rpc 3!:2 f2
   sendmsg 3!:1 r
  end.
 catchd.
  'error'sendmsg 13!:12''
 end. 
end.
)

NB. called when there is data available - just adds it to the stream
NB. data is trunctate to fit in the buffer!
recvmsgraw=: 3 : 0
r=. recv S;(256#' ');256;0
r=. 'zmq_recv i x *c x i'cdxnm S;(5000#' ');5000;0
c=. ;{.r
'raw data truncated'assert c<:5000
(>{.r){.;2{r
D=: D,c{.;2{r
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
sendmsg 3!:1 (<access),boxopen y
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

NB. su must be non-empty for superuser access
rpcjd=: 3 : 0
'access d'=: y
if. (0~:#su)*.su-:access do. 
 do__ d
else.
 jdaccess__' intask',~access
 jdx_jd_ d
end.
)

NB. similiar to jd code in local jd
jd=: 3 : 0
jdlasty_z_=: y
jdlast_z_=: run y
t=. ;{.{.jdlast
if. 'Jd error'-:t do.
 t=. _2}.;jdlast,each <': '
 13!:8&3 t
elseif. 'Jd report '-:10{.t do. ;{:jdlast 
elseif. 'Jd OK'-:t          do. i.0 0
elseif. 1                   do. jdlast
end.
)

jdae=: 4 : 0
try. 
 jd y
 'did not get expected error'assert 0
catchd.
 t['did not get expected error text'assert +./x E. t=. ;1{jdlast
end.
)

jdaccess=: 3 : 'i.0 0[access=: y'

NB. set jcs_pa__,jcs_ps__,jcs_p0__,... and do__ jcs_ps__
NB. access,sentence[,p0,p1,...]
NB. Runs in the object locale, but executes sentences in base
rpcdo=: 3 : 0
('jcs_pa__ jcs_ps__',;(<'__'),~each(<' jcs_p'),each ":each i._2+#y)=: y
select. nc__<jcs_ps__
case. 0;_2 do.  NB. noun is ok; malformed name is just a sentence
case. _1 do. ('value error: ',jcs_ps__)13!:8[21 return.  NB. undefined word, error
case. do. do__ '5!:5<jcs_ps__' return.  NB. non-noun: expunge it and exit
end.
NB. Erase any local names that were created, to avoid assignment conflicts in do__
do__ jcs_ps__
)

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
killpids pids
)

killpids=: 3 : 0
if. 0~:#y do.
 if. IFWIN do.
  shell 'taskkill /f ', ;(<' /pid '),each":each<"0 y
 else.
  2!:0 'kill ',":y
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
case. 'Linux';'OpenBSD' do.
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
 loop to create task and get pid is SLOW
 loop to create tasks and loop to get pids is FAST  

 do timings with testa, testb, and testc 

task start mystery
 occasionally a task script loads are damaged and there is an error
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


NB. parallel each
peinit=: 3 : 0
pekill''
peports=: y
petasks=: jcst y
for_n. petasks do. PID_jcs__n=: run__n '2!:6''''' end.
petasks_jcs_
)

NB. shutdown pe tasks
pekill=: 3 : 0
for_n. petasks do.
 try. runa__n 'exit 0' catch. killpids PID_jcs__n end.
 destroy__n''
end.
peports=: petasks=: ''
i.0 0
)

peservers=: 3 : 0
r=. ''
for_n. petasks do. r=. r,PID_jcs__n end.
petasks,.(<"0 peports),.<"0 r
)

peset=: 3 : 0
for_c. petasks do. run__c y end.
i.0 0
)

peload=: 3 : 0
peset 'load ''',y,''''
)

NB. pe sentence;<data
pe=: 3 : 0
dyad=. 3=#y
if. dyad do.
 's left right'=. y
 'not strict conformance'assert (#left)=#right
else.
 's right'=. y
end.
rs=. '' NB. job results
ns=. '' NB. job numbers
c=. 0
error=: 0
while. (#rs)<#right do. NB. need more results
  'rc reads writes errors'=. poll 5000;'';<petasks
  if.  0=rc do. echo'jpe jcs poll' end.
  for_n. writes do.
   if. c=#right do. break. end.
   jobnum__n=: c
   
   if. dyad do.
    runa__n ('jcs_p0',s,' jcs_p1');(c{left),c{right
   else.
    runa__n (s,' jcs_p0');c{right
   end.
   
   c=. >:c
  end.
  for_n. reads do.
   try.
     ns=. ns,jobnum__n
     rs=. rs,<runz__n 0
   catch.
     rs=. rs,<lse__n 
     error=: 1
   end.
  end.
end.
if. error do. echo 'errors in pe result' end.
rs/:ns
)

NB. parallel jobs
NB. following is an example that runs jobs in multiple tasks
NB. y is number of tasks to create to run jobs
pj=: 3 : 0
j=. jobs__
p=. PORTBASE+i.y
killp p
tasks=. jcst ((#j)<.#p){.p NB. don't create more tasks than jobs
rs=. '' NB. job results
ns=. '' NB. job numbers
i=. 0
error=.0
while. #tasks do.
  'rc reads writes errors'=. poll 5000;'';<tasks
  if.  0=rc do. qshow'poll 0:' end.
  for_n. writes do.
    if. i<#j do.
      jobnum__n=: i
      runa__n i{j
      i=. >:i
    else.
      tasks=. tasks-.n
      kill__n''
    end.
  end.
  for_n. reads do.
   try.
     ns=. ns,jobnum__n
     rs=. rs,<runz__n 0
   catch.
     rs=. rs,<lse__n
     error=. 1
   end.
  end.
end.
if. error do. echo 'errors in result' end.
rs/:ns
)

NB. return number of cores and cores*threads
nct=: 3 : 0
try.
select. UNAME
case.'Linux' do.
 t=. <;._2 [2!:0'cat /proc/cpuinfo'
 ({:1".;(1 i.~(<'cpu cores')=9{.each t){t),+/(<'processor')=9{.each t
case.'Darwin' do.
 1".(2!:0'sysctl -n hw.physicalcpu hw.logicalcpu')rplc LF;' '
case.'OpenBSD' do.
 1".(2!:0'sysctl -n hw.ncpuonline hw.ncpu')rplc LF;' '
case.'Win' do.
 2{.1".;1{<;._2 spawn_jtask_'wmic cpu get numberofcores,numberoflogicalprocessors'
case. do.
 1 1
end.
catch.
 1 1
end. 
)
