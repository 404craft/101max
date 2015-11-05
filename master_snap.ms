-- move objectAs to nearby objectBs
-- parent objectAs to nearby objectBs
-- i.e. connect particle systems (vfx) to nearby cannons

/*for i = 1 to 100 do
(
r = random 10 20
box pos: (p = random [-300,-300,-300] [300,300,300]) length:r width:r height:r wirecolor: yellow
sphere pos: [p[1] + random -3 3,p[2] + random -3 3,p[3] + random -3 3] radius: (r + random -5 5) wirecolor: blue
)*/
/*for o = 1 to selection.count do move $[o] (random [-0.1,-0.1,-0.1] [0.1,0.1,0.1])*/

/*for o in objects where o.children.count == 0 AND o.parent == undefined do hide o*/

src = #()
tar = #()

global closest = #()
global ndis = #()

fn nearest objA objB val = 
(
	for a = 1 to objA.count do 
	(
		for b = 1 to objB.count do
		(
			dis = distance objA[a] objB[b]
			if dis < val do
			(
				if ndis[a] == undefined OR dis < ndis[a] do
				(
				ndis[a] = dis
				if closest[a] == undefined then insertitem objB[b] closest a
					else if closest[a] != undefined then closest[a] = objB[b]
				)
			)
		)
	)
)

try(destroydialog ::masterSnap)catch()
rollout masterSnap "" width:72 height:112
(
	button btn_snap "snap" pos:[8,88] width:56 height:17
	checkbutton btn_parent "parent" pos:[8,72] width:56 height:17 enabled: true checked:true
	button btn_src "arrayB" pos:[24,24] width:40 height:17
	button btn_tar "arrayA" pos:[24,8] width:40 height:17
	spinner spn_range "" pos:[8,48] width:56 height:16 range:[0.01,100000,0.01] type:#float

	button btn_tar_sel "•" pos:[8,8] width:16 height:17
	button btn_src_sel "•" pos:[8,24] width:16 height:17
	
	on btn_snap pressed do
	(
		nearest tar src spn_range.value
		try
		(
			for c = 1 to closest.count do
			(
				tar[c].transform = closest[c].transform
				if btn_parent.state == true do tar[c].parent = closest[c]
			)
		)catch()
	)

	on btn_src pressed do
	(
	src = #()
	if selection.count > 1 do src = $ as array
	if tar.count > 1 AND src.count > 1 do nearest tar src spn_range.value
	)
	
	on btn_src_sel pressed do
	(
	select src
	)
	
	on btn_tar pressed do
	(
	tar = #()
	if selection.count > 1 do tar = $ as array
	if tar.count > 1 AND src.count > 1 do nearest tar src spn_range.value
	)
	
	on btn_tar_sel pressed do
	(
	select tar
	)
)

createdialog masterSnap
