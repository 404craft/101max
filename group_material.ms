-- assign same random material across all group members
-- assign a different random material to each individual member of the same group
-- define source materials by defining material editor slot ranges 1-2 to 1-24
-- i.e. use this script to apply a random material to hundreds of /groups of objects/
-- limited functionality plugin

global mUpper

rollout radMat "radMat" width:88 height:144
(
	checkbutton btn_mode "mode" pos:[8,32] width:72 height:24 toolTip:"assign same material to all group members?"
	label lbl_top "radMat" pos:[28,6] width:80 height:18
	button btn_exe "execute" pos:[8,88] width:72 height:24 toolTip:"confirm operation"
	spinner btn_spn "" pos:[8,64] width:72 height:16 range:[2,24,2] type:#integer scale:0.1
	label lbl_bottom "@101craft" pos:[17,125] width:54 height:17
	on btn_mode changed state do
	(
		if state == true then btn_mode.text = "group"
		else btn_mode.text = "single"
	)
	on btn_exe pressed do
	(
		if btn_mode.state == true then
		(
			for n in selection do n.material = meditmaterials [random 1 mUpper]
				
			for p in selection where isgrouphead p do
			(
			mUpper = btn_spn.value
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
