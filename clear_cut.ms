--auto-assign random smoothing groups across all faces 
--assign smoothing groups other than neighbours
--make an object coarse
--brute force method
--http://imgur.com/2ildnWQ

global a

fn wipe =
(
	fArr = undefined
	fArr = polyop.getNumFaces $
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
	--fArr = (polyop.getFaceSelection $) as array
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

differ()
