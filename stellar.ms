-- underdev
global root
global elements = #()
fn procreate x y z size circles circle_gap orbits orbit_gap ceiling =
(
	-- root
	root = circle radius:(size*circles*circle_gap*1.5) pos:[x,y,z] name: "stellar_root"
	-- base circles
	for c = 1 to circles do
	(
		clone = circle radius:(size*c*circle_gap) pos:[x,y,z] name: "stellar_base"
		m = sweep()
		addModifier clone m
		classof clone
		m[4].length = 1.5
		m[4].width = 1.5 * c
		append elements clone
	)
	
	s = sphere radius:10.0 smooth:on segs:32 pos:[x,y,z] hemisphere:0.5 name: "stellar_base"
	append elements s
	
	c = cylinder pos:[x,y,z] radius:2.0 smooth:on heightsegs:1 capsegs:1 sides:16 height: ceiling name: "stellar_rod"
	append elements c

	s = sphere radius:20.0 smooth:on segs:32 pos:[x,y,ceiling] name: "stellar_core"
	append elements s
	
	--orbits
	for o = 1 to orbits do
	(
		d dummy pos:[x,y,ceiling] name: "stellar_orbit_root"
		append elements d
		orbit = circle radius:(size*o*orbit_gap) pos:[x,y,z] name: "stellar_orbit"
		m = sweep()
		addModifier orbit m
		classof orbit
		m[4].radius = 1.5
		orbit.parent = d
		append elements orbit
	)
	
	for e in elements do e.parent = root
	
)

try(destroydialog ::stellar)catch()
rollout stellar "" width:112 height:136
(
	spinner spn_size "" pos:[8,8] width:48 height:16 range:[1,10,5] type:#integer
	spinner spn_ceiling "" pos:[56,8] width:48 height:16 range:[10.0,1000.0,200.0] type:#float
	spinner spn_circles "" pos:[56,32] width:48 height:16 range:[1,5,3] type:#integer
	spinner spn_c_gap "" pos:[8,32] width:48 height:16 range:[0.1,10.0,2.0] type:#float
	spinner spn_orbits "" pos:[56,48] width:48 height:16 range:[1,5,20] type:#integer
	spinner spn_o_gap "" pos:[8,48] width:48 height:16 range:[0.1,10.0,2.0] type:#float
	button btn_create "execute" pos:[8,80] width:96 height:24

	on spn_size changed val do
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
		procreate 0.0 0.0 0.0 spn_size.value spn_circles.value spn_c_gap.value spn_orbits.value spn_o_gap.value spn_ceiling.value
		select root
	)
	on spn_ceiling changed val do
		(
	)
)

createdialog stellar()
