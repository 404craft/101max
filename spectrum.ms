-- compute distance between two anchors in an object (i.e. the object is not to scale)
-- define target distance / real measurements of the object
-- rescale the object locally or rescale entire scene
-- use imaginary units instead of scene units

/*
for i = 1 to 3 do
(
r = random 10.0 20.0
p = random 10 50
box pos: (random [-p,-p,-p] [p,p,p]) length:r width:r height:r wirecolor: yellow
)
*/

try(destroydialog ::spectrum)catch()

global oTar = undefined --target object
global tDis --target distance
global tvDis --current target vertex distance
global sFac --scale factor

global oSrc = undefined --source object
global sDis --source distance
global svDis --current source vertex distance
global iUnt --imaginary / custom unit
global oTape --selected tape

global lArray = #()
global cArray = #()
global nArray = #()

global ready = false

obj = objects
i = 1

fn markSpinner spn n =
(
	if spn.enabled == true do
	(
	spnArr = #()
	spnArr[1] = #(0.0,tvDis)
	spnArr[2] = #(0.0,svDis)
	spn.value = spnArr[n][i]
	i += 1
	if i > spnArr[n].count do i = 1
	)
)

fn managePoly tar sub =
(
	if superclassof tar == geometryclass then
	(
	p = (for t in tar.modifiers where ((classof t == edit_poly) OR (classof t == edit_mesh)) collect t).count
	if (classof tar != editable_poly) AND (p == 0) do addmodifier tar (edit_poly())
	)
	else if superclassof tar == shape then
	(
	if (classof tar != line) AND (classof tar != splineshape) then 
		(
		convertToSplineShape tar
		ready = true
		)
	else ready = true
	)
	try(subobjectLevel = sub)catch()
)

fn rootParent node = 
(
	if isvalidnode node do 
	(
	while node.parent != undefined do node = node.parent
	node
	)
)

fn saveScale tar =
(
	for t = 1 to tar.count do
	(
		if getuserprop tar[t] "oScale_x" == undefined do
		(
		setuserprop tar[t] "oScale_x" tar[t].scale.x
		setuserprop tar[t] "oScale_y" tar[t].scale.y
		setuserprop tar[t] "oScale_z" tar[t].scale.z
		)
	)
)

fn updateTape nTar =
(
	managePoly nTar 0
	vArr = #()
	tArr = #()
	vArr = for i in nTar.verts collect i.index
	tArr = for o in objects where classof o == tape collect o
	
	if nTar == oTar OR nTar == oSrc then
	(
		if tArr.count > 0 then
		(
			for n = 1 to vArr.count do 
			(
				for t = 1 to tArr.count do 
				(
					if nTar.verts[n].pos == tArr[t].pos do 
					(
					oTape = tArr[t]
					nVal = distance oTape oTape.target
					
						if nTar == oTar then
						(
						tvDis = nVal
						spectrum.sp_spn_target.value = tvDis
						nPrefix = "tar:"
						)
						else if nTar == oSrc then 
						(
						svDis = nVal
						spectrum.sp_spn_target.value = svDis
						nPrefix = "src:"
						)
					spectrum.sp_btn_tape.text = nPrefix + oTape.name
					)
				)
			)
		)
		else messagebox("create tape between object's anchor points")
	)
	else messagebox("select target or source objects")
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
				
				if superclassof oTar == geometryclass then
				(
				tArr = for i in $.mesh.selectedVerts collect i.index
				t1 = tArr[1]
				t2 = tArr[2]
				tvDis = distance $.mesh.verts[t1].pos $.mesh.verts[t2].pos
				)
				else if superclassof oTar == shape then
				(
				tArr = getKnotSelection $ 1
				t1 = getKnotPoint $ 1 tArr[1]
				t2 = getKnotPoint $ 1 tArr[2]
				tvDis = distance t1 t2
				)
				
				if $.scale != [1,1,1] do
				(
				/* print ("---target scale out---")	 */
				s_tvDis = undefined
				s_tvDis = $.scale.x * tvDis
				tvDis = s_tvDis
				)
				
				sFac = (tDis / tvDis)
				/* print ("target distance:" + tDis as string)
				print ("target vert distance:" + tvDis as string)
				print ("scale factor:" + sFac as string) */
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
				
				if superclassof oSrc == geometryclass then
				(
				sArr = for i in $.mesh.selectedVerts collect i.index
				s1 = sArr[1]
				s2 = sArr[2]
				svDis = distance $.mesh.verts[s1].pos $.mesh.verts[s2].pos
				)
				else if superclassof oSrc == shape then
				(
				sArr = getKnotSelection $ 1
				s1 = getKnotPoint $ 1 sArr[1]
				s2 = getKnotPoint $ 1 sArr[2]
				svDis = distance s1 s2
				)
				
				if $.scale != [1,1,1] do
				(
				/* print("---source scale out---") */	
				s_svDis = undefined
				s_svDis = $.scale.x * svDis
				svDis = s_svDis
				)
				iUnt = (svDis / sDis)
				/* print ("source distance:" + sDis as string)
				print ("source vert distance:" + svDis as string)
				print ("custom unit:" + iUnt as string) */
			)
			catch()
		)
	)
)

rollout spectrum "" width:160 height:161
(
	button sp_btn_execute "execute" pos:[88,120] width:64 height:16 toolTip:"execute pending operations"
	listbox sp_listbox "" pos:[8,96] width:72 height:4
	checkbutton sp_chk_mode "local" pos:[88,72] width:64 height:16 toolTip:"scale an object vs scale all objects"
	button sp_btn_target "target" pos:[8,32] width:56 height:16 toolTip:"define target object"
	spinner sp_spn_target "" pos:[8,48] width:72 height:16 enabled:false range:[0,1.67772e+007,0] type:#float
	label sp_lbl_101 "@101craft" pos:[96,141] width:53 height:16
	button sp_btn_resetX "resetX" pos:[88,96] width:64 height:16 toolTip:"reset x-form and collapse"
	button sp_btn_scale_res "zero" pos:[88,8] width:64 height:16 toolTip:"reset to original scale"
	button sp_btn_tape "tape" pos:[8,8] width:72 height:16 toolTip:"assign nearby tape"
	pickbutton sp_btn_append "add obj" pos:[8,72] width:72 height:16 message:"" toolTip:"add in parents"
	button sp_btn_source "source" pos:[88,32] width:48 height:16 toolTip:"define source object"
	spinner sp_spn_source "" pos:[88,48] width:64 height:16 enabled:false range:[0,1.67772e+007,0] type:#float
	button sp_btn_target_rst "•" pos:[64,32] width:16 height:16 toolTip:"reset target spinner"
	button sp_btn_source_rst "•" pos:[136,32] width:16 height:16 toolTip:"reset source spinner"
	
	on sp_btn_execute pressed do
	(
	if oTar != undefined then
	(
		if oSrc != undefined do sFac = (tDis / sDis) * (svDis / tvDis)
		/* print ("------------")
		print ("scale factor:" + sFac as string)
		print ("target distance:" + tDis as string)
		print ("custom unit:" + iUnt as string)
		print ("target vert distance:" + tvDis as string) */
			
		--global vs local
		case sp_chk_mode.state of
		(
		true:
			  (
				  for o = 1 to obj.count do
				  (
					  for l = 1 to lArray.count do
					  (
						  if findItem lArray obj[l] == 0 do
						  (
						  if rootParent obj[o] != lArray[l] AND findItem lArray obj[o] == 0 AND obj[o] != oSrc do (appendifunique cArray obj[o])
						  )
					  )
				  )
				  --nArray = undefined
				  nArray = join cArray lArray
				  saveScale nArray
				  for n = 1 to nArray.count do 
				  (
				  nArray[n].scale = nArray[n].scale * sFac
				  )
			   )
		false:
			   (
			   oTar.scale = oTar.scale * sFac      
			   )
		default:
			   (
			   )
		)
	)
	else messagebox ("target undefined")
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
	    if selection.count == 1 do
	    (
			if $ != oSrc then
			(
				ready = false
				managePoly $ 1
				if (superclassof $ == geometryclass AND $.mesh.selectedVerts.count >= 2) OR (ready == true AND (getKnotSelection $ 1).count >= 2) then
				(
				sp_spn_target.enabled = true
				sp_btn_target.text = $.name
				oTar = $
				try(updateSpn 0)catch()
				)
				else
					(
						try(managePoly $ 1)catch()
						messagebox("select two anchor points")
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
	--print("sp_spn_target_changed")
	sp_spn_target.value = val
	try(updateSpn 0)catch()
	)
	on sp_spn_target buttondown do
	(
	--print("sp_spn_target_buttondown")
	try(updateSpn 0)catch()
	)
	on sp_spn_target buttonup do
	(
	--print("sp_spn_target_buttonup")
	try(updateSpn 0)catch()
	)
	on sp_btn_target_rst pressed do
	(
		try
		(
		updateSpn 0
		markSpinner sp_spn_target 1
		)catch()
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
			if (getuserprop selection[n] "oScale_x") != undefined then 
			(
				selection[n].scale.x = (getuserprop selection[n] "oScale_x") as float
				selection[n].scale.y = (getuserprop selection[n] "oScale_y") as float
				selection[n].scale.z = (getuserprop selection[n] "oScale_z") as float
			)
			else selection[n].scale = [1,1,1]
		)
	)
	
	on sp_btn_tape pressed do
	(
	updateTape $
	)
	
	on sp_btn_append picked oSel do
	(
		oCount = lArray.count
		appendifunique lArray oSel
		nCount = lArray.count
		if oCount < nCount do sp_listbox.items = append sp_listbox.items (oSel as string)
	)
	
	on sp_btn_source pressed do
	(
	    if selection.count == 1 do
	    (
			if $ != oTar then
			(
				ready = false
				managePoly $ 1
				if (superclassof $ == geometryclass AND $.mesh.selectedVerts.count >= 2) OR (ready == true AND (getKnotSelection $ 1).count >= 2) then
				(
				sp_btn_source.text = $.name
				oSrc = $
				sp_spn_source.enabled = true
				try(updateSpn 1)catch()
				)
				else
					(
						try(managePoly $ 1)catch()
						messagebox("select two anchor points")
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
	--print("sp_spn_source_changed")
	sp_spn_source.value = val
	try(updateSpn 1)catch()
	)
	on sp_spn_source buttondown do
	(
	--print("sp_spn_source_buttondown")
	try(updateSpn 1)catch()
	)
	on sp_spn_source buttonup do
	(
	--print("sp_spn_source_buttonup")
	try(updateSpn 1)catch()
	)
	on sp_btn_source_rst pressed do
	(
		try
		(
		updateSpn 1
		markSpinner sp_spn_source 2
		)catch()
	)
)
createdialog spectrum
