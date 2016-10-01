--adjust geometry wirecolor en masse i.e. color character rigs automatically

fn dye arr col gap adv debug =
(  
	offset = 1
	last = arr[1]
	col.hue += adv
	primes = #()
	for a = 1 to arr.count do 
	(
	if debug do print ("start-------------------------------------------------------------")
		if arr[a].parent != undefined do
		(
			if arr[a].parent.children.count > 1 do
			(	
			hasmultiplechildren = arr[a].parent
			tmp = #(hasmultiplechildren,offset)
			primeLogged = false
			for p in primes do
				for f in p do
					if f == hasmultiplechildren do primeLogged = true
			if primeLogged == false do append primes tmp
			if debug do print (hasmultiplechildren.name + " has " + arr[a].parent.children.count as string + " children")
			if debug do print ("offset: " + offset as string)
			)
			if debug do print ("object: " + arr[a].name)
			if arr[a].parent != last.parent do
			(
				if arr[a].parent != hasmultiplechildren then
				(
				offset += 1
				last = arr[a]
				)
				else if arr[a].parent == hasmultiplechildren do
				(
					if debug do print ("twin-------------------------------")
					for p in primes do
						for f in p do
							if f == hasmultiplechildren do offset = p[2]
					if debug do print ("updated offset: " + offset as string)
					col.hue = hasmultiplechildren.wirecolor.hue
					last = arr[a]
				)
			)
		)
		if debug do print ("color step: " + adv as string)
		if debug do print ("current hue: " + col.hue as string)
		if debug do print ("offset: " + offset as string)
		if debug do print ("gap: " + gap as string)
		col.hue += offset * gap
		if debug do print ("updated hue: " + col.hue as string)
		arr[a].wirecolor = col
	)
	if debug do print ("main nodes-------------------------")
	if debug do for p in primes do print p
)

fn order progeny arr =
(
	for p in progeny do
	(
	append arr p
	order p.children arr
	)
)

fn flood src obj objs col gap lot step =
(
	if obj != undefined do
	(
		for o in obj do
		(
		if src == undefined do src = o
		if src != undefined AND o != src do col = src.wirecolor
		objs = #(o)
		if lot do order o.children objs
		if step == true then adv = 15.0
			else adv = 0
		dye objs col gap adv false
		)
	)	
)

global source = undefined
global objs = #()

try(destroydialog ::colorific)catch()
rollout colorific "" width:120 height:112
(
	colorPicker cp "" pos:[56,32] width:32 height:24 color:[255,255,0]
	button b_con "•" pos:[96,8] width:16 height:56
	checkbutton ckb_step "" pos:[96,64] width:16 height:16
	checkbutton ckb_lot "" pos:[59,64] width:29 height:16 checked:true
	button b_src "-" pos:[58,8] width:29 height:16
	spinner spn "" pos:[8,88] width:40 height:16 range:[0.1,10,0.3]
	slider sld1 "" pos:[8,8] width:16 height:80 range:[0,255,0] type:#integer orient:#vertical ticks:1
	slider sld2 "" pos:[24,8] width:16 height:80 range:[0,255,0] type:#integer orient:#vertical ticks:1
	slider sld3 "" pos:[40,8] width:16 height:80 range:[0,255,0] type:#integer orient:#vertical ticks:1
	button b_up "«" pos:[59,88] width:16 height:16
	button b_down "»" pos:[96,88] width:16 height:16
	button b_ini "•" pos:[75,88] width:21 height:16
	
	on cp changed col do
	(
		sld1.value = col.r
		sld2.value = col.g
		sld3.value = col.b
		flood source selection objs col spn.value ckb_lot.state ckb_step.state
	)
	on b_con pressed do
	(
		if $ != undefined then
		(
			l_controllers = #()
			for o in $ as array where classof o.transform.controller == link_constraint do
			(
				if o.transform.controller.getnumtargets() > 0 do
				(
				o.wirecolor = (o.transform.controller.getnode 1).wirecolor
				)
			)
			p_controllers = #()
			for i in $ as array where classof i.pos.controller == position_list do
			(
				for c = 1 to i.pos.controller.count do 
				(
					if classof i.pos.controller[c].controller == Position_Constraint do
					(
					topWeight = 0
					topIndex = 1
						for t = 1 to i.pos.controller[c].controller.getnumtargets() do
						(
								if (i.pos.controller[c].controller.getWeight t) > topWeight do
								(
								topIndex = t
								)
						)
					i.wirecolor = (i.pos.controller[c].controller.getnode topIndex).wirecolor
					)
				)
			)
		)
		else if $ == undefined do 
		(
		controls = #()
		b_con.text = "-"
		)
	)
	on b_src pressed do
	(
		if $ != undefined then
		(
		source = $
		b_src.text = "+"
		)
		else if $ == undefined do 
		(
		source = undefined
		b_src.text = "-"
		)
	)
	on sld1 changed val do
	(
	cp.color.r = val
	flood source selection objs cp.color spn.value ckb_lot.state ckb_step.state
	)
	on sld2 changed val do
	(
	cp.color.g = val
	flood source selection objs cp.color spn.value ckb_lot.state ckb_step.state
	)
	on sld3 changed val do
	(
	cp.color.b = val
	flood source selection objs cp.color spn.value ckb_lot.state ckb_step.state
	)
	on b_up pressed do
	(
		sel = #()
		for n = 1 to selection.count do if selection[n] != undefined AND selection[n].parent != undefined do
		(
			append sel selection[n].parent
		)
		select sel
	)
	on b_down pressed do
	(
		sel = #()
		for n = 1 to selection.count do if selection[n] != undefined AND selection[n].children.count > 0 do
		(
			append sel selection[n].children[1]
		)
		select sel
	)
	on b_ini pressed do
	(
		flood source selection objs cp.color spn.value ckb_lot.state ckb_step.state
	)
)
createDialog colorific
