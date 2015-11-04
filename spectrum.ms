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
global tDis = 0.0 --target distance
global tvDis = 0.0 --current target vertex distance
global fac = 0.0 --scale factor

global oSrc = undefined --source object
global sDis = 0.0 --source distance
global svDis = 0.0 --current source vertex distance
global unt = 0.0 --imaginary / custom unit

global oTape --selected tape

global lArray = #()
global cArray = #()
global nArray = #()

global ready = false
global c = 1

obj = objects

fn markSpinner spn =
(
	try
	(
		if spn.enabled == true do
		(
		spnArr = #()
		if oTar != undefined do append spnArr tvDis
		if oSrc != undefined do append spnArr svDis
		append spnArr 0.0
		spn.value = spnArr[c]
		c += 1
		if c > spnArr.count do c = 1
		)
	)
	catch()
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

fn saveScale arr =
(
	for a = 1 to arr.count do
	(
		if getuserprop arr[a] "oScale_x" == undefined do
		(
		setuserprop arr[a] "oScale_x" arr[a].scale.x
		setuserprop arr[a] "oScale_y" arr[a].scale.y
		setuserprop arr[a] "oScale_z" arr[a].scale.z
		)
	)
)

fn updateTape tar =
(
	managePoly tar 0
	vArr = #() --(v)ertex array
	mArr = #() --tape / (m)easure array
	vArr = for t in tar.verts collect t.index
	mArr = for o in objects where classof o == tape collect o
	
	if tar == oTar OR tar == oSrc then
	(
		if mArr.count > 0 then
		(
			for v = 1 to vArr.count do 
			(
				for m = 1 to mArr.count do 
				(
					if tar.verts[v].pos == mArr[m].pos do 
					(
					oTape = mArr[m]
					nVal = distance oTape oTape.target
					
						if tar == oTar then
						(
						tvDis = nVal
						spectrum.sp_spn_target.value = tvDis
						markSpinner sp_spn_target
						nPrefix = "tar:"
						)
						else if tar == oSrc then 
						(
						svDis = nVal
						spectrum.sp_spn_source.value = svDis
						markSpinner sp_spn_source
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

fn updateSpn spn tar dis arr v1 v2 vdis =
(
		if (spn == 0 AND spectrum.sp_spn_target.enabled == true) OR (spn == 1 AND spectrum.sp_spn_source.enabled == true) do
		(
			try
			(
				if superclassof tar == geometryclass then
				(
				arr = for i in tar.mesh.selectedVerts collect i.index
				v1 = arr[1]
				v2 = arr[2]
				vdis = distance tar.mesh.verts[v1].pos tar.mesh.verts[v2].pos
				)
				else if superclassof tar == shape then
				(
				arr = getKnotSelection tar 1
				v1 = getKnotPoint tar 1 arr[1]
				v2 = getKnotPoint tar 1 arr[2]
				vdis = distance v1 v2
				)
				
				if tar.scale != [1,1,1] do
				(
				s_vdis = undefined
				s_vdis = tar.scale.x * vdis
				vdis = s_vdis
				)
				--target
				if spn == 0 do (oTar = tar; tDis = dis; fac = (dis / vdis); tvDis = vdis)
				--source
				if spn == 1 do (oSrc = tar; sDis = dis; unt = (vdis / dis); svDis = vdis)
			)
			catch()
		)
)

fn executeGlobal mode tar =
(
	for o = 1 to tar.count do
	(
	  for l = 1 to lArray.count do
	  (
		  if findItem lArray tar[l] == 0 do
		  (
		  if rootParent tar[o] != lArray[l] AND findItem lArray tar[o] == 0 AND tar[o] != oSrc do (appendifunique cArray tar[o])
		  )
	  )
	)
	nArray = #()
	nArray = join cArray lArray
	saveScale nArray
	for n = 1 to nArray.count do 
	(
	if mode == 0 do scaleReset n nArray
	if mode == 1 do nArray[n].scale = nArray[n].scale * fac
	)
)

fn scaleReset a arr = 
(
	if (getuserprop arr[a] "oScale_x") != undefined then 
	(
		arr[a].scale.x = (getuserprop arr[a] "oScale_x") as float
		arr[a].scale.y = (getuserprop arr[a] "oScale_y") as float
		arr[a].scale.z = (getuserprop arr[a] "oScale_z") as float
	)
	else arr[a].scale = [1,1,1]
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
		updateSpn 0 oTar spectrum.sp_spn_target.value tArr t1 t2 tvDis
		updateSpn 1 oSrc spectrum.sp_spn_source.value sArr s1 s2 svDis
		if oSrc != undefined do fac = (tDis / sDis) * (svDis / tvDis)

		--global vs local
		case sp_chk_mode.state of
		(
		true:
			  (
			  executeGlobal 1 obj
			  )
		false:
			   (
			   if fac != 0.0 AND lfac != fac do oTar.scale = oTar.scale * fac      
			   )
		default:
			   (
				print("execute_default")
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
				try(updateSpn 0 $ tDis tArr t1 t2 tvDis)catch()
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
	try(updateSpn 0 oTar spectrum.sp_spn_target.value tArr t1 t2 tvDis)catch()
	)
	on sp_spn_target buttondown do
	(
	--print("sp_spn_target_buttondown")
	try(updateSpn 0 oTar spectrum.sp_spn_target.value tArr t1 t2 tvDis)catch()
	)
	on sp_spn_target buttonup do
	(
	--print("sp_spn_target_buttonup")
	try(updateSpn 0 oTar spectrum.sp_spn_target.value tArr t1 t2 tvDis)catch()
	)
	on sp_btn_target_rst pressed do
	(
		try
		(
		updateSpn 0 oTar spectrum.sp_spn_target.value tArr t1 t2 tvDis
		markSpinner sp_spn_target
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
		if sp_chk_mode.state == true then sel = objects
			else if sp_chk_mode.state == false then sel = selection
		for n = 1 to sel.count do 
		(
			scaleReset n sel
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
				try(updateSpn 1 $ spectrum.sp_spn_source.value sArr s1 s2 svDis)catch()
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
	try(updateSpn 1 oSrc spectrum.sp_spn_source.value sArr s1 s2 svDis)catch()
	)
	on sp_spn_source buttondown do
	(
	--print("sp_spn_source_buttondown")
	try(updateSpn 1 oSrc spectrum.sp_spn_source.value sArr s1 s2 svDis)catch()
	)
	on sp_spn_source buttonup do
	(
	--print("sp_spn_source_buttonup")
	try(updateSpn 1 oSrc spectrum.sp_spn_source.value sArr s1 s2 svDis)catch()
	)
	on sp_btn_source_rst pressed do
	(
		try
		(
		updateSpn 1 oSrc spectrum.sp_spn_source.value sArr s1 s2 svDis
		markSpinner sp_spn_source
		)catch()
	)
)
createdialog spectrum
