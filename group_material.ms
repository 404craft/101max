-- assign same random material across all group members
-- assign a different random material to each individual member of the same group
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

rollout radMat "" width:88 height:146
(
	checkbutton rm_chk_mode "mode" pos:[8,32] width:72 height:24 toolTip:"assign same material to all group members?"
	label rm_lbl_top "radMat" pos:[28,6] width:80 height:18
	button rm_btn_exe "assign" pos:[8,88] width:72 height:24 toolTip:"confirm operation"
	spinner rm_spn_rng_btm "" pos:[48,64] width:40 height:16 range:[2,24,2] type:#integer
	label rm_lbl_bottom "@101craft" pos:[17,125] width:54 height:17
	spinner rm_spn_rng_top "" pos:[0,64] width:40 height:16 range:[1,23,1] type:#integer
	
	on rm_chk_mode changed state do
	(
		if state == true then rm_chk_mode.text = "group"
		else rm_chk_mode.text = "single"
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
		)
		else for n in selection do n.material = meditmaterials [random rm_spn_rng_top.value rm_spn_rng_btm.value]
	)
	
	on rm_spn_rng_btm changed val do
	(
	vDiff = rm_spn_rng_btm.value - rm_spn_rng_top.value
	if  vDiff == 0 do rm_spn_rng_top.value -=1
	)
	
	on rm_spn_rng_btm buttondown  do
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
	
)
createdialog radMat
