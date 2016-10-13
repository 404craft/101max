--adjust wirecolor en masse i.e. color & grade object hierarchies automatically
--universal, easy to use colorizer

fn dye arr col gap adv mode debug =
(  
	offset = 1
	last = arr[1]
	cl = col.hue + adv
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
						if f == hasmultiplechildren do
						(	
						primeLogged = true
						)
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
					cl = hasmultiplechildren.wirecolor.h
					last = arr[a]
				)
			)
		)
		
		if arr[a].children.count > 1 do
		(
			if mode == 2 do
			(
			cl +=50
			)
		)
		
		if debug do print ("color step: " + adv as string)
		if debug do print ("current col: " + cl as string)
		if debug do print ("offset: " + offset as string)
		if debug do print ("gap: " + gap as string)
		cl += offset * gap * mode
		if cl > 255.0 do cl = cl - 255.0
		if debug do print ("updated col: " + cl as string)
		col.hue = cl
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

fn flood src obj objs col gap lot step mode =
(
	if obj != undefined do
	(
		for o in obj do
		(
			if src != undefined do
			(  if isvalidnode src == false do
				(
				colorific.b_src.text = "-"
				src = undefined
				)
			)
			if src == undefined do src = o
		if src != undefined AND o != src do col = src.wirecolor
		objs = #(o)
		if lot do order o.children objs
		if step == true then adv = 15.0
			else adv = 0
		dye objs col gap adv mode false
		)
	)	
)

global source = undefined
global objs = #()
global collection = #()
global mode = 1

try(destroydialog ::colorific)catch()

rollout colorific "" width:120 height:152
(
	button btn_101 "look@101craft" pos:[8,8] width:104 height:16 toolTip:"visit 101craft.com"
	colorPicker cp "" pos:[56,56] width:32 height:24 color:[0,128,255] toolTip:"main color"
	button b_con "•" pos:[96,32] width:16 height:56 toolTip:"adjust controls"
	checkbutton ckb_step "" pos:[96,88] width:16 height:16 toolTip:"initial interval"
	checkbutton ckb_lot "" pos:[59,88] width:29 height:16 checked:true toolTip:"local or global"
	button b_src "-" pos:[58,32] width:29 height:16 toolTip:"source object"
	spinner spn1 "" pos:[8,112] width:40 height:16 range:[0.1,10.0,0.3] type:#float scale:0.01 toolTip:"color modifier"
	spinner spn2 "" pos:[8,128] width:40 height:16 range:[1,2,1] type:#integer toolTip:"mode h/s/v"
	slider sld1 "" pos:[8,32] width:16 height:80 range:[0,255,0] type:#integer orient:#vertical ticks:1 toolTip:".red channel"
	slider sld2 "" pos:[24,32] width:16 height:80 range:[0,255,128] type:#integer orient:#vertical ticks:1 toolTip:".green channel"
	slider sld3 "" pos:[40,32] width:16 height:80 range:[0,255,255] type:#integer orient:#vertical ticks:1 toolTip:".blue channel"
	button b_up "«" pos:[59,112] width:16 height:16 toolTip:"up hierarchy"
	button b_down "»" pos:[96,112] width:16 height:16 toolTip:"down hierarchy"
	button b_mid "•" pos:[75,112] width:21 height:16 toolTip:"next child"
	button b_ini "•" pos:[59,128] width:53 height:16 toolTip:"execute"
	on cp changed col do
	(
		sld1.value = col.r
		sld2.value = col.g
		sld3.value = col.b
		flood source selection objs col spn1.value ckb_lot.state ckb_step.state spn2.value
	)
	on b_con pressed do
	(
		if $ != undefined then
		(

			for a in $ as array where classof a.transform.controller == link_constraint do
			(
				if a.transform.controller.getnumtargets() > 0 do
				(
				a.wirecolor = (a.transform.controller.getnode 1).wirecolor
				)
			)

			for a in $ as array where classof a.pos.controller == position_list do
			(
				for b = 1 to a.pos.controller.count do 
				(
					if classof a.pos.controller[b].controller == Position_Constraint do
					(
					topWeight = 0
					topIndex = 1
						for t = 1 to a.pos.controller[b].controller.getnumtargets() do
						(
								if (a.pos.controller[b].controller.getWeight t) > topWeight do
								(
								topIndex = t
								)
						)
					a.wirecolor = (a.pos.controller[b].controller.getnode topIndex).wirecolor
					)
				)
			)

			for a in $ as array where classof a.rotation.controller == rotation_list do
			(
				for b = 1 to a.rotation.controller.count do 
				(
					if classof a.rotation.controller[b].controller == Orientation_Constraint do
					(
					topWeight = 0
					topIndex = 1
						for t = 1 to a.rotation.controller[b].controller.getnumtargets() do
						(
								if (a.rotation.controller[b].controller.getWeight t) > topWeight do
								(
								topIndex = t
								)
						)
					a.wirecolor = (a.rotation.controller[b].controller.getnode topIndex).wirecolor
					)
				)
			)
		)
		else if $ == undefined do 
		(
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
	flood source selection objs cp.color spn1.value ckb_lot.state ckb_step.state spn2.value
	)
	on sld2 changed val do
	(
	cp.color.g = val
	flood source selection objs cp.color spn1.value ckb_lot.state ckb_step.state spn2.value
	)
	on sld3 changed val do
	(
	cp.color.b = val
	flood source selection objs cp.color spn1.value ckb_lot.state ckb_step.state spn2.value
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
	
	on b_mid pressed do
	(
		sel = #()
		s = 1
		for n = 1 to selection.count do if selection[n] != undefined AND selection[n].parent.children.count > 1 do
		(
			for c = 1 to selection[n].parent.children.count do if selection[n] == selection[n].parent.children[c] do s = c + 1
			if s > selection[n].parent.children.count do s = 1
			append sel selection[n].parent.children[s]
		)
		select sel
	)
	
	on b_down pressed do
	(
		sel = #()
		tmp = #()
		rst = false
		s = 1
		for n = 1 to selection.count do if selection[n] != undefined AND selection[n].children.count > 0 do
		(
			if selection[n].children.count > 1 do
			(
			for c in collection do for i in c do if i == selection[n] then
			(
				id = finditem collection c
				s = collection[id][2] + 1
				if s > i.children.count do s = 1
				collection[id][2] = s
			)
			else if i != selection[n] do
			(
				rst = true
			)
			if rst do collection = #()
			tmp = #(selection[n],s)
			append collection tmp
			)
			append sel selection[n].children[s]
		)
		select sel
	)
	on b_ini pressed do
	(
		flood source selection objs cp.color spn1.value ckb_lot.state ckb_step.state spn2.value
	)
	
	on spn1 changed val do
	(
		flood source selection objs cp.color val ckb_lot.state ckb_step.state spn2.value
	)
	
	on spn2 changed val do
	(
		if val != mode do
		(
		mode = val
		flood source selection objs cp.color spn1.value ckb_lot.state ckb_step.state val
		)
	)
)
createDialog colorific
