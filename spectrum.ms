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

fn updateSpn spn =
(
	if spn == 0 then
	(
		if spectrum.sp_spn_target.enabled == true do
		(
			try
			(
			tDis = spectrum.sp_spn_target.value
			sFac = (tDis / tvDis)
			print ("target distance:" + tDis as string)
			print ("target vert distance:" + tvDis as string)
			print ("scale factor:" + sFac as string)
			)
			catch()
		)
	)
	else
	(
		if spectrum.sp_spn_source.enabled = true do
		(
			try
			(
			sDis = spectrum.sp_spn_source.value
			iUnt = (svDis / sDis)
			print ("source distance:" + sDis as string)
			print ("source vert distance:" + svDis as string)
			print ("custom unit:" + iUnt as string)
			)
			catch()
		)
	)
)

rollout spectrum "spectrum" width:160 height:160
(
	global oTar --target object
	global tDis --target distance
	global tvDis --current target vertex distance
	global sFac --scale factor
	
	global oSrc --source object
	global sDis --source distance
	global svDis  --current source vertex distance
	global iUnt --imaginary / custom unit
	
	global oSel --appended item
	global lArray = #()
	global cArray = #()
	
	button sp_btn_execute "execute" pos:[88,8] width:64 height:16
	pickbutton btn4 "PickButton" pos:[84,295] width:0 height:0
	listbox sp_listbox "" pos:[8,96] width:72 height:4
	button btn5 "Button" pos:[86,281] width:0 height:0
	checkbutton sp_chk_mode "mode" pos:[88,72] width:64 height:16
	button sp_btn_target "target" pos:[8,32] width:72 height:16
	spinner sp_spn_target "" pos:[8,48] width:72 height:16 type:#float enabled:false range:[0,16777216,0]
	label sp_lbl_101 "@101craft" pos:[96,141] width:53 height:16
	button sp_btn_resetX "resetX" pos:[88,96] width:64 height:16
	button sp_btn_scale_res "zero" pos:[88,120] width:64 height:16 toolTip:"reset to original scale"
	checkbutton sp_chk_tape "tape" pos:[8,8] width:72 height:16
	pickbutton sp_btn_append "append list" pos:[8,72] width:72 height:16
	button sp_btn_source "source" pos:[88,32] width:64 height:16
	spinner sp_spn_source "" pos:[88,48] width:64 height:16 type:#float enabled:false range:[0,16777216,0]
	
	on sp_btn_execute pressed do
	(
	saveScale()
	if oSrc == undefined then
	(
		case sp_chk_mode.state of
		(
		true:
			  (
				  for o = 1 to lArray.count do 
				  (
				  lArray[o].scale = lArray[o].scale * sFac
				  )
			   )
		false:
			   (
			   $.scale = $.scale *sFac	   
			   )
		default:
			   ()
		)
	)
	else
	(
	sFac = tDis * iUnt
	print ("scale factor:" + sFac as string)
	print ("target distance:" + tDis as string)
	print ("custom unit:" + iUnt as string)
	$.scale = $.scale * sFac
	)
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
	    if selection.count != 0 AND oTar == undefined then
	    (
			if $ != oSrc then
			(
				if $.mesh.selectedVerts.count == 2 then
				(
				sp_spn_target.enabled = true
				sp_btn_target.text = $.name
				oTar = $
				tArr = for i in $.mesh.selectedVerts collect i.index
				t1 = tArr[1]
				t2 = tArr[2]
				tDis = sp_spn_target.value
				tvDis = distance $.mesh.verts[t1].pos $.mesh.verts[t2].pos
				sFac = (tDis / tvDis)
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
	updateSpn 0
	)
	on sp_spn_target buttondown do
	(
    updateSpn 0
		)
	on sp_spn_target buttonup do
	(
	updateSpn 0
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
				svDis = distance $.mesh.verts[s1].pos $.mesh.verts[s2].pos
				-- 1 imaginary or custom unit
				iUnt = (svDis / sDis)
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
	on sp_spn_source changed val do
	(
	updateSpn 1
	)
	on sp_spn_source buttondown  do
	(
	updateSpn 1
	)
	on sp_spn_source buttonup  do
	(
	updateSpn 1
	)
)
createdialog spectrum
