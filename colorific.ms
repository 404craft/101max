fn dye arr col =
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
				if arr[a].parent != hasmultiplechildren then				(
				offset += 1
				last = arr[a]
				)
				else if arr[a].parent == hasmultiplechildren do
				(
					offset = findItem arr hasmultiplechildren
					last = arr[a]
				)
				
			)
			arr[a].wirecolor = col / offset
		)
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
rollout colorific "" width:240 height:72
(
	colorPicker cp1 "" pos:[8,24] width:32 height:24 color:green
	colorPicker cp2 "" pos:[40,24] width:32 height:24 color:yellow
	colorPicker cp3 "" pos:[72,24] width:32 height:24 color:red
	colorPicker cp4 "" pos:[104,24] width:32 height:24 color:[255,0,255]
	colorPicker cp5 "" pos:[136,24] width:32 height:24 color:blue
	colorPicker cp6 "" pos:[168,24] width:32 height:24 color:[0,255,255]
	colorPicker cp7 "" pos:[200,24] width:32 height:24 color:black
	
	button b1 "" pos:[11,48] width:29 height:16 
	button b2 "" pos:[43,48] width:29 height:16
	button b3 "" pos:[75,48] width:29 height:16
	button b4 "" pos:[107,48] width:29 height:16
	button b5 "" pos:[139,48] width:29 height:16
	button b6 "" pos:[171,48] width:29 height:16
	button b7 "" pos:[203,48] width:29 height:16

	checkbutton c1 "" pos:[11,8] width:29 height:16
	checkbutton c2 "" pos:[43,8] width:29 height:16
	checkbutton c3 "" pos:[75,8] width:29 height:16
	checkbutton c4 "" pos:[107,8] width:29 height:16
	checkbutton c5 "" pos:[139,8] width:29 height:16
	checkbutton c6 "" pos:[171,8] width:29 height:16
	checkbutton c7 "" pos:[203,8] width:29 height:16

	on b1 pressed do
	(
		objs = #($)
		order $.children objs
		dye objs cp1.color
	)
)
createDialog colorific
