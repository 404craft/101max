--new plugin under development
--procudural fantasy town generator for Water-Home models
--https://www.cgtrader.com/3d-models/architectural-exterior/house/water-home

try(destroydialog :: castle_gen)catch()

rollout castle_gen "" width:136 height:296
(
	global root
	global a_root
	global roots = #()
	global blocks = #()
	global parts = #()
	global modules = #()
	
	fn rootParent node = 
	(
		if isvalidnode node do 
		(
		while node.parent != undefined do node = node.parent
		node
		)
	)

	fn gen_home meridian sel pos plat mod1 roo1 mod2 roo2 inhabited prefix iterator debug =
	(
		root = undefined
		case sel of
		(
			true:(location = $.pos)
			false:(location = [pos.x,pos.y,pos.z])
		)
		maxOps.cloneNodes plat cloneType:#instance newNodes:&platform
		platform = rootParent platform[1]
		platform.pos = location
		root = dummy pos:platform.pos name: ("waterhome_" + iterator as string + prefix)
		root.rotation = platform.rotation
		platform.parent = root
		
		r = random 0 99
		if meridian < 1 AND (random 0 99 > 19) do meridian = 1
		if inhabited do r = 99
		if meridian > 0 do
		(
			case of 
			(
				
				(r < 25):
				(
					r = random 0 99
					
					if meridian < 5 AND r > 24 do
					(
						--create 1/module tile
						if debug do print ("debug: creating 1/ module home")
						for n = 1 to meridian do
						(
							maxOps.cloneNodes mod1 cloneType:#instance newNodes:&level
							level = rootParent level[1]
							level.pos.x = platform.pos.x + 103.31
							level.pos.y = platform.pos.y
							level.pos.z = platform.pos.z + 290.272*n
							level.parent = root
							if debug do format "debug: level % created at %\n" n level.pos
						)
						--create 1/module roof
						maxOps.cloneNodes roo1 cloneType:#instance newNodes:&roof
						roof = rootParent roof[1]
						roof.pos.x = platform.pos.x + 103.31
						roof.pos.y = platform.pos.y
						roof.pos.z = platform.pos.z + 290.272*meridian
						roof.parent = root
						if debug do format "debug: roof created at %\n" roof.pos
					)
				)
				
				(r > 24):
				(
					--create 2/module tile
					if debug do print ("debug: creating 2/ module home")
					i_top = 2
					highest = #()
					for n = 1 to meridian do
					(
						if (i_top !=1 AND n > 1) do
						(	
						r = random 0 99
						if r < (100 / meridian) do i_top = 1
						)
						m = 1
						for i = 1 to i_top do
						(
						maxOps.cloneNodes mod2 cloneType:#instance newNodes:&level
						level = rootParent level[1]
						level.pos.x = platform.pos.x + 103.31*m
						level.pos.y = platform.pos.y
						level.pos.z = platform.pos.z + 283.692*n
						if m == -1 do coordsys local (rotate level 180 z_axis)
						highest[i] = level
						m *= -1
						level.parent = root
						if debug do format "debug: level %.% created at %\n" n i level.pos
						)
					)
					
					--create 2/module roofs
					m = 1
					for i = 1 to 2 do
					(
						maxOps.cloneNodes roo2 cloneType:#instance newNodes:&roof
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
						roof.parent = root
						if debug do format "debug: roof % created at %\n" i roof.pos
					)
				)
			)
		)
	)
	
	--create an alleyway complete with buildings
	fn gen_alley meridian sel pos plat mod1 roo1 mod2 roo2 iterator debug =
	(
		blocks = #()
		max_blocks = meridian
		dir = 0
		meridian -= 2
		if meridian < 1 do meridian = 1
		
		do
		(
			rnd = random 1 2
			
			for i = 1 to rnd do
			(
				b = blocks.count
				gen_home (meridian-b) sel pos plat mod1 roo1 mod2 roo2 false "_alley" (blocks.count + 1) debug
				append blocks root
				obj = blocks[blocks.count]
				try(obj = blocks[blocks.count-1])catch()
				if dir == 0 then coordsys obj blocks[blocks.count].pos = [0,794.268,0]
				else if dir != 0 then 
				(
				coordsys blocks[blocks.count-1] blocks[blocks.count].pos = [645.881,dir*148.38,0]
				dir = 0
				)	
			)
			--make a turn
			dir = random 0 1
			if dir == 0 do dir = -1
			b = blocks.count
			gen_home (meridian-b) sel pos plat mod1 roo1 mod2 roo2 false "_alley" (blocks.count + 1) debug
			append blocks root
			coordsys blocks[blocks.count-1]
			(
			blocks[blocks.count].pos = [dir*645.881,148.387,0]
			rotate blocks[blocks.count] 90 z_axis
			)
		)
		while blocks.count < max_blocks
		a_root = dummy pos:blocks[1].pos name: ("waterhome_alley_" + iterator as string)
		for b = 1 to blocks.count do blocks[b].parent = a_root
		join roots blocks
	)
	
	--create town centre
	fn gen_centre size square meridian sel pos plat mod1 roo1 mod2 roo2 debug =
	(
		parts = #()
		
		for x = 0 to size-1 do
		(
			r = random 0 99
			if r < 30 AND parts.count > 0 do
			(
			meridian -= 1
			)
		if meridian < 1 do meridian = 1
		gen_home meridian sel [pos.x+x*497.493,pos.y,pos.z] plat mod1 roo1 mod2 roo2 true "_centre" (parts.count + 1) debug
		append parts root
		
		if square == true do
		(
			gen_home meridian sel [pos.x+x*497.493,pos.y+794.268,pos.z] plat mod1 roo1 mod2 roo2 true "_centre" (parts.count + 1) debug
			append parts root
		)
		)
		join roots parts
	)
	
	fn gen_city size square meridian sel pos plat mod1 roo1 mod2 roo2 debug =
	(
		roots = #()
		gen_centre size square meridian sel pos plat mod1 roo1 mod2 roo2 debug
		
		m = 1
		if square do m = 2
 		
		for i = 1 to 4 do
 		(
		x = 0
		if random 0 3 < 3 do x = 497.493
			
 		gen_alley meridian sel pos plat mod1 roo1 mod2 roo2 i debug
			
		case i of
		(
			1:(pos = [parts[1].pos.x+x, parts[1].pos.y+794.268*m, parts[1].pos.z])
			2:(pos = [parts[1].pos.x-645.888, parts[1].pos.y-148.387, parts[1].pos.z])
			3:(pos = [parts[1].pos.x+x, parts[1].pos.y-794.268, parts[1].pos.z])
			4:(pos = [parts[parts.count].pos.x+645.888, parts[parts.count].pos.y+148.387, parts[parts.count].pos.z])
		)
		a_root.pos = pos
		rot = 90*(i-1)
		rotate a_root rot z_axis
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
	
	checkbutton ckb_square "•" pos:[8,192] width:16 height:16 toolTip:"double platform"
	spinner spn_centre "" pos:[24,192] width:40 height:16 range:[2,4,2] type:#integer toolTip:"centre size"
	spinner spn_levels "" pos:[64,192] width:56 height:16 range:[2,10,2] type:#integer toolTip:"maximum levels"
	checkbutton ckb_selection "•" pos:[8,144] width:16 height:48
	spinner spn_posX "" pos:[24,144] width:96 height:16 enabled:true range:[-100000,100000,5000] type:#float
	spinner spn_posY "" pos:[24,160] width:96 height:16 enabled:true range:[-100000,100000,1000] type:#float
	spinner spn_posZ "" pos:[24,176] width:96 height:16 enabled:true range:[-100000,100000,0] type:#float
	
	button btn_create "create" pos:[8,264] width:104 height:24 toolTip:"create structure"
	button btn_confirm "•" pos:[112,264] width:16 height:24 toolTip:"confirm created structure"

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
		for r in roots do
		(
			append modules r
			for child in r.children do
			(
				appendifunique modules child
			)
		)
		delete modules
		modules = #()
		gen_city spn_centre.value ckb_square.state spn_levels.value ckb_selection.state [spn_posX.value,spn_posY.value,spn_posZ.value] btn_platform.object btn_1module.object btn_1roof.object btn_2module.object btn_2roof.object false
	
	)
	
	on btn_confirm pressed do
	(
		roots = #()
	)
)

createDialog castle_gen
