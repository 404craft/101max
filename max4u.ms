--3ds max .fbx to unity bulk exporter
--final-check asset inspector
--pipeline plugin

/*
--correct material names
print ("------------------------")
c=1
for m in scenematerials do (c+=1; print ((c as string) + "_" + m.name))

for m in scenematerials do
(
try(
f = m.diffusemap.filename
n = substring f 67 f.count
s = substring n 1 (n.count-4)
m.name = s
)catch()
)

print ("------------------------")
c=1
for m in scenematerials do (c+=1; print ((c as string) + "_" + m.name))
*/

fn gather = 
(
	if selection.count < 2 then messagebox ("select an array of objects")
	else
	(
	hide objects
	sel = selection as array
	tmp = #()
		for s in sel do
		(
			n = substring s.name 1 (s.name.count-3)
			if tmp.count == 0 do 
			(
			arr = #()
			append arr n
			append tmp arr
			)
			for t = 1 to tmp.count do
			(
				if tmp[t][1] != n do 
				(
					if t == tmp.count do
					(
					arr = #()
					append arr n
					append tmp arr
					append tmp[t+1] s
					)
				)
				if tmp[t][1] == n do append tmp[t] s
			)
		)
	)
)
global c = 1
global tmp = #()
try(destroydialog :: max4u)catch()
rollout max4u "" width:144 height:336
(
	button btn1 "<<" pos:[8,40] width:64 height:32
	button btn2 ">>" pos:[72,40] width:64 height:32
	button btn3 "export" pos:[8,296] width:128 height:32
	button btn4 "0-scale" pos:[8,184] width:128 height:32
	button btn5 "0-transform" pos:[8,216] width:128 height:32
	button btn6 "check construction" pos:[8,80] width:128 height:32
	button btn7 "check scale" pos:[8,112] width:128 height:32
	button btn8 "check transform" pos:[8,144] width:128 height:32
	button btn9 "0" pos:[104,256] width:32 height:32
	checkbutton ckb1 "x" pos:[8,256] width:32 height:32 checked:true
	checkbutton ckb2 "y" pos:[40,256] width:32 height:32 checked:true
	checkbutton ckb3 "z" pos:[72,256] width:32 height:32
	button btn10 "collect" pos:[8,8] width:128 height:32
	on btn1 pressed do
	(
	hide objects
	t = #()
	for n = 2 to tmp[c].count do append t tmp[c][n]
	unhide t
	select t
	unhide $pilot
	c+=1
	if c > tmp.count do c = 1
	)
	on btn2 pressed do
	(
	hide objects
	t = #()
	for n = 2 to tmp[c].count do append t tmp[c][n]
	unhide t
	select t
	unhide $pilot
	c-=1
	if c < 1 do c = tmp.count
	)
	on btn3 pressed do
	(
		for t in tmp do
		(
			FBXExporterSetParam "SmoothingGroups" true
			FBXExporterSetParam "Animation" true
			FBXExporterSetParam "BakeAnimation" false
			FBXExporterSetParam "Cameras" false
			FBXExporterSetParam "Lights" false
			FBXExporterSetParam "EmbedTextures" false
			FBXExporterSetParam "AxisConversionMethod" "None"
			FBXExporterSetParam "UpAxis" "Y" 
			FBXExporterSetParam "SmoothMeshExport" true
			FBXExporterSetParam "Preserveinstances" true
			FBXExporterSetParam "ShowWarnings" true
			FBXExporterSetParam "GenerateLog" false
			FBXExporterSetParam "ASCII" false
			FBXExporterSetParam "FileVersion" "FBX201200"
			clearSelection()
			for v = 2 to t.count do selectmore t[v]
			exportfile (t[1] + ".fbx") #noprompt selectedonly:true
		)
	)
	on btn4 pressed do
	(
		--reset scale
		clearlistener()
		print ("scale reset-------------")
		sel = $
		if selection.count > 1 do sel = $ as array
		for s in sel where s.scale != [1,1,1] do 
		(
		resetscale s
		)
	)
	on btn5 pressed do
	(
		--reset transform
		clearlistener()
		print ("transform reset---------")
		sel = $
		if selection.count > 1 do sel = $ as array
		for s in sel where s.rotation != (quat 0 0 0 1) do 
		(
		resettransform s
		)
	)
	on btn6 pressed do
	(
		--check construction history
		clearlistener()
		print ("construction check------")
		sel = $
		if selection.count > 1 do sel = $ as array
		for s in sel where superclassof s == GeometryClass do 
		if ((s.modifiers[1] != undefined) AND (s.modifiers[1].name != "Unwrap UVW")) OR (s.modifiers.count > 1) do print s.name
	)
	on btn7 pressed do
	(
		--check scale
		clearlistener()
		print ("scale check-------------")
		sel = $
		if selection.count > 1 do sel = $ as array
		for s in sel where s.scale != [1,1,1] do 
		(
		print (s.name + ":" + (s.scale as string))
		)
	)
	on btn8 pressed do
	(
		--check transform
		clearlistener()
		print ("transform check---------")
		sel = $
		if selection.count > 1 do sel = $ as array
		for s in sel where s.rotation != (quat 0 0 0 1) do 
		(
		print (s.name + ":" + (s.rotation as string))
		)
	)
	on btn9 pressed do
	(
		sel = $
		if selection.count > 1 do sel = $ as array
		for s in sel do 
		(
		x = s.pos.x
		y = s.pos.y
		z = s.pos.z
		if ckb1.state == true do x = 0
		if ckb2.state == true do y = 0
		if ckb3.state == true do z = 0
		s.pos = [x,y,z]
		)
	)
	on btn10 pressed do
	(
		gather()
	)
)
createdialog max4u
