-- max to zbrush pipeline plug
-- under development

sel = selection as array
count = 1

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

mcnt = selection[1].material.materialidlist.count
for obj in selection as array do
(
	if classof obj != editable_poly do convertto obj editable_poly
	for m = 1 to mcnt do
	(
		main = #()
		for n = polyop.getnumfaces obj to 1 by -1 do
		(
		id = polyop.getfacematid obj n
		if id == m do append main n
		)
		polyop.detachfaces obj main asnode:true name:(obj.name + m as string)
	)
)

tmp = #()

for m = 1 to mcnt do append tmp #()
	
for g in geometry do
(
	if classof g != editable_poly do convertto g editable_poly

    if polyop.getnumfaces g > 0 do
	(
	id = polyop.getfacematid g 1
    append tmp[id] g
	)
)

for t in tmp do
    (
		for n = t.count to 2 by -1 do
		(
		polyop.attach t[1] t[n]
		)
    )
    
for t in tmp do
(
	for z in t do
	(
		if isvalidnode z == true do
		(
		select z
		exportfile (z.name + ".obj") #noprompt selectedonly:true
		)
	)
)
