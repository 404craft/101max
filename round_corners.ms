-- adjust round corners scene-wide
-- iterate through multi/sub-object material list
-- limited functionality plugin

global rVal
global aMod

fn manageMaterial n rndVar =
(
	-- multiply by Material ID Channel Value i.e. 1 - rough, 7 - soft, 15 - very soft
	if aMod == true do rndVar = rndVar * n.effectschannel
	if rndVar != 0 do
	(
		case classof n of
		(
			autodesk_material: 
			(
				n.Round_Corners_Enable = on
				n.round_corners_source = rndVar
			)
			
			arch___design__mi:
			(
				n.opts_round_corners_on = on
				n.opts_round_corners_radius = rndVar
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

rollout softMat "softMat" width:96 height:128
(
	label sm_lbl_top "softMat" pos:[27,8] width:40 height:15
	button sm_btn_apply "apply" pos:[8,80] width:80 height:16 toolTip:"apply round corners globally"
	label sm_lbl_bottom "@101craft" pos:[22,106] width:54 height:16
	spinner sm_spn_val "" pos:[16,32] width:64 height:16 range:[0,10,0] scale:0.01
	checkbutton sm_chk_mode "mode" pos:[8,56] width:80 height:16
	
	
	on sm_btn_apply pressed do
	(
		rVal = sm_spn_val.value
		for m in scenematerials where m != undefined do
		(
		if classof m == multimaterial do for l = 1 to m.materiallist.count do manageMaterial m[l] rVal
		manageMaterial m rVal
		)
	)
	on sm_spn_val changed val do
	(
	rVal = sm_spn_val.value
	)
	on sm_spn_val buttondown do
	(
	rVal = sm_spn_val.value
	)
	on sm_spn_val buttonup do
	(
	rVal = sm_spn_val.value
	)
	on sm_chk_mode changed state do
	(
		if state == true then 
		(
		sm_chk_mode.text = "mat ID on"
		aMod = true
		)
		else
		(
		sm_chk_mode.text = "mat ID off"
		aMod = false
		)
	)
)
createdialog softMat
