-- aligns an object with line anchor points
-- useful for making handrails with splines for instance
-- limited functionality plugin

try(destroydialog ::auto_rail)catch()
tar_path = undefined
iPost = #()
cPost = #()
ready = true
rollout auto_rail "a-rail" width:88 height:177
(
	pickbutton ar_pic_path "select path" pos:[8,24] width:72 height:16 toolTip:"select item"
	button ar_btn_assign "confirm" pos:[8,136] width:72 height:16 toolTip:"distribute items"
	label ar_lbl_top "auto-rail" pos:[24,5] width:42 height:16
	label ar_lbl_bottom "@101craft" pos:[18,157] width:56 height:16
	spinner ar_spn_normal "" pos:[16,104] width:56 height:16 range:[1,100,20] type:#float
	
	on ar_pic_path picked oPath do
	(
		if classof oPath == line OR classof oPath == SplineShape then 
		(
		ar_pic_path.text = oPath.name
		)
		else messagebox ("select spline obj")	
	)
	on ar_btn_assign pressed  do
	(
		distribute ar_pic_path.object
	)
	on ar_spn_normal changed val do
	(
		if (ready) do
		(
		ready = false
			try
			(
			delete tar_path
			for i in iPost do delete i
			)
			catch()
		ar_pic_path.object.wirecolor = blue
		tar_path = copy ar_pic_path.object
		addmodifier tar_path (normalize_spl length:ar_spn_normal.value name: "rail_normalize" wirecolor:yellow)
		collapseStack tar_path
		distribute tar_path
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
	for t = 1 to iPost.count do iPost[n].pos = getKnotPoint target 1 n
	)
	redrawviews()
	old_tar = target
	ready = true
)

createdialog auto_rail
