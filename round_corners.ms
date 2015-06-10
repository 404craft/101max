-- adjust round corners scene-wide
-- iterate through multi/sub-object material list
-- limited functionality plugin

rVal = 0.0

fn manageMaterial n rndVar =
(
	-- multiply by Material ID Channel Value i.e. 1 - rough, 7 - soft, 15 - very soft
	rndVar = rndVar * n.effectschannel
	
	if n.effectsChannel != 0 do
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

rollout softMat "softMat" width:96 height:136
(
	label lbl_top "softMat" pos:[27,8] width:40 height:15
	button btn_apply "apply" pos:[8,64] width:80 height:38 toolTip:"apply round corners globally"
	label lbl_bottom "@101craft" pos:[22,114] width:54 height:16
	spinner btn_spn "" pos:[16,32] width:64 height:16 range:[0,10,0] scale:0.01
	
	
	on btn_apply pressed do
	(
		for m in scenematerials where m != undefined do
		(
		if classof m == multimaterial do for l = 1 to m.materiallist.count do manageMaterial m[l] rVal
		manageMaterial m rVal
		)
	)
	on btn_spn changed val do
	(
	rVal = btn_spn.value
	)
	on btn_spn buttondown do
	(
	rVal = btn_spn.value
	)
	on btn_spn buttonup do
	(
	rVal = btn_spn.value
	)
)
createdialog softMat
