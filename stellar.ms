-- underdev
global root
fn procreate x y z size circles circle_gap orbits orbit_gap =
(
	-- root
	root = circle radius:(size*circles*circle_gap*1.5) pos:[x,y,z] name: "stellar_root"
	-- base circles
	for c = 1 to circles do
	(
		print(c as string)
		clone = circle radius:(size*c*circle_gap) pos:[x,y,z] name: "stellar_base"
		clone.parent = root
		m = sweep()
		addModifier clone m
		classof clone
		m[4].length = 1.5
		m[4].width = 1.5 * c
	)
	
	--orbits
	for o = 1 to orbits do
	(
	)
	
)

try(destroydialog ::stellar)catch()
rollout stellar "" width:112 height:136
(
	spinner spn_size "" pos:[8,8] width:48 height:16 range:[1,10,5] type:#integer
	spinner spn_circles "" pos:[56,32] width:48 height:16 range:[1,5,3] type:#integer
	spinner spn_c_gap "" pos:[8,32] width:48 height:16 range:[0.1,10,2.0] type:#float
	spinner spn_orbits "" pos:[56,48] width:48 height:16 range:[1,5,20] type:#integer
	spinner spn_o_gap "" pos:[8,48] width:48 height:16 range:[0.1,10,2.0] type:#float
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
		procreate 0.0 0.0 0.0 spn_size.value spn_circles.value spn_c_gap.value spn_orbits.value spn_o_gap.value
		select root
	)
)

createdialog stellar()
