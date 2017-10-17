NB. qrun

require'~addons/net/jcs/jcs.ijs'

qshow=: 3 : 0
echo y
if. IFQT do. wd'msgs' end.
)

qrun=: 3 : 0
'must have count 2 or 3' assert (#y) e. 2 3
'must be integer' assert 4=3!:0 y+0
'must be > 0' assert y>0
'jobc taskc joblen'=. 3 {. y,7
killp_jcs_'' NB. brute force clean up
timeout=. 5000 NB. 5 second poll timeout
taskc=. jobc<.taskc
jobs=: '?~',"1 1 ('e',":joblen),~"1 1 ":,.jobc$5 2 3
tsks=. tasks=: jcst 65201+i.taskc
i=. 0
start=. 6!:1''
while. #tasks do.
  'rc reads writes errors'=. poll_jcs_ timeout;'';<tasks
  if.  0=rc do. qshow'poll 0:' end.
  for_n. writes do.
    if. #jobs do.
      qshow 'start:  ',":i,tsks i. n
      t=. (":i,tsks i.n),'[',({.jobs)
      runa__n t
      jobs=: }.jobs
      i=. >:i
    else.
      qshow 'kill:   ',":tsks i. n
      kill__n''
      tasks=: tasks-.n
    end.
  end.
  for_n. reads do.
   try.
     a=. runz__n 0
     qshow 'finish: ',": a
   catch.
     qshow 'error:  ',(;n),LF,lse__n
   end.
  end.
end.
qshow'end:'
start-~6!:1''
)
