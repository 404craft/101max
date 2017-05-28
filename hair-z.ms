--short for "hair for zbrush"
--max to zbrush hair&fur pipeline plug
--new plugin under development

global spl = #()
global cpy = #()
global m_normalize
global m_sweep
global m_spline
global m_turbo

fn explode_spl =
(
	spl = #()
	cpy = #()
	state = 0
	m_normalize = undefined
	m_sweep = undefined
	m_spline = undefined
	m_turbo = undefined
	
	source = $
	num = numsplines source

	for n = 1 to num do
	(
		target = copy source 
		setFirstSpline target n
		
		for nn = num to 2 by -1 do 
		(
			deleteSpline target nn
		)
		append spl target
		target.steps = 0
		target.optimize = false
		target.name = "hair_spl"
		target.wirecolor = source.wirecolor
	)
	delete source	
)

fn normal_spl val =
(
	m_vdis = (distance (getKnotPoint spl[1] 1 1) (getKnotPoint spl[1] 1 2)) * 2
	m = normalize_spl length:m_vdis
	
	if m_normalize == undefined then
	(
		addmodifier spl m
		hair_z.spn1.value = m_vdis
		m_normalize = spl[1].modifiers[1]
	)
	 
	else if m_normalize != undefined do
	(
		m_normalize.length = val
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

fn decimate_spl =
(
	if m_normalize == undefined do
	(
		for n = 1 to spl.count do
		(
		nTimes = (numknots spl[n])
		deleteKnot spl[n] 1 nTimes
		updateshape spl[n]
		)
	)
	
	if m_normalize != undefined do
	(
		adjust_spl spl m_normalize
	)
)

fn sweep_spl val = 
(
	if m_sweep == undefined then
	(
		m_sweep = sweep current_built_in_shape:2
		addmodifier spl m_sweep
	)
	
	else if m_sweep != undefined do
	(
	m_sweep[4].width = val
	m_sweep[4].length = val
	)
)

fn taper_spl val =
(
	if cpy.count > 0 do 
	(
		delete cpy
		cpy = #()
	)
	
	for s in spl do
	(
	obj = copy s
	obj.wirecolor = s.wirecolor
	hide s
	obj.name = "hair_cpy"
	append cpy obj
	convertto obj editable_poly
	sc = 1 + val
		
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
)

fn turbo_spl val1 =
(
	if cpy.count > 0 do val1 = cpy
		
	if m_turbo == undefined do
	(
		m_turbo = turbosmooth iterations: 2
		addmodifier val1 m_turbo	
	)
)

try(destroydialog ::hair_z)catch()
rollout hair_z "" width:128 height:152
(
	button btn1 "explode" pos:[8,8] width:112 height:16 toolTip:"separate splines"
	button btn2 "normalize" pos:[64,32] width:56 height:16 toolTip:"normalize spline"
	button btn3 "decimate" pos:[8,56] width:112 height:16 toolTip:"remove last knot"
	button btn4 "sweep" pos:[8,80] width:56 height:16 toolTip:"add sweep modifier"
	button btn5 "taper" pos:[64,104] width:56 height:16 toolTip:"scale up initial polygons"
	button btn6 "turbo" pos:[8,128] width:112 height:16 toolTip:"smoothen geometry"
	spinner spn1 "" pos:[8,32] width:56 height:16 range:[0,10000,0] type:#float scale:0.1
	spinner spn2 "" pos:[64,80] width:56 height:16 range:[0,10000,10] type:#float scale:0.1
	spinner spn3 "" pos:[8,104] width:56 height:16 range:[0,10,0.5] type:#float scale:0.1

	on btn1 pressed do
	(
		explode_spl()
	)
	on btn2 pressed do
	(
		normal_spl spn1.value
	)
	on btn3 pressed do
	(
		decimate_spl()
	)
	on btn4 pressed do
	(
		sweep_spl spn2.value
	)
	on btn5 pressed do
	(
		taper_spl spn3.value
	)
	on btn6 pressed do
	(
		turbo_spl spl
	)
)
createdialog hair_z
