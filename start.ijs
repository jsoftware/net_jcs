start_jcs_=: 3 : 0
load'~addons/net/jcs/jcs.ijs'
c=. 10
while. c=. <:c do.
 try.
  serverinit_jcs_ y NB. could fail if previous not quite dead yet
 catch.
  (LF,~(18":6!:9''),'  ',(10{.'jcs-start'),'  ',(8":2!:6''),'  ',y,'  ',(13!:12'')rplc LF;' LF ') fappend '~temp/zmq/',(":2!:6''),'.log'
  6!:3[0.5
 end.
end. 
)
