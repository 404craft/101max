--simple programs & one-liners I wrote when working on animations or games at one point or another used to speed up my workflow

/*----------------------------------------------------------------------------------------------------------------------*/
--move list position position controller's animation frames en masse
for o in selection do
(
	t = getkeytime o.pos.controller[2].controller 2
	o.pos.controller.setactive 2
	animate on at time t o.position.y = o.position.y + -3000
)

--move position controller's animation frames en masse
for o in selection do
(
	t = getkeytime o.pos.controller 1
	animate on
	at time t o.position.y = o.position.y + 3000
)
/*----------------------------------------------------------------------------------------------------------------------*/
blueObj = #()
redObj = #()
yellowObj = #()

try(destroydialog ::colorArray)catch()
rollout colorArray "" width:144 height:144
(
	button btn1_blue "blue" pos:[8,8] width:124 height:30
	button btn2_red "red" pos:[8,42] width:124 height:30
	button btn3_yellow "yellow" pos:[8,72] width:124 height:30
	button btn_white "white" pos:[8,104] width:124 height:30
	on btn1_blue pressed do
	(		
	for n in selection as array do (setuserpropbuffer n "blue"; n.wirecolor = blue)
	)
	on btn2_red pressed do
	(	
	for n in selection as array do (setuserpropbuffer n "red"; n.wirecolor = red)
	)
	on btn3_yellow pressed do
	(
	for n in selection as array do (setuserpropbuffer n "yellow"; n.wirecolor = yellow)
	)
	on btn_white pressed do
	(
	for n in selection as array do (setuserpropbuffer n "white"; n.wirecolor = white)
	)
)

createdialog colorArray
/*----------------------------------------------------------------------------------------------------------------------*/
geo = #()
geo = for g in geometry as array where classof g == chamferbox collect g
for n = 1 to geo.count do geo[n].baseobject = geo[1].baseobject
/*----------------------------------------------------------------------------------------------------------------------*/
global modify

fn rndVar v =
(
	m = random 0 1
	if m == 0 do var= -1
	modify = (random 0 v) * m
	return m
)

for o in geometry do
(
	
	b_cl = (color 29 125 243)
	r_cl = (color 248 24 24)
	y_cl = (color 255 234 0)
	
	if (random 0 1) == 0 do
	(
		v = 20
		modify = 0
		rndVar v
		
		if (255 - modify) <= 255 AND (0 + modify) >= 0 do b_cl.r = b_cl.r - modify
		rndVar v
		if (255 - modify) <= 255 AND (0 + modify) >= 0 do b_cl.g = b_cl.g - modify
		rndVar v
		if (255 - modify) <= 255 AND (0 + modify) >= 0 do b_cl.b = b_cl.b - modify
		rndVar v
		
		if (255 - modify) <= 255 AND (0 + modify) >= 0 do r_cl.r = r_cl.r - modify
		rndVar v
		if (255 - modify) <= 255 AND (0 + modify) >= 0 do r_cl.g = r_cl.g - modify
		rndVar v
		if (255 - modify) <= 255 AND (0 + modify) >= 0 do r_cl.b = r_cl.b - modify
		rndVar v
		
		if (255 - modify) <= 255 AND (0 + modify) >= 0 do y_cl.r = y_cl.r - modify
		rndVar v
		if (255 - modify) <= 255 AND (0 + modify) >= 0 do y_cl.g = y_cl.g - modify
		rndVar v
		if (255 - modify) <= 255 AND (0 + modify) >= 0 do y_cl.b = y_cl.b - modify
	)
	if getuserpropbuffer o == "blue" do o.wirecolor = b_cl
	if getuserpropbuffer o == "red" do o.wirecolor = r_cl
	if getuserpropbuffer o == "yellow" do o.wirecolor = y_cl
)
/*----------------------------------------------------------------------------------------------------------------------*/
randomObjs = #()
for o in selection as array do
(
	if (random 0 1) == 0 do appendifunique randomObjs o
)
/*----------------------------------------------------------------------------------------------------------------------*/
for n in selection do
(
	gMat = StandardMaterial()
	gMat.name = n.name
	gMat.diffuse = n.wirecolor
	gMat.specularlevel = 35
	gMat.glossiness = 40
	n.material = gMat
	
	animate on for t in 0 to 1000 by 10 do
	at time t 
	(
		if n.material.selfIllumAmount == 0 then n.material.selfIllumAmount = 100
			else n.material.selfIllumAmount = 0
	)	
)
/*----------------------------------------------------------------------------------------------------------------------*/
c = 0
alias = 1
b = 200

rollout stepmat "" width:120 height:72
(
	button btn1 "execute" pos:[8,8] width:103 height:58
	on btn1 pressed  do
	(
		mat = Arch___Design__mi ()
		mat.name = "gray_0" + (alias as string)
		mat.diff_color = color (b+c) (b+c) (b+c) (b+c)
		for n in selection do
		(
		n.material = mat
		)
		alias+=1
		c+=15
	)
)
createdialog stepmat
/*----------------------------------------------------------------------------------------------------------------------*/
for m in scenematerials do print (classof m)
/*----------------------------------------------------------------------------------------------------------------------*/
for o in objects do
(
	try
	(
		if o.material != undefined do
		(
			if classof o.material != Arch___Design__mi() do
			(
			mat = Arch___Design__mi ()
			c = o.material.diffuse
			o.material = mat
			o.material.diff_color = c
			)
		)
	)
	catch()
)
/*----------------------------------------------------------------------------------------------------------------------*/
for m in scenematerials do
(
	try
	(
	--m.specularLevel = 25
	--m.glossiness = 80
	m.refl_weight = 0.3
	m.refl_gloss = 0.75
	)
	catch()
)
/*----------------------------------------------------------------------------------------------------------------------*/
for obj in selection do
(
	for m in obj.modifiers do
	(
	if m.enabled == false do deletemodifier obj m
	)
)
/*----------------------------------------------------------------------------------------------------------------------*/
global c = 1
rollout increname "" width:162 height:71
(
	button btn1 "execute" pos:[21,15] width:106 height:46
	on btn1 pressed do
	(
	c += 1
	$.name = $.name + c as string
	)
)
createdialog increname
/*----------------------------------------------------------------------------------------------------------------------*/
render fromframe: 0 toframe: 120 outputFile:("D01" + "_" + ".tga") progressbar: true
delete lights
mr = renderers.current
mr.MaximumSamples = 1
mr.FinalGatherEnable2 = false
mr.Enable_Material_Override = true
render fromframe: 0 toframe: 120 outputFile:("AO1" + "_" + ".tga") progressbar: true
/*----------------------------------------------------------------------------------------------------------------------*/
sv = for i in $.selectedVerts collect i.index
for n=1 to sv.count do $.verts[sv[n]].pos.y = -123.123
/*----------------------------------------------------------------------------------------------------------------------*/
