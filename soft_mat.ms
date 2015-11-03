-- adjust round corners scene-wide
-- iterate through multi/sub-object material list
-- use material ID channel value to grade material softness
-- i.e. multiply final round corners value by Material Channel ID: 1 - rough, 7 - soft, 15 - very soft

/*
i = 0
for n = 1 to 24 do 
(
r = random 1 2
if r == 1 then mat = Arch___Design__mi()
	else if r == 2 then mat = Autodesk_Material()
mat.name = "m_" + n as string + "_" + classof mat as string
c = color (255-n*10.625 as integer) (0+n*10.625 as integer) 255 0
if r == 1 then mat.diff_color = c
	else if r == 2 then mat.Generic_Color = c
mat.effectschannel = i
i += 1
if i > 15 do i = 0
setMeditMaterial n mat
)
*/

-- for i = 1 to selection.count do selection[i].material = meditmaterials[i]

try(destroydialog ::softMat)catch()

rollout softMat "" width:96 height:177
(
	fn manageMaterial n rndVar rndVal=
	(
		if softmat.sm_chk_mode.state == true do rndVar = rndVar * (rndVal * n.effectschannel)
		-- mr mats
		if hasproperty n "Round_Corners_Enable" do
		(
		if rndVar == 0 do (n.Round_Corners_Enable = off; continue)
		n.Round_Corners_Enable = on
		n.round_corners_source = rndVar
		if softmat.sm_ckb_blend.state == true then n.round_corners_blend_with_other_materials = on
			else n.round_corners_blend_with_other_materials = off
		)

		if hasproperty n "opts_round_corners_on" do
		(
		if rndVar == 0 do (n.opts_round_corners_on = off; continue)
		n.opts_round_corners_on = on
		n.opts_round_corners_radius = rndVar
		if softmat.sm_ckb_blend.state == true then n.opts_round_corners_any_mtl = on
			else n.opts_round_corners_any_mtl = off
		)
		
		-- vray mats
		c = 0
		if classof n == vraymtl do c = 1
		if classof n == vRaycarpaintmtl do c = 2
		if c != 0 do
		(
		if c == 1 do if n.texmap_bump == undefined do n.texmap_bump = vrayedgestex ()
		if c == 2 do if n.texmap_base_bump == undefined do n.texmap_base_bump = vrayedgestex ()
		n.texmap_base_bump_on = true
		n.texmap_base_bump.widthtype = 0
		n.texmap_base_bump.thickness = rndVar
		)
	)
	
	label sm_lbl_top "softMat" pos:[27,4] width:40 height:15
	button sm_btn_apply "assign" pos:[16,136] width:64 height:16 toolTip:"apply round corners"
	label sm_lbl_bottom "@101craft" pos:[22,157] width:54 height:16
	spinner sm_spn_val "" pos:[16,48] width:56 height:16 range:[0,100,0] scale:0.01 toolTip:"round corners value"
	checkbutton sm_chk_mode "matID/off" pos:[16,88] width:64 height:16 toolTip:"use Material ID Channel value"
	spinner sm_spn_var "" pos:[16,24] width:56 height:16 range:[0.1,1,0.1] type:#float toolTip:"matID multiplier"
	checkbutton sm_ckb_blend "blend/off" pos:[16,72] width:64 height:16 toolTip:"blend with other materials"
	checkbutton sm_ckb_range "selection" pos:[16,112] width:64 height:16 toolTip:"affect selection or all materials in scene"
	button sm_btn_var_rnd "•" pos:[72,24] width:16 height:16 toolTip:"random matID multiplier"
	button sm_btn_val_rnd "•" pos:[72,48] width:16 height:16 toolTip:"random round corners value"
	
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
		sm_ckb_range.text = "selection"
		)
	)
	
	on sm_btn_var_rnd pressed do
	(
	sm_spn_var.value = random 0.1 1.0
	)
	
	on sm_btn_val_rnd pressed do
	(
	sm_spn_val.value = random 0.1 100.0
	)
)
createdialog softMat
