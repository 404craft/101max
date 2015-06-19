-- compute distance between two points of an object (i.e. an object is not to scale)
-- define target distance / real measurements of the object
-- auto-rescale an object locally or auto-rescale entire scene
-- limited functionality plugin

oTar = undefined
oSrc = undefined

fn saveScale =
(
	for n = 1 to selection.count do
	(
		if getuserprop selection[n] "oScale_x" == undefined do
		(
		setuserprop selection[n] "oScale_x" selection[n].scale.x
		setuserprop selection[n] "oScale_y" selection[n].scale.y
		setuserprop selection[n] "oScale_z" selection[n].scale.z
		)
	)
)

rollout spectrum "spectrum" width:160 height:192
(
	button sp_btn_execute "execute" pos:[88,24] width:64 height:16
	pickbutton btn4 "PickButton" pos:[84,295] width:0 height:0
	listbox sp_listbox "" pos:[8,120] width:72 height:4
	button btn5 "Button" pos:[86,281] width:0 height:0
	checkbutton sp_chk_mode "mode" pos:[88,96] width:64 height:16
	button sp_btn_target "target" pos:[8,48] width:72 height:16
	spinner sp_spn_target "" pos:[8,64] width:72 height:16 range:[1,100,1] type:#float
	label sp_lbl_101 "@101craft" pos:[96,168] width:53 height:16

     global tDis
     global cDis
     global fDis
     global sFac
	 global oSel
	 global oTar
	 global oSrc
	 global lArray = #()
	 global cArray = #()
	button sp_btn_resetX "resetX" pos:[88,120] width:64 height:16
	button sp_btn_scale_res "zero" pos:[88,144] width:64 height:16 toolTip:"reset to original scale"
	checkbutton sp_chk_tape "tape" pos:[8,24] width:72 height:16
	label sp_lbl_top "spectrum" pos:[9,6] width:64 height:16
	pickbutton sp_btn_append "append list" pos:[8,96] width:72 height:16
	button sp_btn_source "source" pos:[88,48] width:64 height:16
	spinner sp_spn_source "" pos:[88,64] width:64 height:16 enabled:false
	
	on sp_btn_execute pressed do
	(
	saveScale()
	if sp_chk_mode.state == true then
	(
			for o = 1 to lArray.count do 
			(
			lArray[o].scale = lArray[o].scale * sFac
			)
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
	 if state == true then sp_chk_mode.text = "global"
		 else sp_chk_mode.text = "local"
	)
	on sp_btn_target pressed do
	(
		saveScale()
	    if selection.count != 0 then
	    (
			if $ != oSrc then
			(
				if $.mesh.selectedVerts.count == 2 then
				(
				sp_btn_target.text = $.name
				oTar = $
				tArr = for i in $.mesh.selectedVerts collect i.index
				t1 = tArr[1]
				t2 = tArr[2]
				tDis = sp_spn_target.value
				cDis = distance $.mesh.verts[t1].pos $.mesh.verts[t2].pos
				sFac = (tDis / cDis)
				saveScale()
				)
				else messagebox("select two points in a mesh")
			)
			else messagebox("select a different object")
	    )
	    else messagebox("select an object")
	)
	on sp_spn_target changed val do
	(
	tDis = sp_spn_target.value
	sFac = (tDis / vDis)
	)
	on sp_spn_target buttondown do
	(
		tDis = sp_spn_target.value
		sFac = (tDis / vDis)
		)
	on sp_spn_target buttonup do
	(
		tDis = sp_spn_target.value
		sFac = (tDis / vDis)
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
			if (getuserprop selection[n] "oScale_x") != undefined do 
			(
				selection[n].scale.x = (getuserprop selection[n] "oScale_x") as float
				selection[n].scale.y = (getuserprop selection[n] "oScale_y") as float
				selection[n].scale.z = (getuserprop selection[n] "oScale_z") as float
			)
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
		for n in oSel do appendifunique cArray n.children
		print(cArray)
	)
	on sp_btn_source pressed do
	(
	    if selection.count != 0 AND oSrc == undefined do
	    (
			if $ != oTar then
			(
				if $.mesh.selectedVerts.count == 2 then
				(
				sp_btn_source.text = $.name
				oSrc = $
				sp_spn_source.enabled = true
				sArr = for i in $.mesh.selectedVerts collect i.index
				s1 = sArr[1]
				s2 = sArr[2]
				sDis = sp_spn_source.value
				cDis = distance $.mesh.verts[s1].pos $.mesh.verts[s2].pos
-- 				sFac = (sDis / vDis)
				saveScale()
				)
				else messagebox("select two points in a mesh")
			)
			else messagebox("select a different object")
	    )
	    if selection.count == 0 AND oSrc != undefined do
		(
		oSrc = undefined
		sp_btn_source.text = "source"
		sp_spn_source.enabled = false
		)
		if selection.count == 0 AND oSrc == undefined do messagebox("select an object")
	)
)
createdialog spectrum
