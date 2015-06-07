-- align an object with line anchor points
-- i.e. draw a line / handrail, create another line / post, add in normal spl on top of handrail modifier stack to even out distribution of knots, with post line selected click assign

rollout auto_rail "a-rail" width:112 height:120
(
	pickbutton btn_pick_line "select path" pos:[16,32] width:80 height:24 toolTip:"select item"
	button btn_assign "confirm" pos:[16,64] width:80 height:24 toolTip:"distribute items"
	label lbl_top "auto-rail" pos:[35,8] width:42 height:16
	label lbl_bottom "@101craft" pos:[31,100] width:56 height:16
	on btn_pick_line picked oPath do
	(
		if classof oPath == line then 
		(
		btn_pick_line.text = oPath.name
		global sPath = oPath
		print (sPath)
		)
		else messagebox ("select line")	
	)
	on btn_assign pressed do
	(
	nTimes = (numknots sPath) - selection.count
	sPost = $ as array
	iPost = #()
	if nTimes > 0 do for i = 1 to nTimes do
	(
	nPost = instance $[1]
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
