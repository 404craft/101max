-- manage trees en-masse in your scene
-- distribute trees along target verts
-- limited functionality plugin

tStats = #()
sTerrain = undefined
fn mSet mAtt = (for n = 1 to selection.count do selection[n].attribute)
fn select3 = select (for o in selection where classof o == foliage collect o)
select3 ()

rollout m3 "m3" width:160 height:296
(
	local targetObj = #()
	label m3_lbl_top "manage3" pos:[10,8] width:48 height:16
	button m3_btn_seed "seed" pos:[8,128] width:48 height:16 toolTip:"select foliage and assign random seed"
	button m3_btn_unique "make unique" pos:[65,8] width:88 height:16 toolTip:"select trees and make them unique"
	pickbutton m3_btn_ins_src "pick tree" pos:[8,152] width:64 height:16 toolTip:"select source tree"
	button m3_btn_ins_exe "connect" pos:[80,152] width:72 height:16 toolTip:"re-instance selected trees to source tree"
	button m3_btn_height "height" pos:[8,32] width:48 height:16 toolTip:"select foliage and assign random height"
	label m3_lbl_bottom "@101craft" pos:[98,245] width:52 height:14
	button m3_btn_dens "density" pos:[7,104] width:48 height:16 enabled:true toolTip:"select foliage and assign random density"
	button m3_btn_rotate "rotate" pos:[8,56] width:48 height:16 toolTip:"select foliage and assign random rotation"
	button m3_btn_omega "OMEGA" pos:[64,264] width:88 height:24 toolTip:"randomize everything with a single click"
	checkbutton m3_btn_show "hide" pos:[8,224] width:45 height:16 toolTip:"leaves on/off"
	pickbutton m3_btn_dis_src "pick terrain" pos:[8,176] width:64 height:16 message:"" toolTip:"select source terrain"
	button m3_btn_dis_exe "distribute" pos:[80,176] width:72 height:16 toolTip:"distribute trees along terrain"
		
	spinner m3_spn_height "" pos:[64,32] width:88 height:16 range:[0,10000,0]
	spinner m3_spn_rotate "" pos:[64,56] width:88 height:16 range:[0,359,45] type:#float
	button m3_btn_prune "prune" pos:[8,80] width:48 height:16
	spinner m3_spn_prune "" pos:[64,80] width:88 height:16 range:[-0.1,1,-0.1]
	spinner m3_spn_seed "" pos:[64,128] width:88 height:16 range:[0,16777216,0] type:#integer scale:0.1
	spinner m3_spn_dens "" pos:[64,104] width:88 height:16 range:[0,1,0]
	
	checkbox m3_show_chk_01 "Checkbox" pos:[60,228] width:8 height:8 state:true checked:true
	checkbox m3_show_chk_02 "Checkbox" pos:[76,228] width:8 height:8 state:true checked:true
	checkbox m3_show_chk_03 "Checkbox" pos:[92,228] width:8 height:8 state:true checked:true
	checkbox m3_show_chk_04 "Checkbox" pos:[108,228] width:8 height:8 state:true checked:true
	checkbox m3_show_chk_05 "Checkbox" pos:[124,228] width:8 height:8 state:true checked:true
	checkbox m3_show_chk_06 "Checkbox" pos:[140,228] width:8 height:8 state:true checked:true
	
	button m3_btn_vcm "VCM" pos:[8,248] width:48 height:16 toolTip:"viewport canopy mode"
	button m3_btn_lod "LOD" pos:[8,272] width:48 height:16 toolTip:"level-of-detail"
	spinner m3_spn_dis_dens "" pos:[80,200] width:72 height:16 range:[0,1,1]
	
	
	on m3_btn_unique pressed do -- make trees unique
	(
	select3 ()
	instancemgr.makeobjectsunique $ #individual
	)
	
	on m3_btn_ins_src picked sourceObj do -- define source tree of the new instance array
	(
	select3 ()
	m3_btn_ins_src.text = sourceObj.name
	targetObj[1] = sourceObj
	select (for o in objects where classof o == foliage collect o)
	)
	
	on m3_btn_ins_exe pressed do -- re-instance unique trees with source tree
	(
	select3 ()
	if targetObj[1] != undefined do for o in selection do o.baseobject = targetObj[1].baseobject
	)
	
	
	on m3_btn_height pressed do -- assign random height
	(
	select3 ()
	if selection.count > 1 then oHeight = $[1].height
	else oHeight = $.height
	m3_spn_height.value = oHeight
	if tStats[1] == undefined do tStats[1] = oHeight
		for n = 1 to selection.count do
		(
		selection[n].height = random (tStats[1] / 2.0) (tStats[1] * 1.5)
		m3_spn_height.value = selection[n].height
		)
	)
	on m3_spn_height changed val do
	(
	tStats[1] = m3_spn_height.value
	for n = 1 to selection.count do selection[n].height = m3_spn_height.value
	)
	
	
	on m3_btn_dens pressed do -- assign random density
	(
	select3 ()
		for n = 1 to selection.count do
		(
		selection[n].density = random 0.0 1.0
		m3_spn_dens.value = selection[n].density
		)
	)
	on m3_spn_dens changed val do
	(
	for n = 1 to selection.count do selection[n].density = m3_spn_dens.value
	)
	
	on m3_btn_seed pressed do -- assign random seed
	(
	select3 ()
		for n = 1 to selection.count do 
		(
		selection[n].seed = random 1 16777216
		m3_spn_seed.value = selection[n].seed
		)
	)
	on m3_spn_seed changed val do
	(
	oSeed = m3_spn_seed.value
	for n = 1 to selection.count do selection[n].seed = m3_spn_seed.value
	)
	on m3_spn_seed buttondown do
	(
	oSeed = m3_spn_seed.value
	)
	on m3_spn_seed buttonup do
	(
	oSeed = m3_spn_seed.value
	)
	
	
	on m3_btn_rotate pressed do -- assign random rotation
	(
	select3 ()
	for n = 1 to selection.count do rotate selection[n] (eulerangles 0 0 (random 0 m3_spn_rotate.value as integer))
	)
	
	on m3_btn_prune pressed  do
	(
		for n = 1 to selection.count do
		(
		selection[n].pruning = random -0.1 1.0
		m3_spn_prune.value = selection[n].pruning
		)
	)
	on m3_spn_prune changed val do
	(
	for n = 1 to selection.count do selection[n].pruning = m3_spn_prune.value
	)	
	
	on m3_btn_omega pressed do -- alpha & omega: hit once randomize everything
	(
	select3 ()
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
		
		rotate selection[n] (eulerangles 0 0 (random 0m3_spn_rotate.value as integer))
			
		if sTerrain != undefined do for n =1 to sTerrain.verts.count do for t = 1 to selection.count do selection[t].pos = sTerrain.verts[t].pos
		)
	)
	
	
	on m3_btn_show changed state do -- leaves switch off / on, i.e. for AO rendering
	(
	select3 ()
		if state == true then 
		(
		try($.showleaves = off
		$.showflowers = off
		$.showfruit = off)catch()
		m3_btn_show.text = "show"
		m3_show_chk_01.state = false
		m3_show_chk_02.state = false
		m3_show_chk_03.state = false
		)
		else if state == false then 
		(
		try($.showleaves = on
		$.showflowers = on
		$.showfruit = on)catch()
		m3_btn_show.text = "hide"
		m3_show_chk_01.state = true
		m3_show_chk_02.state = true
		m3_show_chk_03.state = true
		)
	)
	on m3_show_chk_01 changed state do
	(
	if state == on then try ($.showleaves = on) catch()
	else try($.showleaves = off) catch()
	)
	on m3_show_chk_02 changed state do
	(
	if state == on then try ($.showfruit = on) catch()
	else try($.showfruit = off) catch()
	)
	on m3_show_chk_03 changed state do
	(
	if state == on then try ($.showflowers = on) catch()
	else try($.showflowers = off) catch()
	)
	on m3_show_chk_04 changed state do
	(
	if state == on then try ($.showtrunk = on) catch()
	else try($.showtrunk = off) catch()	
	)
	on m3_show_chk_05 changed state do
	(
	if state == on then try ($.showbranches = on) catch()
	else try($.showbranches = off) catch()		
	)
	on m3_show_chk_06 changed state do
	(
	if state == on then try ($.showroots = on) catch()
	else try($.showroots = off) catch()			
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
		/*if (for m in sPath.modifiers where classof m == normalize_spl collect m).count == 0 do addmodifier sPath (normalize_spl ())*/
		)
		else messagebox ("select geometry")	
	)
	)
	on m3_btn_dis_exe pressed do -- distribute trees along terrain verts
	(
		if sTerrain != undefined then
		(
			if superclassof sTerrain == geometryclass then 
			(
				local gLimit = 512
				if sTerrain.verts.count < gLimit then
				(
				select3 ()
				nLimit = sTerrain.verts.count * m3_spn_dis_dens.value
				nLimit = nLimit as integer
				nTimes = nLimit - selection.count
				if nTimes < 1 then nTimes = 1
					else nTimes = nTimes as integer
				-- err
				if selection.count > 1 then sTree = $ as array
					else sTree = $
				
				iTree = #()
				if nTimes > 0 do for i = 1 to nTimes do 
				(
				-- err
				if selection.count > 1 then nTree = instance $[1]
					else nTree = instance $
				append iTree nTree -- err
				)
				select (join iTree sTree) -- err
				for n =1 to nLimit do for t = 1 to selection.count do selection[n].pos = sTerrain.verts[n].pos
				sTree = undefined
				iTree = undefined
				nTree = undefined
				)
				else messagebox ("geometry exceeds " +gLimit as string)
			)
			
			else if superclassof sTerrain == shape then
			(
			nTimes = (numknots sTerrain) - selection.count
			if selection.count > 1 then sPost = $ as array
				else sPost = $
			iPost = #()
			if nTimes > 0 do for i = 1 to nTimes do
			(
			if selection.count > 1 then nPost = instance $[1]
				else nPost = instance $
			append iPost nPost
			)
			select (join iPost sPost)
			for n = 1 to (numknots sTerrain) do for t = 1 to selection.count do selection[n].pos = getKnotPoint sTerrain 1 n
			sPost = undefined
			iPost = undefined
			nPost = undefined
			)
		)
		else messagebox ("select terrain")
	)

	on m3_btn_vcm pressed  do
	(
	if selection.count > 1 then vSwitch = $[1].CanopyMode
		else vSwitch = $.CanopyMode
	vSwitch += 1
	if vSwitch > 2 do vSwitch = 0
		for n = 1 to selection.count do
		(
		selection[n].CanopyMode = vSwitch
		)
	)
	on m3_btn_lod pressed  do
	(
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
createdialog m3
