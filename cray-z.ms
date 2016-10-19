--max to zbrush pipeline plug
--under development

/*
ids = selection[1].material.materialidlist.count
for obj in selection do
(
	if classof obj != editable_poly do (print "converting"; convertto obj editable_poly)
    for n = polyop.getnumfaces obj to 1 by -1 do
    (
    id = polyop.getfacematid obj n
    if id > ids do print ("err: " + "id nr." + id as string)
    )
)
*/
debug = true
sel = selection as array
count = 1

for s in sel where isGroupHead s do (explodegroup s; deleteitem sel (finditem sel s))

while count <= sel.count do
(
	select sel[count]
	
	instancemgr.getinstances $ &instances
	
	if instances.count > 0 do
		instancemgr.makeobjectsunique &instances #individual
	
	deselect $
	count += 1
)
select sel
if debug do print sel

ids = sel[1].material.materialidlist.count
for obj in sel where superclassof obj == geometryclass do
(
	if classof obj != editable_poly do convertto obj editable_poly
	c = 0
	for m = 1 to ids do
	(
		main = #()
		for n = polyop.getnumfaces obj to 1 by -1 do
		(
		id = polyop.getfacematid obj n
		if id == m do append main n
		)
		if debug do print ("mat:" + m as string + " " + main.count as string)
		polyop.detachfaces obj main asnode:true name:(obj.name + c as string + m as string)
		c+=1
	)
)

tmp = #()

for m = 1 to ids do append tmp #()
	
for g in geometry where polyop.getnumfaces g > 1 do
(
	if debug do print ("tmp-sort-----------")
	id = polyop.getfacematid g 2
	if debug do print (id as string + " " + g.name)
	if id > ids do (print ("err: " + "id nr." + id as string);  id = 1)
    append tmp[id] g
	if debug do print ("-------------------")
)

if debug do print tmp

for t = 1 to tmp.count where tmp[t].count > 0 do
(  
	if debug do print ("tmp-attach---------")
	t1 = polyop.getfacematid tmp[t][1] 2	
    for n = tmp[t].count to 1 by -1 do
    (
    t1 = polyop.getfacematid tmp[t][1] 2	
    t2 = polyop.getfacematid tmp[t][n] 2
    if debug do print (t1 as string + " " + t2 as string+ tmp[t][n].name + "->" + tmp[t][1].name)
    if tmp[t][n] != tmp[t][1] then polyop.attach tmp[t][1] tmp[t][n]
        else if tmp[t][n] == tmp[t][1] do tmp[t] = tmp[t][1]
    )
    if debug do print ("-------------------")
)
	
if debug do print tmp
for t = 1 to tmp.count where classof tmp[t] != Array do
(
    if debug do print (tmp[t].name + " mat:" + t as string)
    tmp[t].name = ("mat" + t as string)
    select tmp[t]
    exportfile (tmp[t].name + ".obj") #noprompt selectedonly:true
)
