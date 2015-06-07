-- aligns an object with line anchor points
-- useful for making handrails with splines for instance
-- instructions: draw the main line - handrail,
   create another line - post,
   add in "normalize spl" to the handrail modifier stack to even out the distribution of knots, 
   with post selected click assign to distribute along knots

rollout auto_rail "a-rail" width:112 height:120
(
	pickbutton btn_pick_line "select path" pos:[16,32] width:80 height:24 toolTip:"select item"
	button btn_assign "confirm" pos:[16,64] width:80 height:24 toolTip:"distribute items"
	label lbl_top "auto-rail" pos:[35,8] width:42 height:16
	label lbl_bottom "@101craft" pos:[31,100] width:56 height:16
	on btn_pick_line picked oPath do
	(
		if classof oPath == line OR classof oPath == SplineShape then 
		(
		btn_pick_line.text = oPath.name
		global sPath = oPath
		print (sPath)
		/*if (for m in sPath.modifiers where classof m == normalize_spl collect m).count == 0 do*/ addmodifier sPath (normalize_spl ())
		)
		else messagebox ("select line")	
	)
	on btn_assign pressed do
	(
	nTimes = (numknots sPath) - selection.count
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
	for n = 1 to (numknots sPath) do for t = 1 to selection.count do selection[n].pos = getKnotPoint sPath 1 n
	sPost = undefined
	iPost = undefined
	nPost = undefined
	)
)
createdialog auto_rail
