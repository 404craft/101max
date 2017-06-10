--new plugin under development
--procudural fantasy town generator for Water-Home models
--compatible with https://www.cgtrader.com/3d-models/exterior/cityscape/water-town
--download prefabs & create your Water-Town

try(destroydialog :: castle_101)catch()

if units.systemtype != #inches do units.systemtype = #inches
if units.displaytype != #generic do units.displaytype = #generic

rollout castle_101 "" width:128 height:296
(
	global root
	global flags = #()
	global crates = #()
	global a_root
	global c_root
	global roots = #()
	global blocks = #()
	global parts = #()
	global modules
	
	fn animateIn arr height offset lframe =
	(
		o = 0
		ani = #()
		
		for a in arr do for c in a.children do if isgrouphead c do append ani c
			
		join ani crates
		
		for a in ani do
		(
			if height > 0 then
			(
			a.parent = undefined
			move a [0,0,height]
			)
			
			animate on
			(
				if height == 0 do at time 0 a.visibility = off
				at time lframe
				(
				if height == 0 then a.visibility = on
					else move a [0,0,-height]
				)
			)
			controller = a.position.controller
			if height == 0 do controller = a.visibility.controller
			movekeys controller (o += offset)
			if height == 0 do moveKey controller 1 (((getKeyTime controller 2) - (getKeyTime controller 1)) - 1)
		)
		join roots ani
	)
	
	fn raze arr1 arr2 =
	(
		arr2 = #()
		for a in arr1 do
		(
			append arr2 a
			for c in a.children do
			(
				appendifunique arr2 c
			)
		)
		delete arr2
		arr2 = #()
	)
	
	fn dropCrate obj roo minX minY maxX maxY num rot =
	(
		for n = 1 to num do
		(
		maxOps.cloneNodes obj cloneType:#instance newNodes:&nn
		o = nn[1]
		s = random 0.5 1.5
		scale o [1*s,1*s,1*s]
		vdis = (distance o.mesh.verts[1].pos o.mesh.verts[2].pos) * s
		dir = random 0 1
		if dir == 0 do dir = -1
		
		x = random minX maxX
		y = (random minY maxY)*dir
		z = roo.pos.z + vdis / 2 + 5.78454
		
		o.pos = roo.pos
		rad = random 0 rot
		rotate o rad z_axis
		move o [x,y,z]
		
		for c in crates do
			if isvalidnode o do
				if intersects c o do delete o
		
		if isvalidnode o do
		(
		append crates o
		o.parent = roo
		o.name = roo.name + "_crate"
		)
		)
	)
	
	fn findNode roo pro arr = 
	(
		for r in roo do
		(
			if getuserpropbuffer r == pro then append arr r
		)
	)
	
	fn randomDir =
	(
		var = random 0 1
		if var == 0 do var= -1
		return var
	)
	
	fn turnNode obj rot =
	(
		d = randomDir()
		rot = rot - (random 0 10)*d
		
		if rot < 0 do rot = 0
			if rot > 359 do rot = 359
		
		obj.rotation = (quat 0 0 0 0)
		dir = quatToEuler obj.parent.rotation
		rotate obj (dir.z - rot) z_axis
		
		coordsys obj.parent
		(
			rotate obj 1.36 y_axis
		)
	)
	
	fn deleteBufferNode roo pro =
	(
		arr = #()
		for r in roo.children do
		(
			if getuserpropbuffer r == pro do append arr r
				
			for c in r.children do
			(
				if getuserpropbuffer c == pro do append arr c
			)
		)
		delete arr
	)
	
	fn rootParent node = 
	(
		if isvalidnode node do 
		(
		while node.parent != undefined do node = node.parent
		node
		)
	)

	fn rename roo nam =
	(
		arr = #()
		append arr roo
		for r in roo.children do
		(
			appendifunique arr r
				
			for c in r.children do
			(
				appendifunique arr c
			)
		)
		
		for a in arr do a.name = uniquename nam
	)
	
	fn gen_home meridian sel pos plat mod1 roo1 mod2 roo2 crate inhabited prefix iterator debug =
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
		rename platform ("waterhome_" + iterator as string + "_plat_")
		
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
					
					if meridian < 5 AND r > 24 then
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
							rename level ("waterhome_" + iterator as string + "_bloc_")
							if n > 1 do deleteBufferNode root "1/door"
								if n == 1 do deleteBufferNode root "1/door/window"
							
							if debug do format "debug: level % created at %\n" n level.pos
							dropCrate crate root -60.0 320.0 -160.0 -320.0 (random 1 3) 30
						)
						--create 1/module roof
						maxOps.cloneNodes roo1 cloneType:#instance newNodes:&roof
						roof = rootParent roof[1]
						roof.pos.x = platform.pos.x + 103.31
						roof.pos.y = platform.pos.y
						roof.pos.z = platform.pos.z + 290.272*meridian
						roof.parent = root
						rename roof ("waterhome_" + iterator as string + "_roof_")
						findNode roof "1/roof/flag" flags
						if debug do format "debug: roof created at %\n" roof.pos
					)
					else
					(
						if (random 0 1) == 1 do dropCrate crate root 160.0 320.0 -160.0 -320.0 (random 2 5) 90
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
						rename level ("waterhome_" + iterator as string + "_bloc_")
							
						if i_top == 1 do
						(
							deleteBufferNode level "2/door/1"
							deleteBufferNode level "2/door/2"
						)
						
						if i_top == 2 do 
						(
							deleteBufferNode level "2/door/2"
							deleteBufferNode level "2/door/2/window"
							deleteBufferNode level "2/vines"
							
							if n == 1 do
							(
							if i == 1 do deleteBufferNode level "2/door/1"
								if i == 2 do deleteBufferNode level "2/door/1/window"
							)
							
							if n > 1 do
							(
								deleteBufferNode level "2/door/1"
							)
						)

						if debug do format "debug: level %.% created at %\n" n i level.pos
						dropCrate crate root -180.0 300.0 180.0 320.0 (random 1 2) 20
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
						findNode roof "2/roof/flag" flags
						coordsys local
						(
						if m == -1 do rotate roof 180 z_axis
						rotate roof 1.36 y_axis
						)
						m *= -1
						roof.parent = root
						rename roof ("waterhome_" + iterator as string + "_roof_")
						if debug do format "debug: roof % created at %\n" i roof.pos
					)
				)
			)
		)
	)
	
	--create an alleyway complete with buildings
	fn gen_alley meridian sel pos plat mod1 roo1 mod2 roo2 crate iterator debug =
	(
		local r
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
				gen_home (meridian-b) sel pos plat mod1 roo1 mod2 roo2 crate false "_alley" (blocks.count + 1) debug
				append blocks root
				obj = blocks[blocks.count]
				try(obj = blocks[blocks.count-1])catch()
				if dir == 0 then coordsys obj blocks[blocks.count].pos = [0,794.268,0]
				else if dir != 0 then 
				(
				coordsys blocks[blocks.count-1-r] blocks[blocks.count].pos = [645.881,dir*148.38,0]
				dir = 0
				)	
			)
			--make a turn
			dir = random 0 1
			if dir == 0 do dir = -1
			b = blocks.count
			
			r = random 0 1
			
			for n = 0 to r do
			(
				gen_home (meridian-b) sel pos plat mod1 roo1 mod2 roo2 crate false "_alley" (blocks.count + 1) debug
				append blocks root
				coordsys blocks[blocks.count-1-n]
				(
				blocks[blocks.count].pos = [dir*(645.881-1291.76*n),148.387,0]
				rotate blocks[blocks.count] 90 z_axis
				)
			)
		)
		while blocks.count < max_blocks
		a_root = dummy pos:blocks[1].pos name: ("watertown_alley_" + iterator as string)
		scale a_root [1.2,1.2,1.2]
		for b = 1 to blocks.count do blocks[b].parent = a_root
		join roots blocks
		append roots a_root
	)
	
	--create town centre
	fn gen_centre size square meridian sel pos plat mod1 roo1 mod2 roo2 crate debug =
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
		gen_home meridian sel [pos.x+x*497.493,pos.y,pos.z] plat mod1 roo1 mod2 roo2 crate true "_centre" (parts.count + 1) debug
		append parts root
		
		if square == true do
		(
			gen_home meridian sel [pos.x+x*497.493,pos.y+794.268,pos.z] plat mod1 roo1 mod2 roo2 crate true "_centre" (parts.count + 1) debug
			append parts root
		)
		)
		
		posX = parts[1].pos.x+(parts[size].pos.x-parts[1].pos.x)/2
		posY = parts[1].pos.y+(parts[size].pos.y-parts[1].pos.y)/2
		posZ = pos.z
		
		c_root = dummy pos:[posX,posY,posZ] name: ("watertown_center")
		scale c_root [1.2,1.2,1.2]
		append roots c_root
		
		for p in parts do p.parent = c_root
		
		join roots parts
	)
	
	fn gen_city size square meridian alleys windward sel pos plat mod1 roo1 mod2 roo2 crate animated offset height debug =
	(
		flags = #()
		roots = #()
		crates = #()

		if debug do format "debug: town has % alleys\n" alleys

		castle_101.pb_pending.value += 100 / (alleys+1)
		gen_centre size square meridian sel pos plat mod1 roo1 mod2 roo2 crate debug

		t_root = dummy pos:c_root.pos name: ("watertown_root")
		scale t_root [1.5,1.5,1.5]
		append roots t_root
		
		m = 1
		if square do m = 2
		alley = #(1,2,3,4)
		
		for i = 1 to alleys do
 		(
		x = 0
		if random 0 3 < 3 do x = 497.493
		castle_101.pb_pending.value += 100/ (alleys+1)
 		gen_alley meridian sel pos plat mod1 roo1 mod2 roo2 crate i debug
		
		a = random 1 alley.count
		
		case alley[a] of
		(
			1:(pos = [parts[1].pos.x+x, parts[1].pos.y+794.268*m, parts[1].pos.z])
			2:(pos = [parts[1].pos.x-645.888, parts[1].pos.y-148.387, parts[1].pos.z])
			3:(pos = [parts[1].pos.x+x, parts[1].pos.y-794.268, parts[1].pos.z])
			4:(pos = [parts[parts.count].pos.x+645.888, parts[parts.count].pos.y+148.387, parts[parts.count].pos.z])
		)
		a_root.pos = pos
		rot = 90*(alley[a]-1)
		deleteitem alley a
		rotate a_root rot z_axis
		a_root.parent = t_root
 		)
		banners = #()
		for f in flags do
		(
			for b in f.children where (for m in b.modifiers where classof m == Bend collect m).count > 0 do append banners b

		turnNode f windward
		)
		InstanceMgr.MakeObjectsUnique &banners #individual
		
		for b in banners do (d = randomDir(); b.modifiers[1].angle = b.modifiers[1].angle - (random 0 10)*d; b.modifiers[2].angle = b.modifiers[2].angle - (random 0 10)*d)
		
		c_root.parent = t_root
		
		--animate blocks in for the purpose of presentation
		if animated do animateIn roots height offset 100
	)
	
	button btn_101 "look@101craft" pos:[8,8] width:112 height:16 toolTip:"visit 101craft.com"
	button btn_auto "grab prefabs" pos:[8,24] width:112 height:24 toolTip:"search scene to auto-assign watertown prefabs"
	pickbutton btn_platform "platform" pos:[8,96] width:112 height:24 toolTip:"define platform prefab slot"
	pickbutton btn_1module "1/ module" pos:[8,72] width:56 height:24 toolTip:"define solitary house prefab slot"
	pickbutton btn_2module "2/ module " pos:[64,72] width:56 height:24 toolTip:"define double house prefab slot"
	pickbutton btn_1roof "1/ roof" pos:[8,48] width:56 height:24 toolTip:"define solitary house roof prefab slot"
	pickbutton btn_2roof "2/ roof" pos:[64,48] width:56 height:24 toolTip:"define double house roof prefab slot"
	pickbutton btn_crate "crate" pos:[8,120] width:56 height:24 toolTip:"define crate prefab slot"
	pickbutton btn_barrel "barrel" pos:[64,120] width:56 height:24 toolTip:"define barrel prefab slot"
	
	checkbutton ckb_square "•" pos:[8,192] width:16 height:16 toolTip:"double platform"
	spinner spn_centre "" pos:[24,192] width:40 height:16 range:[2,4,2] type:#integer toolTip:"centre size"
	checkbutton ckb_levels "•" pos:[64,192] width:16 height:16 checked:true toolTip:"random number of levels"
	spinner spn_levels "" pos:[80,192] width:40 height:16 range:[2,10,2] type:#integer enabled:false toolTip:"maximum levels"
	checkbutton ckb_wind "•" pos:[8,208] width:16 height:16 checked:true toolTip:"random wind"
	spinner spn_wind "" pos:[24,208] width:40 height:16 range:[0,359,35] type:#integer enabled:false toolTip:"wind direction"
	checkbutton ckb_alleys "•" pos:[64,208] width:16 height:16 checked:true toolTip:"random number of alleys"
	spinner spn_alleys "" pos:[80,208] width:40 height:16 range:[1,4,4] type:#integer enabled:false toolTip:"number of alleys"
	
	checkbutton ckb_selection "•" pos:[8,144] width:16 height:48 toolTip:"build at selected object's position"
	spinner spn_posX "" pos:[24,144] width:96 height:16 enabled:true range:[-100000,100000,5000] type:#float
	spinner spn_posY "" pos:[24,160] width:96 height:16 enabled:true range:[-100000,100000,5000] type:#float
	spinner spn_posZ "" pos:[24,176] width:96 height:16 enabled:true range:[-100000,100000,0] type:#float
	
	checkbutton ckb_animated "•" pos:[8,224] width:16 height:16 toolTip:"animate town"
	spinner spn_offset "" pos:[24,224] width:40 height:16 enabled:false range:[0,100,10] type:#integer toolTip:"offset between the animation of modules"
	spinner spn_height "" pos:[64,224] width:56 height:16 enabled:false range:[0,100000,3000] type:#integer toolTip:"initial height for the animation"
	
	progressBar pb_pending "" pos:[8,248] width:112 height:16 value:0 color:(color 0 0 255) orient:#horizontal
	button btn_erase "•" pos:[8,264] width:16 height:24 toolTip:"erase created structure"
	button btn_create "BUILD" pos:[24,264] width:80 height:24 toolTip:"create structure"
	button btn_confirm "•" pos:[104,264] width:16 height:24 toolTip:"confirm created structure"

	on btn_auto pressed do
	(
		--.obj / fbx missing groups
		if isValidNode $wtr_mod_02_02_08 == false do
		(
		--1/roof			
		obj = #($wtr_mod_02_02_09, $wtr_mod_02_02_10)
		o = group obj
		o.name = "wtr_mod_02_02_08"
		h = $wtr_helper_02_10
		h.pivot = h.center
		o.pivot = h.pivot
		setuserpropbuffer o "1/roof/flag"
			
		obj = #($wtr_mod_02_02_08, $wtr_mod_02_02_04, $wtr_mod_02_02_11, $wtr_mod_02_02_12, $wtr_mod_02_02_00, $wtr_mod_02_02_02, $wtr_mod_02_02_06, $wtr_mod_02_02_07)
		append obj o
		o = group obj
		o.name = "wtr_mod_02_02_03"
		h = $wtr_helper_02_05
		h.pivot = h.center
		o.pivot = h.pivot
		setuserpropbuffer o "1/roof"
		
		--2/roof
		obj = #($wtr_mod_01_02_06, $wtr_mod_01_02_05)
		o = group obj
		o.name = "wtr_mod_01_02_04"
		h = $wtr_helper_01_10
		h.pivot = h.center
		o.pivot = h.pivot
		setuserpropbuffer o "2/roof/flag"
			
		obj = #($wtr_mod_01_02_04, $wtr_mod_01_02_07, $wtr_mod_01_02_11, $wtr_mod_01_02_12, $wtr_mod_01_02_09, $wtr_mod_01_02_10, $wtr_mod_01_02_00, $wtr_mod_01_02_02)
		append obj o
		o = group obj
		o.name = "wtr_mod_01_02_03"
		h = $wtr_helper_01_03
		h.pivot = h.center
		o.pivot = h.pivot
		setuserpropbuffer o "2/roof"
		
		--1/module
		obj = #($wtr_mod_02_01_18, $wtr_mod_02_01_17)
		o = group obj
		o.name = "wtr_mod_02_01_16"
		h = $wtr_mod_02_01_17
		h.pivot = h.center
		o.pivot = h.pivot
		setuserpropbuffer o "1/door"
			
		obj = #($wtr_mod_02_01_00, $wtr_mod_02_01_02)
		o = group obj
		o.name = "wtr_mod_02_01_01"
		h = $wtr_mod_02_01_00
		h.pivot = h.center
		o.pivot = h.pivot
		setuserpropbuffer o "1/door/window"
			
		obj = #($wtr_mod_02_01_16, $wtr_mod_02_01_01, $wtr_mod_02_01_04, $wtr_mod_02_01_05, $wtr_mod_02_01_06, $wtr_mod_02_01_07, $wtr_mod_02_01_08, $wtr_mod_02_01_09, $wtr_mod_02_01_10, $wtr_mod_02_01_11, $wtr_mod_02_01_12, $wtr_mod_02_01_13, $wtr_mod_02_01_14, $wtr_mod_02_01_15, $wtr_mod_02_01_19, $wtr_mod_02_01_20, $wtr_mod_02_01_22, $wtr_mod_02_01_23, $wtr_mod_02_01_25, $wtr_mod_02_01_26, $wtr_mod_02_01_28, $wtr_mod_02_01_29, $wtr_mod_02_01_31, $wtr_mod_02_01_32, $wtr_mod_02_01_34, $wtr_mod_02_01_35, $wtr_mod_02_01_37, $wtr_mod_02_01_38, $wtr_mod_02_01_40, $wtr_mod_02_01_41)
		o = group obj
		o.name = "wtr_mod_02_01_03"
		h = $wtr_helper_02_08
		h.pivot = h.center
		o.pivot = h.pivot
		setuserpropbuffer o "1/module"
		
		--2/module
		obj = #($wtr_mod_01_01_32, $wtr_mod_01_01_31)
		o = group obj
		o.name = "wtr_mod_01_01_30"
		h = $wtr_mod_01_01_32
		h.pivot = h.center
		o.pivot = h.pivot
		setuserpropbuffer o "2/door/1"
			
		obj = #($wtr_mod_01_01_26, $wtr_mod_01_01_25)
		o = group obj
		o.name = "wtr_mod_01_01_24"
		h = $wtr_mod_01_01_25
		h.pivot = h.center
		o.pivot = h.pivot
		setuserpropbuffer o "2/door/1/window"
		
		obj = #($wtr_mod_01_01_44, $wtr_mod_01_01_43)
		o = group obj
		o.name = "wtr_mod_01_01_42"
		h = $wtr_mod_01_01_43
		h.pivot = h.center
		o.pivot = h.pivot
		setuserpropbuffer o "2/door/2"
		
		obj = #($wtr_mod_01_01_38, $wtr_mod_01_01_37)
		o = group obj
		o.name = "wtr_mod_01_01_36"
		h = $wtr_mod_01_01_38
		h.pivot = h.center
		o.pivot = h.pivot
		setuserpropbuffer o "2/door/2/window"
		
		obj = #($wtr_mod_01_01_15, $wtr_mod_01_01_06, $wtr_mod_01_01_07, $wtr_mod_01_01_08, $wtr_mod_01_01_09, $wtr_mod_01_01_04, $wtr_mod_01_01_14, $wtr_mod_01_01_05)
		for o in obj do setuserpropbuffer o "1/vines"
			
		obj = #($wtr_mod_01_01_11, $wtr_mod_01_01_12, $wtr_mod_01_01_13, $wtr_mod_01_01_10)
		for o in obj do setuserpropbuffer o "2/vines"
			
		obj = #($wtr_mod_01_01_30, $wtr_mod_01_01_24, $wtr_mod_01_01_42, $wtr_mod_01_01_36, $wtr_mod_01_01_04, $wtr_mod_01_01_05, $wtr_mod_01_01_06, $wtr_mod_01_01_07, $wtr_mod_01_01_08, $wtr_mod_01_01_09, $wtr_mod_01_01_10, $wtr_mod_01_01_11, $wtr_mod_01_01_12, $wtr_mod_01_01_13, $wtr_mod_01_01_14, $wtr_mod_01_01_15, $wtr_mod_01_01_16, $wtr_mod_01_01_17, $wtr_mod_01_01_19, $wtr_mod_01_01_20, $wtr_mod_01_01_22, $wtr_mod_01_01_23, $wtr_mod_01_01_29, $wtr_mod_01_01_00, $wtr_mod_01_01_02, $wtr_mod_01_01_34, $wtr_mod_01_01_35, $wtr_mod_01_01_40, $wtr_mod_01_01_41, $wtr_mod_01_01_28)
		o = group obj
		o.name = "wtr_mod_01_01_03"
		h = $wtr_helper_01_08
		h.pivot = h.center
		o.pivot = h.pivot
		setuserpropbuffer o "2/module"
		
		--platform
		obj = #($wtr_walkway_02_00, $wtr_walkway_02_03, $wtr_walkway_02_04, $wtr_walkway_02_05, $wtr_walkway_02_07, $wtr_walkway_02_08, $wtr_walkway_02_09, $wtr_walkway_02_11, $wtr_walkway_02_12, $wtr_walkway_02_14, $wtr_walkway_02_15, $wtr_walkway_02_17, $wtr_walkway_02_18, $wtr_walkway_02_20, $wtr_walkway_02_21, $wtr_walkway_02_23, $wtr_walkway_02_24, $wtr_walkway_02_26, $wtr_walkway_02_27, $wtr_walkway_02_29, $wtr_walkway_02_30, $wtr_walkway_02_32, $wtr_walkway_02_33, $wtr_walkway_02_35, $wtr_walkway_02_36, $wtr_walkway_02_38, $wtr_walkway_02_39, $wtr_walkway_02_41, $wtr_walkway_02_42, $wtr_walkway_02_44, $wtr_walkway_02_45, $wtr_walkway_02_47, $wtr_walkway_02_48, $wtr_walkway_02_50, $wtr_walkway_02_51, $wtr_walkway_02_53, $wtr_walkway_02_54, $wtr_walkway_02_56, $wtr_walkway_02_57, $wtr_walkway_02_59, $wtr_walkway_02_60, $wtr_walkway_02_62, $wtr_walkway_02_63, $wtr_walkway_02_65, $wtr_walkway_02_66, $wtr_walkway_02_68, $wtr_walkway_02_69)
		o = group obj
		o.name = "wtr_walkway_02_01"
		h = $wtr_helper_02_09
		h.pivot = h.center
		o.pivot = h.pivot			
		setuserpropbuffer o "platform"
		
		--crate
		setuserpropbuffer $wtr_crate_18 "crate"			
		$wtr_crate_18.pivot = $wtr_crate_18.center
		)
		--personal version with defined buffer variables
		for o in objects do
		(
			case getuserpropbuffer o of
			(
				"1/roof":(btn_1roof.picked o; btn_1roof.object = o)
				"2/roof":(btn_2roof.picked o; btn_2roof.object = o)
				"1/module":(btn_1module.picked o; btn_1module.object = o)
				"2/module":(btn_2module.picked o; btn_2module.object = o)
				"platform":(btn_platform.picked o; btn_platform.object = o)
				"crate":(btn_crate.picked o;  btn_crate.object = o)
			)
		)
	)
	
	on ckb_selection changed state do
	(
		spn_posX.enabled = not spn_posX.enabled
		spn_posY.enabled = not spn_posY.enabled
		spn_posZ.enabled = not spn_posZ.enabled
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
	
	on btn_crate picked obj do
	(
		obj = rootParent obj
		btn_crate.text = obj.name
	)
	
	on ckb_levels changed state do
	(
		spn_levels.enabled = not spn_levels.enabled
	)
	
	on ckb_alleys changed state do
	(
		spn_alleys.enabled = not spn_alleys.enabled
	)
	
	on ckb_wind changed state do
	(
		spn_wind.enabled = not spn_wind.enabled
	)
	
	on spn_wind changed val do
	(
		try
		(
		for f in flags do turnNode f val
		for b in banners do (d = randomDir(); b.modifiers[1].angle = b.modifiers[1].angle - (random 0 10)*d; b.modifiers[2].angle = b.modifiers[2].angle - (random 0 10)*d)
		)catch()
	)
	
	on btn_create pressed do
	(
		try(raze roots modules)catch()
		pb_pending.value = 0
		if ckb_levels.state == false then levels = spn_levels.value
			else levels = random 2 10
		if ckb_alleys.state == false then alleys = spn_alleys.value
			else 
			(
				if (random 0 1) == 1 then alleys = 4
				else (alleys = random 1 3)
			)
		if ckb_wind.state == false then windward = spn_wind.value
			else windward = random 0 359
		gen_city spn_centre.value ckb_square.state levels alleys windward ckb_selection.state [spn_posX.value,spn_posY.value,spn_posZ.value] btn_platform.object btn_1module.object btn_1roof.object btn_2module.object btn_2roof.object btn_crate.object ckb_animated.state spn_offset.value spn_height.value false
	)
	
	on btn_confirm pressed do
	(
		roots = #()
	)
	
	on btn_erase pressed do
	(
		try(raze roots modules)catch()
	)
	
	on btn_101 pressed do
	(
		try(shelllaunch "www.101craft.com" "")catch()
	)
	
	on ckb_animated changed state do
	(
		spn_offset.enabled = not spn_offset.enabled
		spn_height.enabled = not spn_height.enabled
	)
)

createDialog castle_101

--disable tooltips
--for c in castle_101.controls do try(c.tooltip = "")catch()
