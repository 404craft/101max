--short for "crayon for zbrush"
--max to zbrush pipeline plug
--divides all in-scene meshes according to multimaterial ids and exports newly created objects as separate files
--this way you can quickly and efficiently load .objs into separate layers in zbrush
--new plugin under development

/*
fn remat mat id sel =
(
	for s in sel do
	(
		s.material = mat
		main = #{}
		epoly = undefined
		if classof s.modifiers[1] != edit_poly do
		(
		addmodifier s (edit_poly name:"Poly Color")
		)
		
		epoly = s.modifiers[1]
		
		for n = getnumfaces s to 1 by -1 do
		(
			append main n
		)
		epoly.setselection #face main
		epoly.SetOperation #setmaterial
		epoly.materialIDToSet = id-1
		epoly.commit()
	)
	hide sel
)
try(destroydialog ::multimat)catch()
global t1
global t2
global t3
rollout multimat "" width:88 height:128
(
	materialButton btn_mat "material" pos:[8,8] width:72 height:24
	spinner spn_matid "" pos:[24,40] width:42 height:16 range:[1,100,1] type:#integer
	button btn_apply "apply" pos:[8,64] width:72 height:24
	button btn_t1 "t1" pos:[8,96] width:24 height:24
	button btn_t2 "t2" pos:[32,96] width:24 height:24
	button btn_t3 "t3" pos:[56,96] width:24 height:24
	
	on btn_mat picked mtl do
	(
		btn_mat.text = mtl.name
	)
	on btn_apply pressed do
	(
		remat btn_mat.material spn_matid.value $
	)
	on btn_t1 pressed do
	(
		for m in $.modifiers where m == t1 or m == t2 or m == t3 do deletemodifier $ m
		if t1 == undefined do t1 = TurboSmooth iterations: 1
		addmodifier $ t1
	)
	on btn_t2 pressed do
	(
		for m in $.modifiers where m == t1 or m == t2 or m == t3 do deletemodifier $ m
		if t2 == undefined do t2 = TurboSmooth iterations: 2
		addmodifier $ t2
	)
	on btn_t3 pressed do
	(
		for m in $.modifiers where m == t1 or m == t2 or m == t3 do deletemodifier $ m
		if t3 == undefined do t3 = TurboSmooth iterations: 3
		addmodifier $ t3
	)
)
createdialog multimat
*/

fn check =
(
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
)

fn divide =
(
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
)
try(destroydialog ::cray_z)catch()
rollout cray_z "" width:144 height:56
(
	button btn1 "check" pos:[8,8] width:128 height:16 toolTip:""
	button btn2 "export" pos:[8,32] width:128 height:16 toolTip:""
	
	on btn1 pressed do
	(
		check()
	)
	on btn2 pressed do
	(
		divide()
	)
)
createdialog cray_z
