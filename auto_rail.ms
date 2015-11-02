-- aligns an object with line anchor points
-- useful for making handrails with splines for instance
-- limited functionality plugin

try(destroydialog ::auto_rail)catch()
tar_path = undefined
iPost = #()
cPost = #()
ready = true
rollout auto_rail "a-rail" width:88 height:144
(
	pickbutton ar_pic_path "path" pos:[8,24] width:72 height:16 toolTip:"select item"
	button ar_btn_assign "confirm" pos:[16,104] width:56 height:16 toolTip:"distribute items"
	label ar_lbl_top "auto-rail" pos:[24,5] width:42 height:16
	label ar_lbl_bottom "@101craft" pos:[17,125] width:56 height:16
	spinner ar_spn_normal "" pos:[16,80] width:56 height:16 range:[1,100,2] type:#float
	checkbutton ckb_rule "divide" pos:[8,48] width:72 height:24 enabled:true checked:true

	on ar_pic_path picked oPath do
	(
		if classof oPath == line OR classof oPath == SplineShape then 
		(
		ar_pic_path.text = oPath.name
		)
		else messagebox ("select spline obj")	
	)
	on ar_btn_assign pressed do
	(
		try(delete tar_path)catch()
	)
	on ar_spn_normal changed val do
	(
		if (ready) do
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
	on ckb_rule changed state do
	(
	if state == true then (ckb_rule.text = "divide"; ar_spn_normal.value = 2.0)
	else if state == false do (ckb_rule.text = "normalize"; ar_spn_normal.value = 40.0)
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
