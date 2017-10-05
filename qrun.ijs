NB. qrun

require'~addons/net/jcs/jcs.ijs'

qshow=: 3 : 0
log_jcs_ y
echo y
if. IFQT do. wd'msgs' end.
)

NB. [sleep - default 0] qrun job_count , task_count , [job_size default 7 - power of 10]
NB. sleep for sleep seconds before first use after starting tasks
qrun=: 3 : 0
0 qrun y
:
'must have count 2 or 3' assert (#y) e. 2 3
'must be integer' assert 4=3!:0 y+0
'must be > 0' assert y>0
'jobc taskc joblen'=. 3 {. y,7
killall_jcs_'' NB. brute force clean up
'' fwrite logfile_jcs_
timeout=. 5000 NB. 5 second poll timeout
taskc=. jobc<.taskc
jobs=: '?~',"1 1 ('e',":joblen),~"1 1 ":,.jobc$5 2 3
tsks=. tasks=: >jcst each 65201+i.taskc
6!:3 x NB. see if sleep before 1st use avoids hang
i=. 0
start=. 6!:1''
while. #tasks do.
  'rc strerror reads writes errors'=. poll_jcs_ timeout;'';<tasks
  if. _1=rc do. ('poll error: ',strerror) assert 0 end.
  if.  0=rc do. qshow'poll 0:' end.
  for_n. writes do.
    if. #jobs do.
      qshow 'start:  ',":i,tsks i. n
      t=. (":i,tsks i.n),'[',({.jobs),'[log_jcs_ ''pid:    ',(":i,tsks i.n),''','' '',','":2!:6'''''
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
     a=. runz__n''
     qshow 'finish: ',": a
   catch.
     qshow 'error:  ',(;n),LF,lse__n
   end.
  end.
end.
qshow'end:'
start-~6!:1''
)
