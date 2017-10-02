
0 : 0
jcs is build with zmq

zmq is an api built on top of sockets

it is available across platforms and removes almost all the mundane and
critical chores in building a solid, high-performance, scalable server

if unfamiliar with zmq, it worth looking at: www.zeromq.org
at least get an overview with: zguide.zeromq.org/page:all
if zmq is not already installed, you'll have to look at: zeromq.org/intro:get-the-software
)

require'~addons/net/jcs/jcs.ijs'
version_jcs_''   NB. zmq version - error if problems with zmq installation
port=: 65201     NB. use this port
killp_jcs_ port  NB. kill an previous server on this port
c=: jcst port    NB. create server task and client
run__c'i.2 3'    NB. run sentence on server
run__c'2+a.'
lse__c           NB. last server error
run__c'notdef'   NB. ". is different than immex - no value error
killp_jcs_ 65202 NB. kill any previous server on this port
d=: jcst port+1  NB. create another server
run__d'a=: i.2 3'
run__c'a=: 7'
(run__c'a')+run__d'a'
jcs''           NB. jcs locales
servers_jcs_''  NB. server ports+pids
kill__c''
kill__d''
jcs''
servers_jcs_''
c=. jcst port
run__c'a=: i.5'
jcs''        NB. jcs locales
destroy__c'' NB. destroy client locale
jcs''
servers_jcs_''

0 : 0
server running on port 65201
zmq ports are 'sticky'
a server can be started after the first client requests
a server can be stopped and restarted without problems with client requests
a server can serve any number of clients
)

NB. by convention the jcs port range is 65100 to 65299
NB. and 65100 to 65199 are for Jd servers

c=. jcsc 65201 NB. create client locale and connect to server
run__c'a'
NB. next sentence won't show until it completes - takes 5 seconds
run__c'6!:3[5' NB. server sleeps for 5 and we wait for it to finish
runa__c'6!:3[5' NB. server starts sentence - we do not wait
NB. wait a bit for the server to finish
runz__c''      NB. get server result - wait if necessary
runz__c''      NB. error - runa required before runz
kill__c''      NB. kill server and close locale
c=: jcst port
c=: jcst port+1
servers_jcs_''
jcs''
killall_jcs_'' NB. clean slate - kill all servers, destroy all client/server locales, and do ctx_term
servers_jcs_''
jcs''

0 : 0
jcs can be used for parallelism
following example runs n jobs on m tasks
)

NB. next step reads in a verb to run jobs on several tasks
NB. the argument is: jobs, tasks [,job size]
load 'net/jcs/qrun'

NB. this creates 3 jobs on 4 tasks of size 7 - takes many seconds to run:
qrun 3 2 7

0 : 0
time qrun with 20 jobs and tasks between 1 and 4 and task size 6
a quad core system running 4 tasks will run faster - but not 4 times faster
)

0 : 0
jcs needs to be robust - and it should be as zmq is robust
after running through the lab cleanly
experiment with how it behaves with misuse and stress
please report any problems and suggestions for improvements
)
help_jcs_ NB. jcs summary
