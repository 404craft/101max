--new plugin under development
--procudural fantasy town generator for Water-Home models
--https://www.cgtrader.com/3d-models/architectural-exterior/house/water-home

try(destroydialog :: castleGen)catch()

rollout castleGen "" width:136 height:296
(
	
	fn rootParent node = 
	(
		if isvalidnode node do 
		(
		while node.parent != undefined do node = node.parent
		node
		)
	)
		
	pickbutton btn1 "platform" pos:[8,8] width:120 height:24
	pickbutton btn2 "1/ module" pos:[8,32] width:120 height:24
	pickbutton btn3 "2/ module " pos:[8,56] width:120 height:24
	pickbutton btn4 "crate" pos:[8,80] width:120 height:24
	button btn5 "create" pos:[8,264] width:120 height:24
	spinner spn1 "" pos:[8,112] width:56 height:16 range:[0,100,1] type:#integer
	spinner spn2 "" pos:[72,112] width:56 height:16 range:[0,100,1] type:#integer

	on btn1 picked obj do
	(
	obj = rootParent obj
	btn1.text = obj.name
	)
	
	on btn2 picked obj do
	(
	obj = rootParent obj
	btn2.text = obj.name
	)
	
	on btn3 picked obj do
	(
	obj = rootParent obj
	btn3.text = obj.name
	)
	
	on btn4 picked obj do
	(
	--obj = rootParent obj
	btn4.text = obj.name
	)
	
	on btn5 pressed do
	(
	offsetX = 1000
	offsetY = 1000
	maxOps.cloneNodes btn1.object cloneType:#instance newNodes:&platform offset:[-offsetX,-offsetY,0]
	platform = rootParent platform[1]
		
	r = random 0 99
	case of 
	(
		(r < 25):
		(
			for n = 1 to spn2.value do
			(
				maxOps.cloneNodes btn2.object cloneType:#instance newNodes:&level
				level = rootParent level[1]
				level.pos.x = platform.pos.x + 103.31
				level.pos.y = platform.pos.y
				level.pos.z = platform.pos.z + 290.272*n
			)
		)
		(r > 24):
		(
			for n = 1 to spn2.value do
			(
				maxOps.cloneNodes btn3.object cloneType:#instance newNodes:&level
				level = rootParent level[1]
				level.pos.x = platform.pos.x + 103.31
				level.pos.y = platform.pos.y
				level.pos.z = platform.pos.z + 290.272*n
				
				maxOps.cloneNodes btn3.object cloneType:#instance newNodes:&level
				level = rootParent level[1]
				level.pos.x = platform.pos.x - 103.31
				level.pos.y = platform.pos.y
				level.pos.z = platform.pos.z + 290.272*n
				coordsys local (rotate level 180 z_axis)
			)
		)
	)
	)
)

createDialog castleGen
