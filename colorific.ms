--shade wirecolor en masse i.e. color character rigs automatically
--new plugin under development


fn dye arr col gap =
(  
	offset = 1
	last = arr[1]

	for a = 1 to arr.count do 
	(
		if arr[a].parent != undefined do
		(
			if arr[a].parent.children.count > 1 do
			(	
			hasmultiplechildren = arr[a].parent
			)
			
			if arr[a].parent != last.parent do
			(
				if arr[a].parent != hasmultiplechildren then
				(
				offset += 1
				last = arr[a]
				)
				else if arr[a].parent == hasmultiplechildren do
				(
					offset = findItem arr hasmultiplechildren
					col.hue = hasmultiplechildren.wirecolor.hue
					last = arr[a]
				)
			)
		)
		
		col.hue += offset * gap
		arr[a].wirecolor = col
	)
)

fn order progeny arr =
(
	for p in progeny do
	(
	append arr p
	order p.children arr
	)
)

fn flood src obj objs col gap =
(
	if src == undefined do src = obj
	if src != undefined do
	(
	objs = #(src)
	order src.children objs
	dye objs col gap
	)
)

global source
global objs = #()

try(destroydialog ::colorific)catch()
rollout colorific "" width:120 height:112
(
	colorPicker cp "" pos:[56,32] width:32 height:24 color:[0,0,0]
	button b_con "-" pos:[96,8] width:16 height:72
	button b1 "" pos:[59,64] width:29 height:16 
 
	button b_src "-" pos:[58,8] width:29 height:16
	spinner spn "" pos:[8,88] width:40 height:16 range:[0.1,10,0.3]
	slider sld1 "" pos:[8,8] width:16 height:80 range:[0,255,0] type:#integer orient:#vertical ticks:1
	slider sld2 "" pos:[24,8] width:16 height:80 range:[0,255,0] type:#integer orient:#vertical ticks:1
	slider sld3 "" pos:[40,8] width:16 height:80 range:[0,255,0] type:#integer orient:#vertical ticks:1
	button b_ini "" pos:[59,88] width:53 height:16 checked:true

	on cp changed col do
	(
		sld1.value = col.r
		sld2.value = col.g
		sld3.value = col.b
		flood source $ objs col spn.value
	)
	on b_con pressed do
	(
		if $ != undefined then
		(
			for o in $ as array do
			(
			controls = $ as array
			b_con.text = "+"
			)
		)
		else if $ == undefined do 
		(
		controls = #()
		b_con.text = "-"
		)
	)
	on b_ini pressed do
	(
		flood source $ objs cp.color spn.value
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
	flood source $ objs cp.color spn.value
	)
	on sld2 changed val do
	(
	cp.color.g = val
	flood source $ objs cp.color spn.value
	)
	on sld3 changed val do
	(
	cp.color.b = val
	flood source $ objs cp.color spn.value
	)
)
createDialog colorific
