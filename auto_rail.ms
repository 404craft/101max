-- aligns an object with line anchor points
-- divide segments and align vs normalize / align
-- useful for making handrails with splines for instance

try(destroydialog ::auto_rail)catch()
tar_path = undefined
iPost = #()
ready = true
rollout auto_rail "" width:88 height:145
(
	fn selShape o = isKindOf o shape
	pickbutton ar_pic_path "path" pos:[8,24] width:72 height:16 filter:selShape toolTip:"select path"
	button ar_btn_assign "confirm" pos:[24,104] width:48 height:16 toolTip:"distribute objects"
	label ar_lbl_top "auto-rail" pos:[24,5] width:42 height:16
	spinner ar_spn_normal "" pos:[16,80] width:56 height:16 range:[1,100,2] type:#float
	checkbutton ckb_rule "divide" pos:[8,48] width:72 height:24 enabled:true checked:true
	button ar_btn_del "•" pos:[8,104] width:16 height:16 toolTip:"delete objects"
	label ar_lbl_bottom "@101craft" pos:[17,125] width:56 height:16

	on ar_pic_path picked oPath do
	(
		ar_pic_path.text = oPath.name
	)
	
	on ar_btn_assign pressed do
	(
		try(delete tar_path)catch()
	)
	
	on ar_spn_normal changed val do
	(
		if (ready) AND (ar_pic_path.object != undefined) do
		(
			ready = false
			wipe()
			ar_pic_path.object.wirecolor = blue
			tar_path = copy ar_pic_path.object
			x = ar_spn_normal.value as integer
			if ckb_rule.state == true do
			(
			divide tar_path x
			)
			if ckb_rule.state == false do addmodifier tar_path (normalize_spl length:ar_spn_normal.value name: "rail_normalize" wirecolor:yellow)
			collapseStack tar_path
			distribute tar_path
		)
	)
	
	on ar_btn_del pressed do
	(
		wipe()
	)
	
	on ckb_rule changed state do
	(
		case ckb_rule.state of
		(
			true: (ckb_rule.text = "divide"; ar_spn_normal.value = 2.0)
			false: (ckb_rule.text = "normalize"; ar_spn_normal.value = 40.0)
		)
	)
)

fn distribute target =
(
	iPost = #()
	sPost = undefined
	nPost = undefined
	
	nTimes = (numknots target)
	
	if selection.count > 1 then sPost = $[1]
		else if selection.count == 1 do sPost = $
	
	for n = 1 to nTimes do
	(
	nPost = instance sPost
	append iPost nPost
	iPost[n].pos = getKnotPoint target 1 n
	)
	redrawviews()
	ready = true
)

fn divide target x =
(
	c = 1
	for s = 1 to numsplines target do
	(
		numSegs = numsegments target s
		
		for n = 1 to numSegs do
		(
			subdivideSegment target s c x
			c += (x+1)
		)
	)
)

fn wipe =
(
	try
	(
	delete tar_path
	for i in iPost do delete i
	)
	catch()
)

createdialog auto_rail
