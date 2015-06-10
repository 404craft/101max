-- compute distance between two points of an object (i.e. an object is not to scale)
-- define target distance / real scale of the object
-- scale an object locally or rescale entire scene
-- limited functionality plugin

rollout spectrum "spectrum" width:176 height:336
(
	button sp_btn_execute "execute" pos:[40,272] width:96 height:24
	label lbl_point_01 "point_01" pos:[16,8] width:144 height:16
	label lbl_point_02 "point_02" pos:[16,24] width:144 height:16
	pickbutton btn4 "PickButton" pos:[84,295] width:0 height:0
	listbox sp_listbox "" pos:[40,160] width:98 height:5
	button btn5 "Button" pos:[86,281] width:0 height:0
	checkbutton sp_chk_mode "local" pos:[40,240] width:96 height:24
	button sp_btn_append "append" pos:[40,128] width:96 height:24
	button sp_btn_points "select" pos:[40,48] width:96 height:24
	spinner sp_distance "" pos:[48,80] width:80 height:16 range:[1,100,0] type:#float
	label sp_lbl_factor "scale factor" pos:[62,105] width:112 height:16
	label sp_lbl_distance "distance" pos:[66,306] width:120 height:15
	
	global tDis
	on sp_btn_execute pressed do
	(
	)
	on sp_listbox doubleClicked sel do
	(
	)
	on sp_chk_mode changed state do
	(
	)
	on sp_btn_append pressed do
	(
	)
	on sp_btn_points pressed do
	(
	sArr = for i in $.selectedVerts collect i.index
	print(sArr)
	v1 = sArr[1]
	v2 = sArr[2]
	tDis = sp_distance.value
	vDis = distance $.verts[v1].pos $.verts[v2].pos
	sp_lbl_factor.text = (vDis / tDis)  as string
	sp_lbl_distance.text = vDis as string
	iV1 = $.verts[v1].pos
	iV2 = $.verts[v2].pos
	lbl_point_01.text = iV1 as string
	lbl_point_02.text = iV2 as string
	)
	on sp_distance changed val do
	(
	tDis = sp_distance.value
	)
	on sp_distance buttondown do
	(
	tDis = sp_distance.value
	)
	on sp_distance buttonup do
	(
	tDis = sp_distance.value
	)
)
createdialog spectrum
