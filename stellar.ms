-- underdev

fn procreate x y z size circles orbits =
(
	-- root
	root = circle radius:(size*circles*2.0*1.5) pos:[x,y,z] name: "stellar_root"
	-- base circles
	for c = 1 to circles do
	(
		print(c as string)
		clone = circle radius:(size*c*2.0) pos:[x,y,z] name: "stellar_base"
		clone.parent = root
	)
	
	--orbits
	for o = 1 to orbits do
	(
		print("orbit")
	)
	
)

try(destroydialog ::stellar)catch()
rollout stellar "" width:112 height:112
(
	spinner spn_size "" pos:[8,8] width:48 height:16 range:[1,10,5] type:#integer
	spinner spn_circles "" pos:[8,32] width:48 height:16 range:[1,5,3] type:#integer
	spinner spn_orbits "" pos:[8,56] width:48 height:16 range:[1,5,20] type:#integer
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
		procreate 0.0 0.0 0.0 spn_size.value spn_circles.value spn_orbits.value
	)
)

createdialog stellar()
