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
	
	if classof $ == line AND numsplines $ > 1 do
	(
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
)

fn sweep_spl val1 val2 val3 =
(
	arr1 = tst
	if val1 == true do arr1 = spl
	
	if m_normalize == undefined then
	(
		select arr1
		m_vdis = knot_dis true
		m_normalize = normalize_spl length:m_vdis
		modpanel.addmodtoselection m_normalize
	)
	 
	else if m_normalize != undefined do
	(
		m_normalize.length = val2
	)
	
	if m_sweep == undefined then
	(
		select arr1
		m_sweep = sweep current_built_in_shape:2
		modpanel.addmodtoselection m_sweep
		m_sweep[4].width = val3
		m_sweep[4].length = val3
		clearselection()
	)
	
	else if m_sweep != undefined do
	(
		if cpy.count > 0 do 
		(
			delete cpy
			cpy = #()
			unhide arr1
			if m_turbo != undefined do m_turbo = undefined
		)
		m_sweep[4].width = val3
		m_sweep[4].length = val3
	)
)

fn knot_dis val1 =
(
	m_vdis = (distance (getKnotPoint spl[1] 1 1) (getKnotPoint spl[1] 1 2)) * 2
	if val1 == true do hair_z.spn1_1.value = m_vdis
	return m_vdis
)

fn adjust_spl arr1 val1 val2 val3 =
(
	m_vdis = distance (getKnotPoint arr1[1] 1 1) (getKnotPoint arr1[1] 1 2)

	if cpy.count > 0 do 
	(
		delete cpy
		cpy = #()
	)
	
    for a = arr1.count to 1 by -1 do
    (
        for i in arr1[a].modifiers.count to 1 by -1 do
		(
			if arr1[a].modifiers[i] == val1 do 
			(
				maxops.CollapseNodeTo arr1[a] i off
				exit
			)
		)
		
		for n = (numknots arr1[a]) to 2 by -1 do
		(
			vdis = distance (getKnotPoint arr1[a] 1 n) (getKnotPoint arr1[a] 1 (n-1))
			if vdis < m_vdis - (vdis/20) do deleteKnot arr1[a] 1 n
		)
		updateshape arr1[a]
		
		if val3 == true do
		(
			if (numknots arr1[a]) < 3 do 
			(
			delete arr1[a]
			deleteitem arr1 a
			)
		)
		
		obj = copy arr1[a]
		hide arr1[a]
		append cpy obj
		convertto obj editable_poly
		sc = 1
				
		n_verts = polyOp.getNumVerts obj
		n_val = val2 / n_verts
		
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

fn taper_spl val1 val2 val3 =
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
		adjust_spl arr1 m_normalize val2 val3
	)
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
		
	hair_z.btn1.enabled = true
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
rollout hair_z "" width:88 height:240
(
	button btn1 "explode" pos:[8,32] width:72 height:16 toolTip:"separate splines" enabled:true
	checkbutton btn3_2 "×" pos:[8,96] width:16 height:16 toolTip:"erase splines with 2 knots" checked:true
	button btn5 "taper" pos:[8,112] width:72 height:16 toolTip:"scale up initial polygons"
	button btn6 "turbo" pos:[8,136] width:72 height:16 toolTip:"smoothen geometry"
	button btn7 "reset" pos:[8,200] width:72 height:16 toolTip:"delete all proxies"
	checkbutton btn8 "preview" pos:[8,8] width:72 height:16 toolTip:"finalize hairlines"

	button btn9_1 "group" pos:[8,160] width:72 height:16 toolTip:"group hairlines"
	checkbutton btn9_2 "x" pos:[8,176] width:24 height:16 toolTip:"x to origin" checked:true
	checkbutton btn9_3 "y" pos:[32,176] width:24 height:16 toolTip:"y to origin" checked:true
	checkbutton btn9_4 "z" pos:[56,176] width:24 height:16 toolTip:"z to origin" checked:true
	
	spinner spn1_1 "" pos:[8,56] width:56 height:16 range:[0,10000,0] type:#float scale:0.1
	button btn1_2 "•" pos:[64,56] width:16 height:16 toolTip:"distance between knots"
	spinner spn2_1 "" pos:[8,72] width:56 height:16 range:[0,10000,32] type:#float scale:0.1
	button btn2_2 "¤" pos:[64,72] width:16 height:16 toolTip:"apply selected values"

	spinner spn3 "" pos:[24,96] width:56 height:16 range:[0,10,0.01] type:#float scale:0.01
	label lbl1 "101craft" pos:[24,220] width:40 height:16
	
	on btn1 pressed do
	(
		explode_spl btn8.state
		btn1.enabled = false
	)
	on spn1_1 changed val do
	(
		sweep_spl btn8.state spn1_1.value spn2_1.value
	)
	on btn1_2 pressed do
	(
		m_vdis = knot_dis true
		sweep_spl btn8.state m_vdis spn2_1.value
	)
	on spn2_1 changed val do
	(
		sweep_spl btn8.state spn1_1.value spn2_1.value
	)
	on btn2_2 pressed do
	(
		sweep_spl btn8.state spn1_1.value spn2_1.value
	)
	on btn3_2 changed state do
	(
		if state == false then
		(
		btn3_2.text = "+"
		)
		else
		(
		btn3_2.text = "×"
		)
	)
	on btn5 pressed do
	(
		taper_spl btn8.state spn3.value btn3_2.state
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
		)
		else
		(
		btn8.text = "final"
		)
	)
	on btn9_1 pressed do
	(
		h = group cpy
		cpy.wirecolor = gray
		cpy = #()
		if btn9_2.state == true do h.pivot.x = 0
			if btn9_3.state == true do h.pivot.y = 0
				if btn9_4.state == true do h.pivot.z = 0
		h.name = "hair_group"
		reset_spl 2 h
		btn8.state = false
	)
)
createdialog hair_z

--for h in hair_z.controls do try(h.tooltip = "")catch()
