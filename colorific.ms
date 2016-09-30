fn dye arr c =
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
					c.hue = hasmultiplechildren.wirecolor.hue
					last = arr[a]
				)
			)
		)
		
		c.hue += offset * 0.3
		arr[a].wirecolor = c
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

try(destroydialog ::colorific)catch()
rollout colorific "" width:120 height:112
(
	colorPicker cp1 "" pos:[56,32] width:32 height:24
	button b0 "" pos:[96,8] width:16 height:72
	button b1 "" pos:[59,64] width:29 height:16 
 	checkbutton c1 "" pos:[59,8] width:29 height:16 checked:true
	spinner spn1 "" pos:[8,88] width:40 height:16
	slider sld1 "" pos:[8,8] width:16 height:80 range:[0,255,0] type:#integer orient:#vertical ticks:1
	slider sld2 "" pos:[24,8] width:16 height:80 range:[0,255,0] type:#integer orient:#vertical ticks:1
	slider sld3 "" pos:[40,8] width:16 height:80 range:[0,255,0] type:#integer orient:#vertical ticks:1
	checkbutton ckb19 "" pos:[59,88] width:53 height:16 checked:true

	on cp1 changed col do
	(
		objs = #($)
		order $.children objs
		dye objs cp1.color
	)
	on b0 pressed do
		(
	)
	on b1 pressed do
	(
		objs = #($)
		order $.children objs
		dye objs cp1.color
	)
)
createDialog colorific
