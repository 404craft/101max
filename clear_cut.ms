--auto-assign random smoothing groups across all faces 
--assign smoothing groups different to neighbors
--make an object coarse
--brute force method

global a

fn wipe w=
(
	fArr = undefined
	fArr = polyop.getNumFaces $
	--if w == 1 do fArr = (polyop.getFaceSelection $) as array
	for f = 1 to fArr do polyop.setFaceSmoothGroup $ f 0
)

fn hit f =
(
	r = (random 0 32)
	e = 0
	if (r != 0) do e = 2^(r-1)
	polyop.setFaceSmoothGroup $ f e
)

fn check f =
(
	fVerts = polyop.getVertsUsingFace $ #{f}
	fFaces = polyop.getFacesUsingVert $ fVerts
	
	s_f = polyop.getFaceSmoothGroup $ f
	
	--print ("debug: fn check " + s_f as string)
	do
	(
	--print ("debug: fn check --- start new do loop ---")
	b = false
		for i in fFaces where i != f do
		(
			s_i = polyop.getFaceSmoothGroup $ i
			--print ("debug: fn check " + s_i as string)
				if (s_i == s_f) do
				(
				hit(i)
				--print ("debug: fn check --- same group restart ---")
				a = true
				b = true
				)
		)
	)
	while b
)

fn differ =
(	
	fArr = undefined
	fArr = (polyop.getFaceSelection $) as array
	fArr = polyop.getNumFaces $

	for f = 1 to fArr do
	(
		hit(f)
	)
	
	do
	(
	-- print("debug: fn differ ---------- big loop start ----------")
	a = false
		for f = 1 to fArr do
		(
			check(f)
		)
	)
	while a
)

-- rollout
try(destroydialog ::clear_cut)catch()

rollout clear_cut "" width:64 height:64
(
	button btn_wipe "wipe" pos:[8,8] width:32 height:16 toolTip:"erase smoothing groups"
	button btn_differ "differ" pos:[8,24] width:48 height:16 toolTip:"assign random smoothing groups"
	label craft101 "@101craft" pos:[6,44] width:52 height:16
	checkbutton ckb_range "•" pos:[40,8] width:16 height:16

	on btn_wipe pressed do
	(
		wipe(0)
		/*if ckb_range.state == true do
		(
			wipe(1)
		)
		if ckb_range.state == false do
		(
			wipe(0)
		)*/
	)
	on btn_differ pressed do
	(
	differ()	
	)
	on ckb_range changed state do
	(
		
	)
)
createdialog clear_cut
