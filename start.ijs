start_jcs_=: 3 : 0
load'~addons/net/jcs/jcs.ijs'
c=. 5
while. c=. <:c do.
 try.
  serverinit_jcs_ y
 catch.
  (LF,~(18":6!:9''),'  ',(10{.'jcs-start'),'  ',(8":2!:6''),'  ',y,'  ',(13!:12'')rplc LF;' LF ') fappend '~temp/zmq/',(":2!:6''),'.log'
  6!:3[2
 end.
end. 
)
