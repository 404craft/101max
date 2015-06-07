-- align an object to line anchor points

rollout distribute "distribute" width:112 height:120
(
	pickButton btn_pick_line "select path" pos:[16,32] width:80 height:24 toolTip:"select item"
	button btn_assign "confirm" pos:[16,64] width:80 height:24 toolTip:"distribute items"
	label lbl_top "distribute" pos:[34,8] width:48 height:16
	label lbl_bottom "@101craft" pos:[31,100] width:56 height:16
	on btn_pick_line picked oPath do
	(
		if classof oPath == line then 
		(
		btn_pick_line.text = oPath.name
		global sPath = btn_pick_line.value
		print (sPath)
		)
		else messagebox ("select line")	
	)
	on btn_assign pressed  do
	(
	)
)
