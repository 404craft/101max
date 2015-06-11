-- compute distance between two points of an object (i.e. an object is not to scale)
-- define target distance / real measurements of the object
-- auto-rescale an object locally or auto-rescale entire scene
-- limited functionality plugin

fn saveScale =
(
	for n = 1 to selection.count do
	(
		--if getuserprop selection[n] "oScale" == undefined do setuserprop selection[n] "oScale" selection[n].scale
		setuserprop selection[n] "oScale" selection[n].scale
	)
)

rollout spectrum "spectrum" width:104 height:408
(
	button sp_btn_execute "execute" pos:[8,360] width:88 height:16
	pickbutton btn4 "PickButton" pos:[84,295] width:0 height:0
	listbox sp_listbox "" pos:[8,208] width:88 height:5
	button btn5 "Button" pos:[86,281] width:0 height:0
	checkbutton sp_chk_mode "local mode" pos:[8,288] width:88 height:16
	button sp_btn_points "select" pos:[8,56] width:88 height:16
	spinner sp_distance "" pos:[8,80] width:88 height:16 range:[1,100,1] type:#float
	label sp_lbl_factor "scale factor" pos:[25,121] width:112 height:16
	label sp_lbl_distance "distance" pos:[31,102] width:120 height:15
	label sp_lbl_101 "@101craft" pos:[27,388] width:53 height:16

     global tDis
     global vDis
     global fDis
     global sFac
	 global oSel
	 global lArray = #()

	label sp_lbl_scale_curr "current scale" pos:[25,141] width:114 height:16
	button sp_btn_resetX "resetX" pos:[8,312] width:88 height:16
	button sp_btn_scale_res "original scale" pos:[8,336] width:88 height:16
	checkbutton sp_chk_tape "tape off" pos:[8,32] width:88 height:16
	label sp_lbl_top "spectrum" pos:[30,6] width:64 height:16
	pickbutton sp_btn_append "append list" pos:[8,184] width:88 height:16
	
	on sp_btn_execute pressed do
	(
	-- 	print(sFac)
	-- 	print($.scale.x*sFac)
	-- 	scale $ [$.scale.x*sFac,$.scale.x*sFac,$.scale.x*sFac]
	saveScale()
	if sp_chk_mode.state == true then
	(
		for o = 1 to lArray.count do lArray[o].scale = lArray[o].scale * sFac
	)
	else $.scale = $.scale *sFac
	)
	on sp_listbox doubleClicked sel do
	(
		if sp_listbox.items.count > 0 and sp_listbox.selection > 0 do
		(
		deleteitem lArray sp_listbox.selection
		sp_listbox.items = deleteItem sp_listbox.items sp_listbox.selection
		)
	)
	on sp_chk_mode changed state do
	(
	 if state == true then sp_chk_mode.text = "global mode"
		 else sp_chk_mode.text = "local mode"
	)
	on sp_btn_points pressed do
	(
		saveScale()
	    if selection.count != 0 then
	    (
	    sArr = for i in $.selectedVerts collect i.index
	    v1 = sArr[1]
	    v2 = sArr[2]
	    tDis = sp_distance.value
	    vDis = distance $.verts[v1].pos $.verts[v2].pos
	    sFac = (tDis / vDis)
	    sp_lbl_factor.text = sFac  as string
	    sp_lbl_distance.text = vDis as string
		sp_lbl_scale_curr.text = $.scale as string
		print(tDis);print(sFac)
		saveScale()
	    )
	    else messagebox("select two points in a mesh")
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
	on sp_btn_resetX pressed do
	(
		for n = 1 to selection.count where superclassof selection[n] == geometryclass do
			(
				resetxform selection[n]
				convertto selection[n] editable_poly
			)
	)
	on sp_btn_scale_res pressed do
	(
		for n = 1 to selection.count do 
		(
		if (getuserprop selection[n] "oScale") != undefined do selection[n].scale = getuserprop selection[n] "oScale"
		)
	)
	on sp_chk_tape changed state do
	(
	actionMan.executeAction 0 "40472"
	)
	on sp_btn_append picked obj do
	(
		oSel = obj
		sp_listbox.items = append sp_listbox.items (oSel as string)
		appendifunique lArray oSel
	)
)
createdialog spectrum
