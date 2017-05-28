--short for "hair for zbrush"
--create geometrical hair from hair & fur
--max to zbrush pipeline plug
--new plugin under development

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
	hide src
)

fn normal_spl val1 val2 =
(
	arr1 = tst
	if val2 == true do arr1 = spl
		
	m_vdis = (distance (getKnotPoint arr1[1] 1 1) (getKnotPoint arr1[1] 1 2)) * 2
	m = normalize_spl length:m_vdis
	
	if m_normalize == undefined then
	(
		addmodifier arr1 m
		hair_z.spn1.value = m_vdis
		m_normalize = arr1[1].modifiers[1]
	)
	 
	else if m_normalize != undefined do
	(
		m_normalize.length = val1
	)
)

fn adjust_spl val1 val2 =
(
	m_vdis = distance (getKnotPoint val1[1] 1 1) (getKnotPoint val1[1] 1 2)
	
    for v in val1 do
    (
        for i in v.modifiers.count to 1 by -1 do
		(
			if v.modifiers[i] == val2 do 
			(
				maxops.CollapseNodeTo v i off
				exit
			)
		)
		
		for n = (numknots v) to 2 by -1 do
		(
			vdis = distance (getKnotPoint v 1 n) (getKnotPoint v 1 (n-1))
			if vdis < m_vdis - (vdis/20) do deleteKnot v 1 n
		)
		if (numknots v) < 3 then 
		(
		deleteitem val1 v
		delete v
		)
		else updateshape v
    )
)

fn decimate_spl val1 =
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
		adjust_spl arr1 m_normalize
	)
)

fn sweep_spl val1 val2 = 
(
	arr1 = tst
	if val2 == true do arr1 = spl
		
	if m_sweep == undefined then
	(
		m_sweep = sweep current_built_in_shape:2
		addmodifier arr1 m_sweep
	)
	
	else if m_sweep != undefined do
	(
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
	sc = 1 + val1
		
	n_verts = polyOp.getNumVerts obj
	c = (n_verts / 4) / 3
		
		for n = 1 to n_verts by 4 do
		(
		v_sel = #{n..n+3}
		sc = sc - (0.05 * c)
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
		c+=1
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
		m_turbo = turbosmooth iterations: 2
		addmodifier arr1 m_turbo	
	)
)

fn reset_spl =
(
	delete cpy
	delete spl
	delete tst
	unhide src
	select src
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
rollout hair_z "" width:128 height:200
(
	button btn1 "explode" pos:[8,32] width:112 height:16 toolTip:"separate splines"
	button btn2 "normalize" pos:[64,56] width:56 height:16 toolTip:"normalize spline"
	button btn3 "decimate" pos:[8,80] width:112 height:16 toolTip:"remove last knot"
	button btn4 "sweep" pos:[8,104] width:56 height:16 toolTip:"add sweep modifier"
	button btn5 "taper" pos:[64,128] width:56 height:16 toolTip:"scale up initial polygons"
	button btn6 "turbo" pos:[8,152] width:112 height:16 toolTip:"smoothen geometry"
	button btn7 "reset" pos:[8,176] width:112 height:16 toolTip:"delete all proxies"
	checkbutton btn8 "confirm" pos:[8,8] width:112 height:16 toolTip:"finalize hairlines"
	
	spinner spn1 "" pos:[8,56] width:56 height:16 range:[0,10000,0] type:#float scale:0.1
	spinner spn2 "" pos:[64,104] width:56 height:16 range:[0,10000,0] type:#float scale:0.1
	spinner spn3 "" pos:[8,128] width:56 height:16 range:[0,10,0] type:#float scale:0.1

	on btn1 pressed do
	(
		explode_spl btn8.state
	)
	on btn2 pressed do
	(
		normal_spl spn1.value btn8.state
	)
	on btn3 pressed do
	(
		decimate_spl btn8.state
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
		reset_spl()
	)
	
	on btn8 changed state do
	(
	-- if state == true then btn8.text = "global"
	--	 else btn8.text = "local"
		execute_spl()
	)
)
createdialog hair_z
