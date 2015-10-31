-- move objectAs to nearby objectBs
-- parent objectAs to nearby objectBs

/*for i = 1 to 100 do
(
r = random 10 20
box pos: (p = random [-300,-300,-300] [300,300,300]) length:r width:r height:r wirecolor: yellow
sphere pos: [p[1] + random -3 3,p[2] + random -3 3,p[3] + random -3 3] radius: (r + random -5 5) wirecolor: blue
)*/
/*for o = 1 to selection.count do move $[o] (random [-0.1,-0.1,-0.1] [0.1,0.1,0.1])*/

src = #()
tar = #()
try(destroydialog ::masterSnap)catch()
rollout masterSnap "" width:72 height:112
(
	button btn_snap "snap" pos:[8,72] width:56 height:17
	button btn_parent "parent" pos:[8,88] width:56 height:17
	button btn_src "source" pos:[24,8] width:40 height:17
	button btn_tar "target" pos:[24,24] width:40 height:17
	spinner spn_range "" pos:[8,48] width:56 height:16 range:[0.01,100000,0.01] type:#float

	button btn_tar_sel "•" pos:[8,24] width:16 height:17
	button btn_src_sel "•" pos:[8,8] width:16 height:17
	
	on btn_snap pressed do
	(
		try
		(
		for t = 1 to tar.count do for s = 1 to src.count where distance tar[t] src[s] < spn_range.value do src[s].transform = tar[t].transform
		)
		catch()
	)
	on btn_parent pressed do
	(
		try
		(
		for t = 1 to tar.count do for s = 1 to src.count where distance tar[t] src[s] < spn_range.value do src[s].parent = tar[t]
		)
		catch()
	)
	
	on btn_src pressed do
	(
	src = #()
	if selection.count > 1 do src = $ as array
	)
	
	on btn_src_sel pressed do
	(
	select src
	)
	
	on btn_tar pressed do
	(
	tar = #()
	if selection.count > 0 do tar = $ as array
	)
	
	on btn_tar_sel pressed do
	(
	select tar
	)
)

createdialog masterSnap
