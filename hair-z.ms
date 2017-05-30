--short for "hair for zbrush"
--create geometrical hair from hair & fur modifier
--new max to zbrush pipeline plug under development

global src
global spl = #()
global tst = #()
global cpy = #()
global m_normalize
global m_sweep
global m_spline
global m_turbo

fn explode_spl val1 =
(
	spl = #()
	cpy = #()
	tst = #()
	m_normalize = undefined
	m_sweep = undefined
	m_spline = undefined
	m_turbo = undefined
	
	src = $
	src.wirecolor = blue
	src.name = "hair_src"
	num = numsplines src

	for n = 1 to num do
	(
		tar = copy src
		setFirstSpline tar n
		
		for nn = num to 2 by -1 do 
		(
			deleteSpline tar nn
		)
		append spl tar
	)
	
	spl.steps = 0
	spl.optimize = false
	spl.name = "hair_spl"
	spl.wirecolor = yellow
	
	if val1 == false do
	(
		test_spl()
	)
	hide src
)

fn test_spl =
(
	for n = 1 to 10 do
	(
		t = copy spl[n]
		if spl[n] != undefined do append tst t
	)
	
	tst.name = "hair_tst"
	tst.wirecolor = red
	hide spl
	unhide tst
)

fn normal_spl val1 val2 =
(
	arr1 = tst
	if val2 == true do arr1 = spl
	
	if m_normalize == undefined then
	(
		select arr1
		m_vdis = normal_dis()
		m_normalize = normalize_spl length:m_vdis
		modpanel.addmodtoselection m_normalize
		clearselection()
	)
	 
	else if m_normalize != undefined do
	(
		m_normalize.length = val1
	)
)

fn normal_dis =
(
	m_vdis = (distance (getKnotPoint spl[1] 1 1) (getKnotPoint spl[1] 1 2)) * 2
	hair_z.spn1.value = m_vdis
	return m_vdis
)

fn adjust_spl arr1 val1 val2 =
(
	m_vdis = distance (getKnotPoint arr1[1] 1 1) (getKnotPoint arr1[1] 1 2)
	
    for a in arr1 do
    (
        for i in a.modifiers.count to 1 by -1 do
		(
			if a.modifiers[i] == val1 do 
			(
				maxops.CollapseNodeTo a i off
				exit
			)
		)
		
		for n = (numknots a) to 2 by -1 do
		(
			vdis = distance (getKnotPoint a 1 n) (getKnotPoint a 1 (n-1))
			if vdis < m_vdis - (vdis/20) do deleteKnot a 1 n
		)
		updateshape a
    )
	
	if val2 == true do
	(
		for a = arr1.count to 1 by -1 do
		(
			if (numknots arr1[a]) < 3 do 
			(
			delete arr1[a]
			deleteitem arr1 a
			)
		)
	)
)

fn decimate_spl val1 val2 =
(
	arr1 = tst
	if val1 == true do arr1 = spl
		
	if m_normalize == undefined do
	(
		for n = 1 to arr1.count do
		(
		nTimes = (numknots arr1[n])
		deleteKnot arr1[n] 1 nTimes
		updateshape arr1[n]
		)
	)
	
	if m_normalize != undefined do
	(
		adjust_spl arr1 m_normalize val2
	)
)

fn sweep_spl val1 val2 = 
(
	arr1 = tst
	if val2 == true do arr1 = spl
		
	if m_sweep == undefined then
	(
		select arr1
		m_sweep = sweep current_built_in_shape:2
		modpanel.addmodtoselection m_sweep
		clearselection()
	)
	
	else if m_sweep != undefined do
	(
		if cpy.count > 0 do 
		(
			delete cpy
			cpy = #()
			unhide arr1
		)
	m_sweep[4].width = val1
	m_sweep[4].length = val1
	)
)

fn taper_spl val1 val2 =
(
	arr1 = tst
	if val2 == true do arr1 = spl
		
	if cpy.count > 0 do 
	(
		delete cpy
		cpy = #()
	)
	
	for a in arr1 do
	(
	obj = copy a
	hide a
	append cpy obj
	convertto obj editable_poly
	sc = 1
			
	n_verts = polyOp.getNumVerts obj
	n_val = val1 / n_verts
		
		for n = 1 to n_verts by 4 do
		(
		v_sel = #{n..n+3}
		sc = sc - (n_val * n)
		scl = [sc, sc, sc]
		v_arr = for v in v_sel collect polyOp.getVert obj v
		cnt = [0,0,0]
		for v_pos in v_arr do cnt+=v_pos
		cnt/=v_arr.count
		
		m = (transMatrix -cnt) * (scaleMatrix scl)
		n = 0	
		for v in v_sel do
		( 
			polyOp.moveVert obj v ((v_arr[n+=1]*m))
		)
		)
	)
	cpy.wirecolor = blue
	cpy.name = "hair_cpy"
)

fn turbo_spl val1 =
(
	arr1 = tst
	if val1 == true do arr1 = spl
		
	if cpy.count > 0 do arr1 = cpy
		
	if m_turbo == undefined do
	(
		select arr1
		m_turbo = turbosmooth iterations: 2
		modpanel.addmodtoselection m_turbo
		clearselection()
	)
)

fn reset_spl val1 val2 =
(
	delete cpy
	delete spl
	delete tst
	unhide src
	
	if val1 == 1 then select src
	else if val1 == 2 do select val2
)

fn execute_spl =
(
	delete tst
	tst = #()
	
	delete cpy
	cpy = #()
	
	m_normalize = undefined
	m_sweep = undefined
	m_spline = undefined
	m_turbo = undefined
	
	unhide spl
)

try(destroydialog ::hair_z)catch()
rollout hair_z "" width:144 height:224
(
	button btn1 "explode" pos:[8,32] width:128 height:16 toolTip:"separate splines"
	button btn2_1 "normalize" pos:[64,56] width:56 height:16 toolTip:"normalize spline"
	button btn2_2 "•" pos:[120,56] width:16 height:16 toolTip:"distance between knots"
	button btn3_1 "decimate" pos:[24,80] width:112 height:16 toolTip:"remove last knot"
	checkbutton btn3_2 "•" pos:[8,80] width:16 height:16 toolTip:"erase splines with 2 knots" checked:true
	button btn4 "sweep" pos:[8,104] width:72 height:16 toolTip:"add sweep modifier"
	button btn5 "taper" pos:[64,128] width:72 height:16 toolTip:"scale up initial polygons"
	button btn6 "turbo" pos:[8,152] width:128 height:16 toolTip:"smoothen geometry"
	button btn7 "reset" pos:[8,200] width:128 height:16 toolTip:"delete all proxies"
	checkbutton btn8 "preview" pos:[8,8] width:128 height:16 toolTip:"finalize hairlines"

	button btn9_1 "group" pos:[8,176] width:80 height:16 toolTip:"group hairlines"
	checkbutton btn9_2 "x" pos:[88,176] width:16 height:16 toolTip:"x to origin" checked:true
	checkbutton btn9_3 "y" pos:[104,176] width:16 height:16 toolTip:"y to origin" checked:true
	checkbutton btn9_4 "z" pos:[120,176] width:16 height:16 toolTip:"z to origin" checked:true
	
	spinner spn1 "" pos:[8,56] width:56 height:16 range:[0,10000,0] type:#float scale:0.1
	spinner spn2 "" pos:[80,104] width:56 height:16 range:[0,10000,32] type:#float scale:0.1
	spinner spn3 "" pos:[8,128] width:56 height:16 range:[0,10,0.01] type:#float scale:0.01
	

	on btn1 pressed do
	(
		explode_spl btn8.state
	)
	on btn2_1 pressed do
	(
		normal_spl spn1.value btn8.state
	)
	on btn2_2 pressed do
	(
		normal_dis()
	)
	on btn3_1 pressed do
	(
		decimate_spl btn8.state btn3_2.state
	)
	on btn4 pressed do
	(
		sweep_spl spn2.value btn8.state
	)
	on btn5 pressed do
	(
		taper_spl spn3.value btn8.state
	)
	on btn6 pressed do
	(
		turbo_spl btn8.state
	)
	on btn7 pressed do
	(
		reset_spl 1 undefined
	)
	on btn8 changed state do
	(
		execute_spl()
		if state == false then
		(
		btn8.text = "preview"
		test_spl()
		)
		else btn8.text = "final"
	)
	on btn9_1 pressed do
	(
		h = group cpy
		cpy = #()
		if btn9_2.state == true do h.pivot.x = 0
			if btn9_3.state == true do h.pivot.y = 0
				if btn9_4.state == true do h.pivot.z = 0
		h.name = "hair_group"
		reset_spl 2 h
	)
)
createdialog hair_z
