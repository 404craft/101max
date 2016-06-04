-- auto-assign random smoothing groups across all faces 
-- assign smoothing groups different to neighbors
-- make an object or selected faces coarse
-- reset smoothing groups on all or only selected faces (• - switch)
-- use it instead of auto-smooth to create a coarse object where auto-smooth 
   will assign same smoothing groups to faces sharing the same vertex which will result
   in creases upon adding a turbosmooth modifier
-- brute force method

global a

fn wipe w=
(
	fArr = undefined
	if w == 0 do
	(
	fArr = polyop.getNumFaces $
	for f = 1 to fArr do polyop.setFaceSmoothGroup $ f 0
	)
	
	if w == 1 do 
	(
	fArr = polyop.getFaceSelection $ as array
		for f = 1 to fArr.count do
		(
		polyop.setFaceSmoothGroup $ fArr[f] 0
		)
	)
)

fn hit f =
(
	r = (random 0 32)
	e = 0
	if (r != 0) do e = 2^(r-1)
	polyop.setFaceSmoothGroup $ f e
)

fn check f debug =
(
	fVerts = polyop.getVertsUsingFace $ #{f}
	fFaces = polyop.getFacesUsingVert $ fVerts
	
	s_f = polyop.getFaceSmoothGroup $ f
	
	if debug do format "debug: fn check %\n" s_f
		
	do
	(
	if debug do print ("debug: fn check --- start new do loop ---")
		
	b = false
		for i in fFaces where i != f do
		(
			s_i = polyop.getFaceSmoothGroup $ i
			if debug do format "debug: fn check %\n" s_i
				if (s_i == s_f) do
				(
				hit(i)
				if debug do print ("debug: fn check --- same group restart ---")
				a = true
				b = true
				)
		)
	)
	while b
)

fn differ debug =
(	
	fArr = undefined
	fArr = polyop.getNumFaces $
	sel = polyop.getFaceSelection $ as array
	
	-- if there are no selected faces loop through all faces
	if sel.count == 0 do
	(
		for f = 1 to fArr do
		(
			hit(f)
		)
		
		do
		(
		if debug do print("debug: fn differ ---------- big loop start ----------")
		a = false
			for f = 1 to fArr do
			(
				check f debug
			)
		)
		while a
	)
	
	-- differ selected polygons
	if sel.count != 0 do
	(
		for f = 1 to sel.count do
		(
			hit(sel[f])
		)
		
		do
		(
		if debug do print("debug: fn differ ---------- big loop start ----------")
		a = false
			for f = 1 to sel.count do
			(
				check sel[f] debug
			)
		)
		while a
	)
)

try(destroydialog ::clear_cut)catch()

rollout clear_cut "" width:64 height:64
(
	button btn_wipe "wipe" pos:[8,8] width:32 height:16 toolTip:"erase smoothing groups"
	button btn_differ "differ" pos:[8,24] width:48 height:16 toolTip:"assign random smoothing groups"
	checkbutton ckb_range "•" pos:[40,8] width:16 height:16 toolTip:"clear all or selected faces only"
	label craft101 "@101craft" pos:[6,44] width:52 height:16

	on btn_wipe pressed do
	(
		-- if the dot has been pressed reset smoothing groups on selected faces only
		if ckb_range.state == true do
		(
			wipe(1)
		)
		-- if the dot remains unpressed reset object's smoothing groups globally
		if ckb_range.state == false do
		(
			wipe(0)
		)
	)
	on btn_differ pressed do
	(
	differ(false)	
	)
)
createdialog clear_cut
