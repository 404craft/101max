--new plugin under development
--procudural fantasy town generator for Water-Home models
--https://www.cgtrader.com/3d-models/architectural-exterior/house/water-home

try(destroydialog :: castleGen)catch()

rollout castle_gen "" width:136 height:296
(
	
	fn rootParent node = 
	(
		if isvalidnode node do 
		(
		while node.parent != undefined do node = node.parent
		node
		)
	)
		
	button btn_auto "auto-assign" pos:[8,24] width:112 height:24 toolTip:"search the scene to auto-assign watertown prefabs"
	pickbutton btn_platform "platform" pos:[8,96] width:112 height:24
	pickbutton btn_1module "1/ module" pos:[8,72] width:56 height:24
	pickbutton btn_2module "2/ module " pos:[64,72] width:56 height:24
	pickbutton btn_1roof "1/ roof" pos:[8,48] width:56 height:24
	pickbutton btn_2roof "2/ roof" pos:[64,48] width:56 height:24
	pickbutton btn_crate "crate" pos:[8,120] width:56 height:24
	pickbutton btn_barrel "barrel" pos:[64,120] width:56 height:24
	button btn_create "create" pos:[8,264] width:120 height:24
	spinner spn_centre "" pos:[8,176] width:56 height:16 range:[0,100,1] type:#integer toolTip:"centre size"
	spinner spn_levels "" pos:[64,176] width:56 height:16 range:[0,100,1] type:#integer toolTip:"maximum levels"
	checkbutton ckb_selection "•" pos:[8,144] width:16 height:32
	spinner spn_posX "" pos:[24,144] width:96 height:16 enabled:true range:[-100000,100000,1000] type:#float
	spinner spn_posY "" pos:[24,160] width:96 height:16 enabled:true range:[-100000,100000,1000] type:#float

	on btn_auto pressed do
	(
		for o in objects do
		(
			case getuserpropbuffer o of
			(
				"1/roof":(btn_1roof.picked o; btn_1roof.object = o)
				"2/roof":(btn_2roof.picked o; btn_2roof.object = o)
				"1/module":(btn_1module.picked o; btn_1module.object = o)
				"2/module":(btn_2module.picked o; btn_2module.object = o)
				"platform":(btn_platform.picked o; btn_platform.object = o)
			)
		)
	)
	
	on ckb_selection changed state do
	(
		spn_posX.enabled = not spn_posX.enabled
		spn_posY.enabled = not spn_posY.enabled
	)
	
	on btn_platform picked obj do
	(
		obj = rootParent obj
		btn_platform.text = obj.name
	)
	
	on btn_1module picked obj do
	(
		obj = rootParent obj
		btn_1module.text = obj.name
	)
	
	on btn_2module picked obj do
	(
		obj = rootParent obj
		btn_2module.text = obj.name
	)
	
	on btn_1roof picked obj do
	(
		obj = rootParent obj
		btn_1roof.text = obj.name
	)
	
	on btn_2roof picked obj do
	(
		obj = rootParent obj
		btn_2roof.text = obj.name
	)
	
	on btn_create pressed do
	(
		debug = true
		case ckb_selection.state of
		(
			true:(location = $.pos)
			false:(location = [spn_posX.value,spn_posY.value,0])
		)
		maxOps.cloneNodes btn_platform.object cloneType:#instance newNodes:&platform
		platform = rootParent platform[1]
		platform.pos = location
		
		r = random 0 99
		case of 
		(
			(r < 25):
			(
				if debug do print ("debug: creating 1/ module home")
				for n = 1 to spn_levels.value do
				(
					maxOps.cloneNodes btn_1module.object cloneType:#instance newNodes:&level
					level = rootParent level[1]
					level.pos.x = platform.pos.x + 103.31
					level.pos.y = platform.pos.y
					level.pos.z = platform.pos.z + 290.272*n
					if debug do format "debug: level % created at %\n" n level.pos
				)
				maxOps.cloneNodes btn_1roof.object cloneType:#instance newNodes:&roof
				roof = rootParent roof[1]
				roof.pos.x = platform.pos.x + 103.31
				roof.pos.y = platform.pos.y
				roof.pos.z = platform.pos.z + 290.272*spn_levels.value
				if debug do format "debug: roof created at %\n" roof.pos
			)
			
			(r > 24):
			(
				if debug do print ("debug: creating 2/ module home")
				i_top = 2
				highest = #()
				for n = 1 to spn_levels.value do
				(
					if (i_top !=1 AND n > 1) do
					(	
					r = random 0 99
					if r < (100 / spn_levels.value) do i_top = 1
					)
					
					m = 1
					for i = 1 to i_top do
					(
					maxOps.cloneNodes btn_2module.object cloneType:#instance newNodes:&level
					level = rootParent level[1]
					level.pos.x = platform.pos.x + 103.31*m
					level.pos.y = platform.pos.y
					level.pos.z = platform.pos.z + 283.692*n
					if m == -1 do coordsys local (rotate level 180 z_axis)
					highest[i] = level
					m *= -1
					if debug do format "debug: level %.% created at %\n" n i level.pos
					)
				)
				
				m = 1
				for i = 1 to 2 do
				(
				maxOps.cloneNodes btn_2roof.object cloneType:#instance newNodes:&roof
				roof = rootParent roof[1]
				roof.pos.x = highest[i].pos.x + 0.138*m
				roof.pos.y = highest[i].pos.y
				roof.pos.z = highest[i].pos.z + 0.00701904
				coordsys local
				(
				if m == -1 do rotate roof 180 z_axis
				rotate roof 1.36 y_axis
				)
				m *= -1
				if debug do format "debug: roof % created at %\n" i roof.pos
				)
			)
		)
	)
)

createDialog castle_gen
