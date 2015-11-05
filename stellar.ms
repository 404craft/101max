-- underdev
global root
global elements = #()
global planets = #()
fn procreate x y z size circles circle_gap orbits orbit_gap ceiling sun =
(
	-- root
	root = circle radius:(size*circles*circle_gap*1.5) pos:[x,y,z] name: "stellar_root"
	-- base circles
	for c = 1 to circles do
	(
		rnd = random 0.1 3.0
		clone = circle radius:(rnd+size*c*circle_gap) pos:[x,y,z] steps:32 name: "stellar_base"
		m = sweep current_built_in_shape: 2
		addModifier clone m
		classof clone
		m[4].length = 1.5
		m[4].width = 1.5 * c
		append elements clone
	)
	-- base hemisphere
	s = sphere radius:(0.5 * sun) smooth:on segs:32 pos:[x,y,z] hemisphere:0.5 name: "stellar_base"
	append elements s

	-- rod cylinder base
	b = cylinder pos:[x,y,z] radius:2.0 smooth:on heightsegs:1 capsegs:1 sides:16 height: ((0.5 * sun) + 0.1) name: "stellar_rod_base"
	append elements b
	
	-- rod cylinder
	r = cylinder pos:[x,y,z] radius:(b.radius * 0.75) smooth:on heightsegs:1 capsegs:1 sides:16 height: ceiling name: "stellar_rod"
	append elements r

	s = sphere radius:sun smooth:on segs:32 pos:[x,y,ceiling] name: "stellar_core"
	append elements s
	
	--orbits
	for o = 1 to orbits do
	(
		d = dummy pos:[x,y,ceiling] name: "stellar_orbit_root"
		append planets d
		append elements d
		rnd = random 0.5 10.0
		rim = rnd+(sun*2)+o*orbit_gap
		orbit = circle radius:rim pos:[x,y,ceiling] steps:32 name: "stellar_orbit"
		m = sweep current_built_in_shape: 4
		addModifier orbit m
		classof orbit
		m[4].radius = 1.5
		orbit.parent = d
		append elements orbit
		
		rnd = random 5.0 (sun-(sun*0.25)) 
		s = sphere radius:rnd smooth:on segs:32 pos:[rim,y,ceiling] name: "stellar_planet"
		s.parent = d
		append elements s
		
		c = cylinder pos:[ceiling,y,z] rotation: (eulerangles 0 90 0) radius:(r.radius * 0.5) smooth:on heightsegs:1 capsegs:1 sides:16 height: (rim) name: "stellar_holder"
		c.parent = d
		append elements c
		
		r1 = random -120 120
		r2 = random -30 30
		rotate d (angleAxis r1 [0, 0, 1])
		rotate d (angleAxis r2 [0, 1, 0])
	)
	
	c = cylinder pos:[x,y,ceiling] radius:(r.radius * 0.75) smooth:on heightsegs:1 capsegs:1 sides:16 height: (ceiling*0.25) name: "stellar_holder"
	append elements c
	
	for e in elements do e.parent = root
	
)

try(destroydialog ::stellar)catch()
rollout stellar "" width:112 height:136
(
	spinner spn_size "" pos:[8,8] width:48 height:16 range:[1.0,10,5.0] type:#integer
	spinner spn_sun "" pos:[8,24] width:48 height:16 range:[1.0,50.0,20.0] type:#float
	spinner spn_ceiling "" pos:[56,24] width:48 height:16 range:[10,1000,200] type:#float
	spinner spn_circles "" pos:[56,56] width:48 height:16 range:[1,5,3] type:#integer
	spinner spn_c_gap "" pos:[8,56] width:48 height:16 range:[0.1,10,3.0] type:#float
	spinner spn_orbits "" pos:[56,72] width:48 height:16 range:[1,20,5] type:#integer
	spinner spn_o_gap "" pos:[8,72] width:48 height:16 range:[0.1,50.0,20.0] type:#float
	button btn_create "procreate" pos:[8,104] width:96 height:24
	on spn_size changed val do
	(
	)
	on spn_ceiling changed val do
	(
	)
	on spn_circles changed val do
	(
	)
	on spn_orbits changed val do
	(
	)
	on btn_create pressed do
	(
		procreate 0.0 0.0 0.0 spn_size.value spn_circles.value spn_c_gap.value spn_orbits.value spn_o_gap.value spn_ceiling.value spn_sun.value
		select root
	)
)

createdialog stellar()
