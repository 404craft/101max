-- aligns an object with line anchor points
-- useful for making handrails with splines for instance
-- instructions: draw the main line - handrail,
   create another line - post,
   add in "normalize spl" to the handrail modifier stack to even out the distribution of knots, 
   or use /divide/ function to create additional anchor points,
   with post selected click assign to distribute along knots
-- limited functionality plugin

rollout auto_rail "a-rail" width:88 height:177
(
	pickbutton ar_pic_path "select path" pos:[8,24] width:72 height:16 toolTip:"select item"
	button ar_btn_assign "confirm" pos:[8,136] width:72 height:16 toolTip:"distribute items"
	label ar_lbl_top "auto-rail" pos:[24,5] width:42 height:16
	label ar_lbl_bottom "@101craft" pos:[18,157] width:56 height:16
	button ar_btn_normal "normalize" pos:[8,80] width:72 height:16
	spinner ar_spn_normal "" pos:[16,104] width:56 height:16 range:[1,100,20] type:#float
	button ar_btn_section "section" pos:[8,48] width:72 height:16
	on ar_pic_path picked oPath do
	(
		if classof oPath == line OR classof oPath == SplineShape then 
		(
		ar_pic_path.text = oPath.name
		try(ar_spn_normal.value = ar_pic_path.object.rail_normalize.length)catch()
		)
		else messagebox ("select line")	
	)
	on ar_btn_assign pressed do
	(
	nTimes = (numknots ar_pic_path.object) - selection.count
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
	for n = 1 to (numknots ar_pic_path.object) do for t = 1 to selection.count do selection[n].pos = getKnotPoint ar_pic_path.object 1 n
	sPost = undefined
	iPost = undefined
	nPost = undefined
	)
	on ar_btn_normal pressed do
	(
		if ar_pic_path.object != undefined then
		(
		if (for m in ar_pic_path.object.modifiers where classof m == normalize_spl collect m).count == 0 do
		(
		addmodifier ar_pic_path.object (normalize_spl length:ar_spn_normal.value name: "rail_normalize")
		)
		)
		else messagebox ("select path")
	)
	on ar_spn_normal changed val do
	(
	try (ar_pic_path.object.rail_normalize.length = val) catch()
	)
	on ar_spn_normal buttondown  do
	(
	try (ar_pic_path.object.rail_normalize.length = val) catch()
	)
	on ar_spn_normal buttonup  do
	(
	try (ar_pic_path.object.rail_normalize.length = val) catch()
	)
	on ar_btn_section pressed do
	(
		messagebox("under development")
	)
)
createdialog auto_rail
