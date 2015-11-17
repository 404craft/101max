-- tree randomization and distribution
-- manage trees en-masse in your scene
-- distribute trees along target object's vertices
-- distribute along path i.e. country lane, forest road

try(destroydialog ::manage3)catch()

tStats = #()
sTerrain = undefined
fn mSet mAtt = (for n = 1 to selection.count do selection[n].attribute)
fn select3 = select (for o in selection where classof o == foliage collect o)
fn element3 tar =
(
	tar.showleaves = manage3.m3_show_chk_01.state
	tar.showfruit = manage3.m3_show_chk_02.state
	tar.showflowers = manage3.m3_show_chk_03.state
	tar.showtrunk = manage3.m3_show_chk_04.state
	tar.showbranches = manage3.m3_show_chk_05.state
	tar.showroots = manage3.m3_show_chk_06.state
)

fn bloom target method density = 
(
			--geometry class
			if superclassof target == geometryclass then 
			(
				local gLimit = 512
				if target.verts.count < gLimit then
				(
				select3()
				nLimit = target.verts.count * manage3.m3_spn_dis_dens.value
				nLimit = nLimit as integer
				nTimes = nLimit - selection.count
				if nTimes < 1 then nTimes = 1
					else nTimes = nTimes as integer
				if selection.count > 1 then sTree = $ as array
					else sTree = $
				
				iTree = #()
				if nTimes > 0 do for i = 1 to nTimes do 
				(
				if selection.count > 1 then nTree = instance $[1]
					else nTree = instance $
				append iTree nTree
				)
				select (join iTree sTree)
				for n =1 to nLimit do for t = 1 to selection.count do selection[n].pos = target.verts[n].pos
				sTree = undefined
				iTree = undefined
				nTree = undefined
				)
				else messagebox ("geometry exceeds " +gLimit as string)
			)
			
			--spline class
			else if superclassof target == shape then
			(
				if selection.count > 1 then sPost = $ as array
					else sPost = $
				
				--distribute along path / method 1
				if method then
				(
					span = 0.05 * (curvelength target)
				    step = (1.1 - density) / span
					
					for n = 0.0 to 1.0 by step do
					(
						pos = lengthInterp target n
						nPost = instance sPost
						nPost.pos = pos
					)
				)
				
				--distribute around vertices i.e. normalize spline first / method 2
				else if method == false do
				(
					nTimes = (numknots target) - selection.count
					iPost = #()
					if nTimes > 0 do for i = 1 to nTimes do
					(
					if selection.count > 1 then nPost = instance $[1]
						else nPost = instance $
					append iPost nPost
					)
					select (join iPost sPost)
					for n = 1 to (numknots target) do for t = 1 to selection.count do selection[n].pos = getKnotPoint target 1 n
					sPost = undefined
					iPost = undefined
					nPost = undefined
				)
			)
)
select3()

rollout manage3 "" width:112 height:232
(
	local targetObj = #()
	
	button m3_btn_seed "seed" pos:[8,88] width:40 height:16 toolTip:"assign random seed"
	button m3_btn_unique "differ" pos:[56,112] width:48 height:16 toolTip:"make trees unique to each other"
	pickbutton m3_btn_ins_src "tree" pos:[8,176] width:48 height:16 toolTip:"select source tree"
	button m3_btn_ins_exe "stem" pos:[8,112] width:48 height:16 toolTip:"re-instance selected trees with source tree"
	button m3_btn_height "height" pos:[8,24] width:40 height:16 toolTip:"assign random height"
	label m3_lbl_bottom "look@101craft.com" pos:[11,6] width:96 height:14
	button m3_btn_dens "density" pos:[8,72] width:40 height:16 enabled:true toolTip:"assign random density"
	button m3_btn_rotate "rotate" pos:[8,40] width:40 height:16 toolTip:"assign random rotation"
	button m3_btn_omega "bloom" pos:[32,200] width:72 height:24 toolTip:"randomize everything with a single click"
	pickbutton m3_btn_dis_src "terrain" pos:[8,160] width:48 height:16 message:"" toolTip:"select source terrain"
	button m3_btn_dis_exe "plant" pos:[56,176] width:40 height:16 toolTip:"distribute trees along terrain"
		
	spinner m3_spn_height "" pos:[48,24] width:56 height:16 range:[0,10000,0]
	spinner m3_spn_rotate "" pos:[48,40] width:56 height:16 range:[0,359,45]
	button m3_btn_prune "prune" pos:[8,56] width:40 height:16
	spinner m3_spn_prune "" pos:[48,56] width:56 height:16 range:[-0.1,1,-0.1]
	spinner m3_spn_seed "" pos:[48,88] width:56 height:16 range:[0,1.67772e+007,0] type:#integer scale:0.1
	spinner m3_spn_dens "" pos:[48,72] width:56 height:16 range:[0,1,0]
	
	checkbutton m3_show_chk_01 "" pos:[8,136] width:16 height:16 checked:true state:true toolTip:"leaves"
	checkbutton m3_show_chk_02 "" pos:[24,136] width:16 height:16 checked:true state:true toolTip:"fruit"
	checkbutton m3_show_chk_03 "" pos:[40,136] width:16 height:16 checked:true state:true toolTip:"flowers"
	checkbutton m3_show_chk_04 "" pos:[56,136] width:16 height:16 checked:true state:true toolTip:"trunk"
	checkbutton m3_show_chk_05 "" pos:[72,136] width:16 height:16 checked:true state:true toolTip:"branches"
	checkbutton m3_show_chk_06 "" pos:[88,136] width:16 height:16 checked:true state:true toolTip:"roots"
	
	button m3_btn_vcm "" pos:[16,200] width:16 height:24 toolTip:"viewport canopy mode"
	button m3_btn_lod "" pos:[8,200] width:8 height:24 toolTip:"level-of-detail"
	checkbutton m3_ckb_dis_method "" pos:[96,176] width:8 height:16 toolTip:"type of distribution" checked:true state:true
	spinner m3_spn_dis_dens "" pos:[56,160] width:48 height:16 range:[0,1,1]

	on m3_btn_seed pressed do -- assign random seed
	(
	select3()
		for n = 1 to selection.count do 
		(
		selection[n].seed = random 1 16777216
		m3_spn_seed.value = selection[n].seed
		)
	)
	on m3_btn_unique pressed do -- make trees unique
	(
	select3()
	instancemgr.makeobjectsunique $ #individual
	)
	on m3_btn_ins_src picked sourceObj do -- define source tree of the new instance array
	(
	select3()
	m3_btn_ins_src.text = sourceObj.name
	targetObj[1] = sourceObj
	select (for o in objects where classof o == foliage collect o)
		
	m3_spn_height.value = sourceObj.height
	m3_spn_dens.value = sourceObj.density
	m3_spn_prune.value = sourceObj.pruning
	m3_spn_seed.value = sourceObj.seed
	m3_spn_rotate.value = sourceObj.rotation.z		
	)
	on m3_btn_ins_exe pressed do -- re-instance unique trees with source tree
	(
	select3()
	if targetObj[1] != undefined do for o in selection do o.baseobject = targetObj[1].baseobject
	)
	on m3_btn_height pressed do -- assign random height
	(
	select3()
	if selection.count > 1 then m3_spn_height.value = $[1].height
	else m3_spn_height.value = $.height
	if tStats[1] == undefined do tStats[1] = m3_spn_height.value
		for n = 1 to selection.count do
		(
		selection[n].height = random (tStats[1] / 2.0) (tStats[1] * 1.5)
		m3_spn_height.value = selection[n].height
		)
	)
	on m3_btn_dens pressed do -- assign random density
	(
	select3()
		for n = 1 to selection.count do
		(
		selection[n].density = random 0.0 1.0
		m3_spn_dens.value = selection[n].density
		)
	)
	on m3_btn_rotate pressed do -- assign random rotation
	(
	select3()
	for n = 1 to selection.count do rotate selection[n] (eulerangles 0 0 (random 0 m3_spn_rotate.value as integer))
	)
	on m3_btn_omega pressed do -- alpha & omega: hit once randomize everything
	(
	select3()
		for n = 1 to selection.count do 
		(
		instancemgr.makeobjectsunique $ #individual
	
		if selection.count > 1 then oHeight = $[1].height
		else oHeight = $.height
		
		if tStats[1] == undefined do tStats[1] = oHeight
		selection[n].height = random (tStats[1] / 2.0) (tStats[1] * 1.5)
	
		selection[n].density = random 0.0 1.0
		m3_spn_dens.value = selection[n].density
		
		selection[n].seed = random 1 16777216
		m3_spn_seed.value = selection[n].seed
		
		rotate selection[n] (eulerangles 0 0 (random 0 m3_spn_rotate.value as integer))
		)
	)
	on m3_btn_dis_src picked sourceTerrain do -- pick source terrain i.e. environment geometry
	(
	global sTerrain
	if superclassof sourceTerrain == geometryclass then 
	(
		if classof sourceTerrain != editable_poly do 
		(
		resetxform sourceTerrain
		convertto sourceTerrain editable_poly
		)
	m3_btn_dis_src.text = sourceTerrain.name
	sTerrain = sourceTerrain
	)
	else
	(
		if classof sourceTerrain == line OR classof sourceTerrain == splineshape then 
		(
		m3_btn_dis_src.text = sourceTerrain.name
		sTerrain = sourceTerrain
		)
		else messagebox ("select geometry")	
	)
	)
	on m3_btn_dis_exe pressed do -- distribute trees along terrain verts
	(
		if sTerrain != undefined then
		(
			bloom sTerrain m3_ckb_dis_method.state m3_spn_dis_dens.value
		)
		else messagebox ("select terrain")
	)
	on m3_spn_height changed val do
	(
	select3()
	tStats[1] = m3_spn_height.value
	for n = 1 to selection.count do selection[n].height = m3_spn_height.value
	)
	on m3_btn_prune pressed do
	(
	select3()
		for n = 1 to selection.count do
		(
		selection[n].pruning = random -0.1 1.0
		m3_spn_prune.value = selection[n].pruning
		)
	)
	on m3_spn_prune changed val do
	(
	select3()
	for n = 1 to selection.count do selection[n].pruning = m3_spn_prune.value
	)
	on m3_spn_seed changed val do
	(
	select3()
	for n = 1 to selection.count do selection[n].seed = m3_spn_seed.value
	)
	on m3_spn_dens changed val do
	(
	select3()
	for n = 1 to selection.count do selection[n].density = m3_spn_dens.value
	)
	on m3_show_chk_01 changed state do
	(
		select3()
		element3 $
	)
	on m3_show_chk_02 changed state do
	(
		select3()
		element3 $
	)
	on m3_show_chk_03 changed state do
	(
		select3()
		element3 $
	)
	on m3_show_chk_04 changed state do
	(
		select3()
		element3 $
	)
	on m3_show_chk_05 changed state do
	(
		select3()
		element3 $	
	)
	on m3_show_chk_06 changed state do
	(
		select3()
		element3 $		
	)
	on m3_btn_vcm pressed do
	(
	select3()
	if selection.count > 1 then vSwitch = $[1].CanopyMode
		else vSwitch = $.CanopyMode
	vSwitch += 1
	if vSwitch > 2 do vSwitch = 0
		for n = 1 to selection.count do
		(
		selection[n].CanopyMode = vSwitch
		)
	)
	on m3_btn_lod pressed do
	(
	select3()
		if selection.count > 1 then lSwitch = $[1].LevelOfDetail
		else lSwitch = $.LevelOfDetail
	lSwitch += 1
	if lSwitch > 2 do lSwitch = 0
		for n = 1 to selection.count do
		(
		selection[n].LevelOfDetail = lSwitch
		)
	)
)
createdialog manage3
