--3ds max .fbx to unity mass exporter
--final-check asset inspector
--pipeline plugin

/*
--check for construction history
for s in $ as array where superclassof s == GeometryClass do 
	if ((s.modifiers[1] != undefined) AND (s.modifiers[1].name != "Unwrap UVW")) OR (s.modifiers.count > 1) do print s.name

--validate scale
for s in $ as array where s.scale != [1,1,1] do 
(
print s.name
resetscale s
)
*/

sel = selection as array
global tmp = #()
for s in sel do
(
	n = substring s.name 1 (s.name.count-3)
	if tmp.count == 0 do 
	(
	print ("1-fired")
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
			print ("2-fired")
			arr = #()
			append arr n
			append tmp arr
			append tmp[t+1] s
			)
		)
		if tmp[t][1] == n do append tmp[t] s
	)
)

global c = 1
hide objects
try(destroydialog :: max4u)catch()
rollout max4u "" width:144 height:80
(
	button btn1 "<<" pos:[8,8] width:64 height:32
	button btn2 ">>" pos:[72,8] width:64 height:32
	button btn3 "EXPORT" pos:[8,40] width:128 height:32
	on btn1 pressed do
	(
	hide objects
	t = #()
	for n = 2 to tmp[c].count do append t tmp[c][n]
	unhide t
	c+=1
	if c > tmp.count do c = 1
	)
	on btn2 pressed do
	(
	hide objects
	t = #()
	for n = 2 to tmp[c].count do append t tmp[c][n]
	unhide t
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
)
createdialog max4u
