-- parametric model of a solar system
-- can be used for showcasing spaceships as in https://vimeo.com/40504508#t=0m5s

global root = undefined
global elements = #()
global p_orbit = #()
global p_track = #()
global m_track = #()
global m_orbit = #()
global base = #()
global top = #()
global planets = #()
global moons = #()
global asteroids = #()
global rad = 0

fn purge tar chk =
(
	if tar != undefined then s_pos = tar.pos
	else if root == undefined then s_pos = [0.0,0.0,0.0]

	try(if chk == true do kill elements)catch()
)

fn tone arr n rnd opa dye =
(  
	for a = 1 to arr.count do 
	(
	mat = standard()
	mat.opacity = opa
	mat.name = "m_" + arr[a] as string
		
	if dye == 0 then
	(
	mod = 255.0 / arr.count
	a1 = (255-a*mod as integer)
	a2 = (0+a*mod as integer)
	r = 255
	g = 255
	b = 255
	if n == 1 then (r = a1; g = a2)
		else if n == 2 then (g = a1; b = a2)
			else if n == 3 then (g = a1; b = a2)
				else if n == 4 then (r = a1 = g = b)
	c = color r g b 0
	mat.diffuse = c
	)
	
	else if dye == 1 then
	(
		mat.diffuseMap = noise()
		mat.diffuseMap.color1 = color (random 150 255) (random 100 200) 0 0
		mat.diffuseMap.color2 = color (random 200 255) (random 200 255) 0 0
		mat.diffuseMap.size = random 10.0 20.0
		mat.diffuseMap.type = 1
	)
	
	else if dye == 2 do
	(
		check = random 0 1
		if check == 0 then
		(
			mat.diffuseMap = Wood()
			mat.diffuseMap.thickness = random 10.0 30.0
			mat.diffuseMap.color1 = random white black
			mat.diffuseMap.color2 = random white black
		)
		else if check == 1 do
		(
			mat.diffuseMap = planet()
			mat.diffuseMap.oceanPercent = random 0.1 25.0
			mat.diffuseMap.continentSize = random 50.0 125.0
			mat.diffuseMap.islandFactor = random 5.0 10.0

			wtr = random white black
			--water colors
			mat.diffuseMap.color1 = wtr
			mat.diffuseMap.color2 = color (wtr.r-wtr.r*0.2) (wtr.g-wtr.g*0.2) (wtr.b-wtr.b*0.2) (wtr.a-wtr.a*0.2)
			mat.diffuseMap.color3 = color (wtr.r-wtr.r*0.1) (wtr.g-wtr.g*0.1) (wtr.b-wtr.b*0.1) (wtr.a-wtr.a*0.1)
			--land colors
			mat.diffuseMap.color4 = random white black
			mat.diffuseMap.color5 = random white black
			mat.diffuseMap.color6 = random white black
			mat.diffuseMap.color7 = random white black
			mat.diffuseMap.color8 = random white black
		)
	)
		
	try(arr[a].material = mat)catch()
	)
)

fn aim arr =
(
	global dir = #()
	for a = 1 to arr.count do
	(
		rnd = random 1 2
		if rnd == 1 then d = -1
			else if rnd == 2 do d = 1
		dir[a] = d
	)
)

fn spark arrA arrB spd matrix constrain roll =
(
	for a = 1 to arrA.count do
	(
		with animate on
		(
		   at time 0 rotate arrA[a] (angleAxis 0 matrix)
		   at time 50 rotate arrA[a] (angleAxis (spd) [matrix.x*dir[a], matrix.y*dir[a], matrix.z*dir[a]])
		)
		
		ctr = getXYZControllers arrA[a].rotation.controller
		for c in ctr do
		(	
			for k in c.keys do
			(
			k.inTangentType = #linear
			k.outTangentType = #linear
			)
		)
		setAfterORT arrA[a].rotation.controller #relativeRepeat
		
		if roll == true do
		(
		-- set orbit rotation
		r1 = random -120 120
		r2 = random -30 30
		rotate arrA[a] (angleAxis r1 [0, 0, 1])
		rotate arrA[a] (angleAxis r2 [0, 1, 0])
		)
			
		if constrain == true do
		(
		arrB[a].rotation.controller = Orientation_Constraint ()
		arrB[a].rotation.controller.appendTarget arrA[a] 100
		arrB[a].rotation.controller.local_world = 1
		arrB[a].rotation.controller.relative = on
		)
	)
)

fn kill arr =
(
	for a = 1 to arr.count do delete arr[a]
)

fn origin child parent =
(
	child.parent = parent
)

fn terra source o orbits orbit_gap mass decay period rootX rootY rootZ ceiling sun wire prefix alias form d_array o_array p_array astral comet =
(
		-- orbit roots / dummies
		d = dummy pos:[rootX,rootY,rootZ+ceiling] name: (prefix + alias + "orbit_root_" + o as string)
		origin d source
		append d_array d
		append top d
	
		rnd = random 0.5 period
		rim = rnd+(sun*decay)+o*orbit_gap

		-- orbit
		orbit = circle radius:rim pos:[rootX,rootY,rootZ+ceiling] steps:32 name: (prefix + alias + "orbit_" + o as string)
		m = sweep current_built_in_shape: 4
		addModifier orbit m
		classof orbit
		m[4].steps = 3
		if (comet == true AND o == orbits) do wire *= 0.5
		m[4].radius = wire * 0.75
		origin orbit d
		append o_array orbit
		append top orbit
		append p_array orbit

		c = random 0 2
		
		-- planet
		if (astral == false OR asteroids.count > 0 OR c > 0 or o == orbits) do
		(
			do rnd = random mass (sun-(sun*0.25))
				while rnd < wire * 2.0
			
			if (comet == true AND o == orbits) do
			(
				r = random 2.5 4.0
				p = box pos: [rootX+rim,rootY,(rootZ+ceiling)-(r*0.5)] length:r width:r height:r name: (prefix + alias + o as string + "_comet")
				origin p orbit
				append top p
				append c_head p
				global cometa = superspray pos:p.pos size:5.5 size_variation:2.0 birth_rate:1 total_number:100 quantitymethod:0 viewpercent:10 emitter_start:-50f emitter_stop:500f display_until:500f subsampleemittertranslation:on subsamplecreationtime:on subsampleemitterrotation:off seed:12345 metaparticle_tension:1 metaparticle_tension_variation:0 metaballautocoarsness:on metaballrendercoarsness:0.5 mappingtype:0 mapping_time_base:30f mapping_distance_base:100 spin_time:30f spin_time_variation:0 spin_phase:0 spin_phase_variation:0 spinaxistype:0 x_spin_vector:1 y_spin_vector:0 z_spin_vector:0 spin_axis_variation:0 motioninfluence:100 motionmultiplier:1 motionvariation:0 bubble_amplitude:0 bubble_amplitude_variation:0 bubble_period:100000f bubble_period_variation:0 bubble_phase:0 bubble_phase_variation:0 iconsize:16.822 iconhidden:off metaballviewcoarsness:1 spawn_affects:100 spawn_multiplier_variation:0 die__x_frames_after_collision:0f
				cometa.life = 15f
				cometa.life_variation= 3f
				cometa.off_axis = 0
				cometa.axis_spread = random 7 10
				cometa.off_plane = 0
				cometa.plane_spread = 0
				cometa.speed = random 7 10
				cometa.speed_variation = 0
				cometa.viewtype = 2
				cometa.standardparticle = 1
				cometa.interparticle_collisions_on = 0
				cometa.interparticle_collision_steps = 2
				cometa.interparticle_collision_bounce = 100 
				cometa.interparticle_collision_bounce_variation = 0
				cometa.name = (prefix + alias + o as string + "_comet_particles")
				origin p orbit
				cometa.growth_time = 5f
				cometa.fade_time = 20f
				cometa.viewpercent = 100
				origin cometa p
				append top cometa
			)
		
			if (comet == false) OR (comet == true AND o < orbits) do
			(
			p = sphere radius:rnd smooth:on segs:32 pos:[rootX+rim,rootY,rootZ+ceiling] name: (prefix + alias + o as string)
			origin p orbit
			append form p
			append top p
			append p_array p
			)
		)

		-- orbit holder
		stick = cylinder pos:[rootX,rootY,rootZ+ceiling] radius:((wire * 0.75) * 0.5) smooth:on heightsegs:1 capsegs:1 sides:16 height:rim name: (prefix + alias + o as string + "_orbit_holder" )
		rotate stick (angleAxis 90 [0, 1, 0])
		origin stick orbit
		append top stick
		append p_array stick
		
		-- asteroid belt
		if (astral == true AND asteroids.count == 0 AND c == 0 AND o != orbits) do
		(
			-- optionally adjust orbit and orbit holder
			m[4].radius *= 0.75
			stick.radius *= 0.75
			
			-- or switch them off for rendering
			--orbit.renderable = off
			stick.renderable = off
			
			d = dummy pos:[rootX+rim,rootY,rootZ+ceiling] name: (prefix + alias + o as string + "_asteroid_belt" )
			origin d orbit
			append top d
			append p_array p
			
			a = random 15 30
				for i = 1 to a do
				(
				r = random 1 4
				spread = random 5 18
				n = box pos: (p = random [rootX+rim-spread,rootY-spread,(rootZ+ceiling)-spread*0.25] [rootX+rim+spread,rootY+spread,(rootZ+ceiling)+spread*0.25]) length:r width:r height:r name: (prefix + alias + o as string + "_asteroid_" + i as string)
					try
					(
						for i in asteroids do
						(
							if (intersects i n == true) do delete n
						)
						
						if IsValidNode n == true do 
						(
							append asteroids n
							append top n
							origin n d
						)
					)catch()
				)
		)
)

fn procreate comet dye lunar astral alone pos size circles circle_gap orbits orbit_gap ceiling sun links wire =
(
	if alone do ceiling = 0.0
		
	root = undefined
	elements = #()
	p_track = #()
	p_orbit = #()
	m_track = #()
	m_orbit = #()
	base = #()
	top = #()
	planets = #()
	moons = #()
	asteroids = #()
	rad = 0
	
	-- root
	root = circle radius:(size*circles*circle_gap*1.5) pos:pos name: "stellar_root"
	root.steps = 0
	rootX = root.pos.x
	rootY = root.pos.y
	rootZ = root.pos.z
	append base root
	
	if alone != true do
	(
		len = 1.5
		-- base circles
		for c = 1 to circles do
		(
			rnd = random 0.1 3.0
			rad = rnd+size*c*circle_gap
			clone = circle radius:rad pos:root.pos steps:32 name: ("stellar_base_" + c as string)
			m = sweep current_built_in_shape: 2
			addModifier clone m
			classof clone
			m[4].length = len
			m[4].width = 1.5 * c
			clone.pos.z = clone.pos.z + (len *0.5)
			origin clone root
			append base clone
		)
		
		-- base links
		for l = 1 to (links*2) do
		(
			rot = l * (360 / (links*2))
			clone = box pos:[root.pos.x,root.pos.y,root.pos.z+(len * 0.25)] length: 1.5 width: (len * 0.5) height: rad name: ("stellar_link_" + l as string)
			rotate clone (angleAxis 90 [0,1,0])
			rotate clone (angleAxis rot [0, 0, 1])
			origin clone root
			append base clone
		)	
		
		-- base hemisphere
		s = sphere pos:root.pos radius:(0.5 * sun) smooth:on segs:32 hemisphere:0.5 name: "stellar_base"
		origin s root
		append base s

		-- rod cylinder base
		b = cylinder pos:root.pos radius:wire smooth:on heightsegs:1 capsegs:1 sides:16 height: ((0.5 * sun) + 0.1) name: "stellar_rod_base"
		origin b s
		append base b
		
		-- rod cylinder
		r = cylinder pos:root.pos radius:(wire * 0.75) smooth:on heightsegs:1 capsegs:1 sides:16 height: ceiling name: "stellar_rod"
		origin r b
		append base r
	)
	-- sun root
	s_r = dummy pos:[rootX,rootY,rootZ+ceiling] name: ("stellar_core_root")
	if alone == false then origin s_r r
		else if alone == true then origin s_r root
	append top s_r
	
	-- sun sphere
	core = sphere radius:sun smooth:on segs:32 pos:[rootX,rootY,rootZ+ceiling] name: "stellar_core"
	origin core s_r
	append top core
	suns = #()
	if alone != true do
	(
	-- rod cylinder base
	c = cylinder pos:[rootX,rootY,rootZ+ceiling-(sun+0.1)] radius:(wire * 1.25) smooth:on heightsegs:1 capsegs:1 sides:16 height: (2*sun + 0.2) name: "stellar_rod_sun"
	origin c core
	append suns c
	append top c
	)
	superior = #()
	--orbits
	if comet == true do orbits+=1
	for o = 1 to orbits do
	(
	terra s_r o orbits orbit_gap 5.0 2.0 10.0 rootX rootY rootZ ceiling sun wire "stellar_" "planet_" planets p_track p_orbit superior astral comet
	)
	
	--optionally create moons
	if lunar do
	(
		for p = 1 to planets.count do
		(
			inferior = #()
			--append inferior planets[p]
			check = random 0 3
			for m = 1 to check do
			(
			terra planets[p] m orbits (planets[p].radius*1.25) 0.1 0.5 (planets[p].radius * 0.25) planets[p].pos.x planets[p].pos.y planets[p].pos.z 0.0 (planets[p].radius*0.75) (wire*0.5) planets[p].name "_moon_" moons m_track m_orbit inferior false false
			)
			-- tone planets
			tone inferior 3 (random 0 255) 100 0
		)
	--animate moons
	aim moons
	spark moons moons ((random 5 10) * 60) [0,0,1] false false
	aim m_track
	spark m_track m_orbit ((random 5 10) * 30) [0,0,1] true true
	)
	--animate asteroids
	aim asteroids
	spark asteroids asteroids ((random 1 10) * 60) [0,1,0] false true

	-- animate planets
	aim planets
	spark planets planets ((random 5 10) * 30) [0,0,1] false false
	aim p_track
	-- comet's direction
	try(rotate cometa (angleAxis 90 [dir[orbits],0,0]))catch()
	spark p_track p_orbit ((random 1 10) * 15) [0,0,1] true true
	
	if alone != true do
	(
	c = cylinder pos:[rootX,rootY,rootZ+ceiling] radius:((wire * 0.75) * 0.75) smooth:on heightsegs:1 capsegs:1 sides:16 height: (sun*2) name: "stellar_holder"
	origin c s
	append top c
	)
	elements = join base top
	tone base 1 0 100 0
	tone top 2 0 100 0
	if dye == true then
	(
	append suns core
	--tone elements 4 0 50 0
	tone planets 2 0 100 2
	tone moons 2 0 100 2
	tone suns 1 0 100 1
	)
	else if dye == false do
	(
	tone superior 2 0 100 0
	)
)

try(destroydialog ::stellar)catch()
rollout stellar "" width:112 height:160
(
	global size = [1,10,5]
	global links = [2,10,3]
	global sun = [5.0,50.0,20.0]
	global wire = [0.1,3.0,1.75]
	global ceiling = [50.0,1000.0,200.0]
	global circles = [1,10,3]
	global c_gap = [1.0,10.0,3.0]
	global orbits = [1,20,5]
	global o_gap = [5.0,75.0,20.0]
	global s_pos = [0.0,0.0,0.0]
	
	spinner spn_size "" pos:[8,8] width:48 height:16 range:size type:#integer toolTip:"system size"
	spinner spn_links "" pos:[56,40] width:48 height:16 enabled:true range:links type:#integer toolTip:"number of diagonal base links"
	spinner spn_sun "" pos:[8,24] width:48 height:16 range:sun type:#float toolTip:"sun size"
	spinner spn_wire "" pos:[9,40] width:48 height:16 range:wire type:#float toolTip:"wire weight"
	spinner spn_ceiling "" pos:[56,24] width:48 height:16 range:ceiling type:#float toolTip:"system height"
	spinner spn_circles "" pos:[56,56] width:48 height:16 range:circles type:#integer toolTip:"number of base circles"
	spinner spn_c_gap "" pos:[8,56] width:48 height:16 range:c_gap type:#float toolTip:"gaps between circles"
	spinner spn_orbits "" pos:[56,72] width:48 height:16 range:orbits type:#integer toolTip:"number of orbits"
	spinner spn_o_gap "" pos:[8,72] width:48 height:16 range:o_gap type:#float toolTip:"gaps between orbits"
	button btn_create "procreate" pos:[32,128] width:72 height:24 toolTip:"for He spoke, and it was done"
	checkbutton chk_kill "annihilate" pos:[24,96] width:56 height:24 toolTip:"delete current before creating next" state:false
	checkbutton ckb_alone "" pos:[96,96] width:8 height:24 toolTip:"create a standalone system" state:false
	checkbutton ckb_lunar "" pos:[88,96] width:8 height:24 toolTip:"create planetary moons" state:false
	checkbutton ckb_astral "" pos:[80,96] width:8 height:24 toolTip:"create asteroid belt" state:false
	checkbutton ckb_dye "" pos:[8,96] width:8 height:24 toolTip:"texture system" state:false
	checkbutton ckb_comet "" pos:[16,96] width:8 height:24 toolTip:"create a comet" state:false
	button btn_c_3 "" pos:[24,128] width:8 height:24 toolTip:"create new system based on random extreme values"
	button btn_c_2 "" pos:[16,128] width:8 height:24 toolTip:"create new system based on random upper extreme values"
	button btn_c_1 "" pos:[8,128] width:8 height:24 toolTip:"create new system based on random lower extreme values"
	label lbl_101 "101craft" pos:[59,8] width:43 height:16

	on btn_create pressed do
	(
		purge root chk_kill.state
		procreate ckb_comet.state ckb_dye.state ckb_lunar.state ckb_astral.state ckb_alone.state s_pos spn_size.value spn_circles.value spn_c_gap.value spn_orbits.value spn_o_gap.value spn_ceiling.value spn_sun.value spn_links.value spn_wire.value
		select root
	)
	on btn_c_1 pressed do
	(
		purge root chk_kill.state
		procreate ckb_comet.state ckb_dye.state ckb_lunar.state ckb_astral.state ckb_alone.state s_pos (random size[1] size[3]) (random circles[1] circles[3]) (random c_gap[1] c_gap[3]) (random orbits[1] orbits[3]) (random o_gap[1] o_gap[3]) (random ceiling[1] ceiling[3]) (random sun[1] sun[3]) (random links[1] links[3]) wire[3]
		select root
	)
	on btn_c_2 pressed do
	(
		purge root chk_kill.state
		procreate ckb_comet.state ckb_dye.state ckb_lunar.state ckb_astral.state ckb_alone.state s_pos (random size[3] size[2]) (random circles[3] circles[2]) (random c_gap[3] c_gap[2]) (random orbits[3] orbits[2]) (random o_gap[3] o_gap[2]) (random ceiling[3] ceiling[2]) (random sun[3] sun[2]) (random links[3] links[2]) wire[3]
		select root
	)
	on btn_c_3 pressed do
	(
		purge root chk_kill.state
		procreate ckb_comet.state ckb_dye.state ckb_lunar.state ckb_astral.state ckb_alone.state s_pos (random size[1] size[2]) (random circles[1] circles[2]) (random c_gap[1] c_gap[2]) (random orbits[1] orbits[2]) (random o_gap[1] o_gap[2]) (random ceiling[1] ceiling[2]) (random sun[1] sun[2]) (random links[1] links[2]) wire[3]
		select root
	)
)

createdialog stellar()
