-- assign same random material across all group members
-- assign a different random material to each individual member of the same group
-- assign same random material to objects based on their distance from each other
-- define source materials by defining material editor slot ranges 1-2 to 1-24
-- i.e. use this script to apply a random material to hundreds of /groups of objects/
-- limited functionality plugin

/*
for n = 1 to 24 do 
(
tMat = StandardMaterial()
tMat.diffuse = random black white
setMeditMaterial n tMat
)
*/

try(destroydialog ::radMat)catch()

rollout radMat "" width:96 height:138
(
	checkbutton rm_chk_mode "node" pos:[16,72] width:64 height:16 toolTip:"assign same material to all group members?"
	label rm_lbl_top "radMat" pos:[33,5] width:80 height:18
	button rm_btn_exe "assign" pos:[24,96] width:48 height:16 toolTip:"confirm operation"
	spinner rm_spn_rng_btm "" pos:[48,24] width:40 height:16 range:[2,24,2] type:#integer
	label rm_lbl_bottom "@101craft" pos:[24,117] width:54 height:17
	spinner rm_spn_rng_top "" pos:[8,24] width:40 height:16 range:[1,23,1] type:#integer
	spinner rm_spn_distance "" pos:[24,48] width:64 height:16 enabled:false range:[-1e+006,1e+006,0]
	checkbutton rm_ckb_distance "•" pos:[8,48] width:16 height:16 toolTip:"defined distance between objects"
	
	on rm_chk_mode changed state do
	(
		if state == true then rm_chk_mode.text = "group"
		else rm_chk_mode.text = "node"
	)
	on rm_btn_exe pressed do
	(
		if rm_chk_mode.state == true then
		(
			for n in selection do n.material = meditmaterials [random rm_spn_rng_top.value rm_spn_rng_btm.value]
				
			for p in selection where isgrouphead p do
			(
			groupmaterial = meditmaterials [random rm_spn_rng_top.value rm_spn_rng_btm.value]
			for c in p where isgroupmember c do c.material = groupmaterial
			)
			
			if rm_ckb_distance.state == true then
			(
			oArr = objects as array
				for o = 1 to oArr.count do 
				(
					nArr = objects as array
					deleteItem nArr o
					if rm_spn_distance.value > 0 do for n = 1 to nArr.count where (distance oArr[o] nArr[n] <= rm_spn_distance.value) do try(oArr[o].material = groupmaterial)catch()
					if rm_spn_distance.value < 0 do for n = 1 to nArr.count where (distance oArr[o] nArr[n] >= -1 * rm_spn_distance.value) do try(oArr[o].material = groupmaterial)catch()
				)
			)
		)
		else for n in selection do n.material = meditmaterials [random rm_spn_rng_top.value rm_spn_rng_btm.value]
	)
	on rm_spn_rng_btm changed val do
	(
	vDiff = rm_spn_rng_btm.value - rm_spn_rng_top.value
	if  vDiff == 0 do rm_spn_rng_top.value -=1
	)
	on rm_spn_rng_btm buttondown do
	(
	if  rm_spn_rng_btm.value <= rm_spn_rng_top.value do rm_spn_rng_top.value = rm_spn_rng_btm.value - 1
	)
	on rm_spn_rng_btm buttonup do
	(
	vDiff = rm_spn_rng_btm.value - rm_spn_rng_top.value
	if  vDiff == 0 do rm_spn_rng_top.value -=1
	if  rm_spn_rng_btm.value <= rm_spn_rng_top.value do rm_spn_rng_top.value = rm_spn_rng_btm.value - 1
	)
	on rm_spn_rng_top changed val do
	(
	vDiff = rm_spn_rng_top.value - rm_spn_rng_btm.value
	if  vDiff == 0 do rm_spn_rng_btm.value +=1
	)
	on rm_spn_rng_top buttondown do
	(
	if  rm_spn_rng_top.value >= rm_spn_rng_btm.value do rm_spn_rng_btm.value = rm_spn_rng_top.value + 1
	)
	on rm_spn_rng_top buttonup do
	(
	vDiff = rm_spn_rng_top.value - rm_spn_rng_btm.value
	if  vDiff == 0 do rm_spn_rng_btm.value +=1
	if  rm_spn_rng_top.value >= rm_spn_rng_btm.value do rm_spn_rng_btm.value = rm_spn_rng_top.value + 1
	)
	on rm_ckb_distance changed state do
	(
		case state of
		(
			true: rm_spn_distance.enabled = true
			false: rm_spn_distance.enabled = false
		)
	)
)
createdialog radMat
