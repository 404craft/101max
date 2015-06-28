-- adjust round corners scene-wide
-- iterate through multi/sub-object material list
-- use material ID channel value to grade material softness
-- limited functionality plugin

try(destroydialog ::softMat)catch()

rollout softMat "" width:96 height:176
(
	fn manageMaterial n rndVar rndVal=
	(
		-- multiply by Material ID Channel Value i.e. 1 - rough, 7 - soft, 15 - very soft
		if softmat.sm_chk_mode.state == true do rndVar = rndVar * (rndVal * n.effectschannel)
		if rndVar != 0 do
		(
			case classof n of
			(
				autodesk_material: 
				(
					n.Round_Corners_Enable = on
					n.round_corners_source = rndVar
					if softmat.sm_ckb_blend.state == true then n.round_corners_blend_with_other_materials = on
						else n.round_corners_blend_with_other_materials = off
				)
				
				arch___design__mi:
				(
					n.opts_round_corners_on = on
					n.opts_round_corners_radius = rndVar
					if softmat.sm_ckb_blend.state == true then n.opts_round_corners_any_mtl = on
						else n.opts_round_corners_any_mtl = off
				)
				
				vraymtl:
				(
					if n.texmap_bump == undefined do n.texmap_bump = vrayedgestex ()
					n.texmap_base_bump_on = true
					n.texmap_bump.widthtype = 0
					n.texmap_bump.thickness = rndVar
				)
		
				vRaycarpaintmtl:
				(
					if n.texmap_base_bump == undefined do n.texmap_base_bump = vrayedgestex ()
					n.texmap_base_bump_on = true
					n.texmap_base_bump.widthtype = 0
					n.texmap_base_bump.thickness = rndVar
				)
				
				default: print ("invalid")
			)
		)
	)
	
	label sm_lbl_top "softMat" pos:[27,4] width:40 height:15
	button sm_btn_apply "assign" pos:[16,136] width:64 height:16 toolTip:"apply round corners"
	label sm_lbl_bottom "@101craft" pos:[22,157] width:54 height:16
	spinner sm_spn_val "" pos:[16,48] width:64 height:16 range:[0,10,0] scale:0.01 toolTip:"round corners value"
	checkbutton sm_chk_mode "matID/off" pos:[16,88] width:64 height:16 toolTip:"use Material ID Channel value"
	spinner sm_spn_var "" pos:[16,32] width:64 height:16 range:[0.1,1,0.1] type:#float toolTip:"matID multiplier"
	
	checkbutton sm_ckb_blend "blend/off" pos:[16,72] width:64 height:16 toolTip:"blend with other materials"
	checkbutton sm_ckb_range "local" pos:[16,112] width:64 height:16 toolTip:"affect selection or all materials in scene"
	on sm_btn_apply pressed do
	(
		if sm_ckb_range.state == true then mRng = scenematerials
			else mRng = selection
		for m in mRng do
		(
		if sm_ckb_range.state == false do m = m.material
			if (sm_ckb_range.state == true) OR (sm_ckb_range.state == false AND mRng.count > 0) do
			(
				if classof m == multimaterial do for l = 1 to m.materiallist.count do manageMaterial m[l] softmat.sm_spn_val.value
				manageMaterial m softmat.sm_spn_val.value softmat.sm_spn_var.value
				if sm_ckb_range.state == false do m = undefined
			)
		)
	)
	on sm_chk_mode changed state do
	(
		if state == true then 
		(
		sm_chk_mode.text = "matID/on"
		)
		else
		(
		sm_chk_mode.text = "matID/off"
		)
	)
	on sm_ckb_blend changed state do
	(
		if state == true then 
		(
		sm_ckb_blend.text = "blend/on"
		)
		else
		(
		sm_ckb_blend.text = "blend/off"
		)
	)
	on sm_ckb_range changed state do
	(
		if state == true then 
		(
		sm_ckb_range.text = "global"
		)
		else
		(
		sm_ckb_range.text = "local"
		)
	)
)
createdialog softMat
