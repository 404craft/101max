-- parametric model of a solar system
-- can be used for showcasing spaceships as in https://vimeo.com/40504508#t=0m5s

global root = undefined
global elements = #()
global p_track = #()
global p_orbit = #()
global m_track = #()
global m_orbit = #()
global base = #()
global top = #()
global planets = #()
global asteroids = #()
global rad = 0

fn purge tar chk =
(
	if tar != undefined then s_pos = tar.pos
	else if root == undefined then s_pos = [0.0,0.0,0.0]

	try(if chk == true do kill elements)catch()
)

fn tone arr n rnd =
(  
	for a = 1 to arr.count do 
	(
	mat = standard()
	mat.name = "m_" + arr[a] as string
	mod = 255.0 / arr.count
	a1 = (255-a*mod as integer)
	a2 = (0+a*mod as integer)
	r = 255
	g = 255
	b = 255
	if n == 1 then (r = a1; g = a2)
		else if n == 2 then (g = a1; b = a2)
			else if n == 3 then (g = a1; b = a2)
	c = color r g b 0
	mat.diffuse = c
	try(arr[a].material = mat)catch()
	)
)

fn spark arrA arrB spd =
(
	for a = 1 to arrA.count do
	(
		rnd = random 1 2
		if rnd == 1 then dir = -1
			else if rnd == 2 then dir = 1
				
		with animate on
		(
		   at time 0 rotate arrA[a] (angleAxis 0 [0, 0, 1])
		   at time 50 rotate arrA[a] (angleAxis (spd) [0, 0, dir])
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
		
		-- set orbit rotation
		r1 = random -120 120
		r2 = random -30 30
		rotate arrA[a] (angleAxis r1 [0, 0, 1])
		rotate arrA[a] (angleAxis r2 [0, 1, 0])
		
	arrB[a].rotation.controller = Orientation_Constraint ()
	arrB[a].rotation.controller.appendTarget arrA[a] 100
	arrB[a].rotation.controller.local_world = 1
	arrB[a].rotation.controller.relative = on
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

fn terra source o orbit_gap mass decay period rootX rootY rootZ ceiling sun wire prefix alias store d_array o_array p_array astral =
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
		m[4].radius = wire * 0.75
		origin orbit d
		append o_array orbit
		append top orbit
		append p_array orbit

		c = random 0 2
		
		-- planet
		if (astral == false OR asteroids.count > 0 OR c > 0) do
		(
		rnd = random mass (sun-(sun*0.25)) 
		p = sphere radius:rnd smooth:on segs:32 pos:[rootX+rim,rootY,rootZ+ceiling] name: (prefix + alias + o as string)
		origin p orbit
		if store do append planets p
		append top p
		append p_array p
		)

		-- asteroid belt
		if (astral == true AND asteroids.count == 0 AND c == 0) do
		(
			d = dummy pos:[rootX+rim,rootY,rootZ+ceiling] name: (prefix + alias + "asteroid_root" + o as string)
			origin d orbit
			append top d
			append p_array p
			
			a = random 15 30
				for i = 1 to a do
				(
				r = random 0.5 5
				spread = random 5 20
				n = box pos: (p = random [rootX+rim-spread,rootY-spread,(rootZ+ceiling)-spread*0.25] [rootX+rim+spread,rootY+spread,(rootZ+ceiling)+spread*0.25]) length:r width:r height:r name: (prefix + alias + "asteroid_" + i as string)
					try
					(
						for i in asteroids do
						(
							if (intersects i n == true) do 
							(
								print (i.name + "intersects with" + n.name)
								delete n
							)
							
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

		-- orbit holder
		c = cylinder pos:[rootX,rootY,rootZ+ceiling] radius:((wire * 0.75) * 0.5) smooth:on heightsegs:1 capsegs:1 sides:16 height:rim name: (prefix + alias + "orbit_holder_" + o as string)
		rotate c (angleAxis 90 [0, 1, 0])
		origin c orbit
		append top c
		append p_array c
)

fn procreate lunar astral alone pos size circles circle_gap orbits orbit_gap ceiling sun links wire =
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
	s = sphere radius:sun smooth:on segs:32 pos:[rootX,rootY,rootZ+ceiling] name: "stellar_core"
	origin s s_r
	append top s
	
	if alone != true do
	(
	-- rod cylinder base
	c = cylinder pos:[rootX,rootY,rootZ+ceiling-(sun+0.1)] radius:(wire * 1.25) smooth:on heightsegs:1 capsegs:1 sides:16 height: (2*sun + 0.2) name: "stellar_rod_sun"
	origin c s
	append top c
	)
	superior = #()
	--orbits
	for o = 1 to orbits do
	(
	terra s_r o orbit_gap 5.0 2.0 10.0 rootX rootY rootZ ceiling sun wire "stellar_" "planet_" true p_track p_orbit superior astral
	)
	
	--optionally create moons
	if lunar do
	(
		for p = 1 to planets.count do
		(
			inferior = #()
			--append inferior planets[p]
			moons = random 0 3
			for m = 1 to moons do
			(
			terra planets[p] m (planets[p].radius*1.25) 0.1 0.5 (planets[p].radius * 0.25) planets[p].pos.x planets[p].pos.y planets[p].pos.z 0.0 (planets[p].radius*0.75) (wire*0.5) planets[p].name "_moon_" false m_track m_orbit inferior false
			)
			-- tone planets
			tone inferior 3 (random 0 255)
		)
	--animate moons
	spark m_track m_orbit ((random 5 10) * 30)
	)

	-- animate planets
	spark p_track p_orbit ((random 1 10) * 15)
	if alone != true do
	(
	c = cylinder pos:[rootX,rootY,rootZ+ceiling] radius:((wire * 0.75) * 0.75) smooth:on heightsegs:1 capsegs:1 sides:16 height: (sun*2) name: "stellar_holder"
	origin c s
	append top c
	)
	
	elements = join base top
	tone base 1 0
	tone top 2 0
	tone superior 2 0
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
	checkbutton chk_kill "annihilate" pos:[8,96] width:72 height:24 toolTip:"delete current before creating next" state:false
	checkbutton ckb_alone "" pos:[96,96] width:8 height:24 toolTip:"create a standalone system" state:false
	checkbutton ckb_lunar "" pos:[88,96] width:8 height:24 toolTip:"create planetary moons" state:false
	checkbutton ckb_astral "" pos:[80,96] width:8 height:24 toolTip:"create asteroid belt" state:false
	button btn_c_3 "" pos:[24,128] width:8 height:24 toolTip:"create new system based on random extreme values"
	button btn_c_2 "" pos:[16,128] width:8 height:24 toolTip:"create new system based on random upper extreme values"
	button btn_c_1 "" pos:[8,128] width:8 height:24 toolTip:"create new system based on random lower extreme values"
	label lbl_101 "101craft" pos:[59,8] width:43 height:16

	on btn_create pressed do
	(
		purge root chk_kill.state
		procreate ckb_lunar.state ckb_astral.state ckb_alone.state s_pos spn_size.value spn_circles.value spn_c_gap.value spn_orbits.value spn_o_gap.value spn_ceiling.value spn_sun.value spn_links.value spn_wire.value
		select root
	)
	on btn_c_1 pressed do
	(
		purge root chk_kill.state
		procreate ckb_lunar.state ckb_astral.state ckb_alone.state s_pos (random size[1] size[3]) (random circles[1] circles[3]) (random c_gap[1] c_gap[3]) (random orbits[1] orbits[3]) (random o_gap[1] o_gap[3]) (random ceiling[1] ceiling[3]) (random sun[1] sun[3]) (random links[1] links[3]) wire[3]
		select root
	)
	on btn_c_2 pressed do
	(
		purge root chk_kill.state
		procreate ckb_lunar.state ckb_astral.state ckb_alone.state s_pos (random size[3] size[2]) (random circles[3] circles[2]) (random c_gap[3] c_gap[2]) (random orbits[3] orbits[2]) (random o_gap[3] o_gap[2]) (random ceiling[3] ceiling[2]) (random sun[3] sun[2]) (random links[3] links[2]) wire[3]
		select root
	)
	on btn_c_3 pressed do
	(
		purge root chk_kill.state
		procreate ckb_lunar.state ckb_astral.state ckb_alone.state s_pos (random size[1] size[2]) (random circles[1] circles[2]) (random c_gap[1] c_gap[2]) (random orbits[1] orbits[2]) (random o_gap[1] o_gap[2]) (random ceiling[1] ceiling[2]) (random sun[1] sun[2]) (random links[1] links[2]) wire[3]
		select root
	)
)

createdialog stellar()
