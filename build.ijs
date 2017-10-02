NB. build

mkdir_j_ '~addons/net/jcs'

f=. 3 : 0
('~addons/net/jcs/',y,'.ijs') fcopynew '~Addons/net/jcs/',y,'.ijs'
)

f each ;: 'jcs jcs_lab jcs_jd_lab qrun'
