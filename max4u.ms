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
tmp = #()
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
	for t = tmp.count to 1 by -1 do
	(
		if t == tmp.count AND tmp[t][1] != n do 
			(
			print ("2-fired")
			arr = #()
			append arr n
			append tmp arr
			)
	)
	for t in tmp do 
		if findItem t n != undefined do appendifunique t s
)

for t in tmp do
(
	--Geometry------------------------------------------------------------------------
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
