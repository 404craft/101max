-- compute distance between two points of an object (i.e. an object is not to scale)
-- define target distance / real measurements of the object
-- auto-rescale an object locally or auto-rescale entire scene
-- limited functionality plugin

try(destroydialog ::spectrum)catch()

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
				
				if $.scale != [1,1,1] then
				(
				print ("---target scale out---")	
				s_tvDis = undefined
				s_tvDis = $.scale.x * tvDis
				sFac = (tDis / s_tvDis)
				print ("target vert distance:" + s_tvDis as string)
				)
				
				else
				(
				print ("---target---")
				sFac = (tDis / tvDis)
				print ("target vert distance:" + tvDis as string)
				)
				print ("target distance:" + tDis as string)
				print ("scale factor:" + sFac as string)
			)
			catch()
		)
	)
	else
	(
		if spectrum.sp_spn_source.enabled == true do
		(
			try
			(
				sDis = spectrum.sp_spn_source.value
				
				if $.scale != [1,1,1] do
				(
				print("---source scale out---")	
				s_svDis = undefined
				s_svDis = $.scale * svDis
				iUnt = (s_svDis / sDis)
				print ("source vert distance:" + s_svDis as string)
				)
			
				else
				(
				print("---source---")	
				iUnt = (svDis / sDis)
				print ("source vert distance:" + svDis as string)
				)
				print ("source distance:" + sDis as string)
				print ("custom unit:" + iUnt as string)
			)
			catch()
		)
	)
)

rollout spectrum "" width:160 height:160
(
	global oTar --target object
	global tDis --target distance
	global tvDis --current target vertex distance
	global sFac --scale factor
	
	global oSrc --source object
	global sDis --source distance
	global svDis --current source vertex distance
	global iUnt --imaginary / custom unit
	
	global oSel --appended item
	global lArray = #()
	global cArray = #()
	
	button sp_btn_execute "execute" pos:[88,8] width:64 height:16 toolTip:"execute pending operations"
	pickbutton btn4 "PickButton" pos:[84,295] width:0 height:0
	listbox sp_listbox "" pos:[8,96] width:72 height:4
	checkbutton sp_chk_mode "local" pos:[88,72] width:64 height:16 toolTip:"scale an object vs scale all objects"
	button sp_btn_target "target" pos:[8,32] width:72 height:16 toolTip:"define target object"
	spinner sp_spn_target "" pos:[8,48] width:72 height:16 enabled:false range:[0,1.67772e+007,0] type:#float
	label sp_lbl_101 "@101craft" pos:[96,141] width:53 height:16
	button sp_btn_resetX "resetX" pos:[88,96] width:64 height:16 toolTip:"reset x-form and collapse object/s"
	button sp_btn_scale_res "zero" pos:[88,120] width:64 height:16 toolTip:"reset object/s to original scale"
	checkbutton sp_chk_tape "tape" pos:[8,8] width:72 height:16 toolTip:"account for nearby tape"
	pickbutton sp_btn_append "append list" pos:[8,72] width:72 height:16 toolTip:"add in parents"
	button sp_btn_source "source" pos:[88,32] width:64 height:16 toolTip:"define source object"
	spinner sp_spn_source "" pos:[88,48] width:64 height:16 enabled:false range:[0,1.67772e+007,0] type:#float
	
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
			   oTar.scale = oTar.scale *sFac	   
			   )
		default:
			   ()
		)
	)
	else
	(
	sFac = (tDis / sDis)*(svDis / tvDis)
	print ("------------")
	print ("scale factor:" + sFac as string)
	print ("target distance:" + tDis as string)
	print ("custom unit:" + iUnt as string)
	print ("target vert distance:" + tvDis as string)
	oTar.scale = oTar.scale * sFac
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
	    if selection.count == 1 do
	    (
			if $ != oSrc then
			(
				if ($.mesh.selectedVerts.count == 2) then
				(
				sp_spn_target.enabled = true
				sp_btn_target.text = $.name
				oTar = $
				tArr = for i in $.mesh.selectedVerts collect i.index
				t1 = tArr[1]
				t2 = tArr[2]
				tDis = sp_spn_target.value
				tvDis = distance $.mesh.verts[t1].pos $.mesh.verts[t2].pos
					if $.scale != [1,1,1] do
					(
					print("---scale mismatch---")	
					s_tvDis = $.scale.x * tvDis
					tvDis = s_tvDis
					)
				sFac = (tDis / tvDis)
				saveScale()
				)
				else
					(
						try
						(
						p = (for m in $.modifiers where ((classof m == edit_poly) OR (classof m == edit_mesh)) collect m).count
						if (classof $ != editable_poly) AND (p == 0) do addmodifier $ (edit_poly())
						)
						catch()
						messagebox("select two points in a mesh")
					)
			)
			else messagebox("select a different object")
	    )
	    if selection.count == 0 AND oTar != undefined then
		(
			try
			(
			sp_btn_target.text = "target"
			sp_spn_target.value = 0.0
			oTar = undefined
			sp_spn_target.enabled = false
			)
			catch()
		)
		else if (selection.count == 0 AND oTar == undefined) OR (selection.count > 1) do messagebox("select an object")
	)
	on sp_spn_target changed val do
	(
	print("sp_spn_target_changed")
	try(updateSpn 0)catch()
	)
	on sp_spn_target buttondown do
	(
	print("sp_spn_target_buttondown")
	try(updateSpn 0)catch()
	)
	on sp_spn_target buttonup do
	(
	print("sp_spn_target_buttonup")
	try(updateSpn 0)catch()
	)
	on sp_btn_resetX pressed do
	(
		for n = 1 to selection.count do
			(
				resetxform selection[n]
				case superclassof selection[n] of
				(
				geometryclass:
								   (
								   convertto selection[n] editable_poly
								   )
				shape:
						(
						convertto selection[n] splineshape
						)
				)
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
		case sp_chk_tape.state of
		(
		true:
			(
			)
		false:
			(
			)
		)
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
	    if selection.count == 1 do
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
				else
					(
						try
						(
						p = (for m in $.modifiers where ((classof m == edit_poly) OR (classof m == edit_mesh)) collect m).count
						if (classof $ != editable_poly) AND (p == 0) do addmodifier $ (edit_poly())
						)
						catch()
						messagebox("select two points in a mesh")
					)
			)
			else messagebox("select a different object")
	    )
	    if selection.count == 0 AND oSrc != undefined then
		(
			try
			(
			sp_btn_source.text = "source"
			sp_spn_source.value = 0.0
			oSrc = undefined
			sp_spn_source.enabled = false
			)
			catch()
		)
		else if (selection.count == 0 AND oSrc == undefined) OR selection.count > 1 do messagebox("select an object")
	)
	on sp_spn_source changed val do
	(
	print("sp_spn_source_changed")
	try(updateSpn 1)catch()
	)
	on sp_spn_source buttondown do
	(
	print("sp_spn_source_buttondown")
	try(updateSpn 1)catch()
	)
	on sp_spn_source buttonup do
	(
	print("sp_spn_source_buttonup")
	try(updateSpn 1)catch()
	)
)
createdialog spectrum
