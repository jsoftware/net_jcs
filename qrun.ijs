NB. qrun

NB. argument is: job count, task count, [job size as power of 10]
qrun=: 3 : 0
'must have count 2 or 3' assert (#y) e. 2 3
'must be integer' assert 4=3!:0 y+0
'must be > 0' assert y>0
'jobc taskc joblen'=. 3 {. y,7
taskc=. jobc<.taskc
jobs=: '?~',"1 1 ('e',":joblen),~"1 1 ":,.jobc$5 2 3
tasks=: >jcst each 65201+i.taskc
if. IFQT do. show=. wd @ ('msgs' [ echo) else. show=. echo end.
show (;:'num sentence'),:(":,.i.#jobs);jobs
show tasks
i=: 0
start=. 6!:1''
while. #tasks do.
  'reads writes errors'=. poll_jcs_ 180000;'';<tasks
  for_n. writes do.
    if. #jobs do.
      show 'start (job task): ',(":i),' ',;n
      runa__n (":i),'[',{.jobs
      jobs=: }.jobs
      i=. >:i
    else.
NB. don't need this task anymore
      show 'end task: ',,;n
      kill__n''
      tasks=: tasks-.n
    end.
  end.
  for_n. reads do.
    a=. runz__n''
    show (28$' '),'finish: ',(":a),' ',;n
  end.
end.
start-~6!:1''
)
