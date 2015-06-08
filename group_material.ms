-- assign same random material across all group members
-- assign a different random material to each individual member of the same group
-- define source materials by defining material editor slot ranges 1-2 to 1-24
-- i.e. use this script to apply a random material to hundreds of /groups of objects/

mUpper = 2
rollout radMat "radMat" width:96 height:168
(
	checkbutton btn_mode "mode" pos:[8,32] width:80 height:31 toolTip:"assign same material to all group members?"
	label lbl_top "radMat" pos:[30,5] width:80 height:18
	button btn_exe "execute" pos:[8,112] width:80 height:32 toolTip:"confirm operation"
	spinner btn_spn "" pos:[16,80] width:64 height:16 range:[2,24,2] type:#integer scale:0.1
	on btn_mode changed state do
	(
		if state == true then btn_mode.text = "group"
		else btn_mode.text = "single"
	)
	on btn_exe pressed do
	(
		if btn_mode.state == true then
		(
			for p in selection where isgrouphead p do
			(
			groupmaterial = meditmaterials [random 1 mUpper] /*material editor slot 1 to material editor slot 3*/
			for c in p where isgroupmember c do c.material = groupmaterial
			)
		)
		
		else for n in selection do n.material = meditmaterials [random 1 mUpper]
	)
	on btn_spn changed val do
	(
	mUpper = btn_spn.value
	)
	on btn_spn buttondown do
	(
	mUpper = btn_spn.value
	)
	on btn_spn buttonup do
	(
	mUpper = btn_spn.value
	)
)

createdialog radMat
