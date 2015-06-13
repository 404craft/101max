-- assign same random material across all group members
-- assign a different random material to each individual member of the same group
-- define source materials by defining material editor slot ranges 1-2 to 1-24
-- i.e. use this script to apply a random material to hundreds of /groups of objects/
-- limited functionality plugin

rollout radMat "radMat" width:88 height:146
(
	checkbutton rm_chk_mode "mode" pos:[8,32] width:72 height:24 toolTip:"assign same material to all group members?"
	label rm_lbl_top "radMat" pos:[28,6] width:80 height:18
	button rm_btn_exe "execute" pos:[8,88] width:72 height:24 toolTip:"confirm operation"
	spinner rm_spn_range "" pos:[8,64] width:72 height:16 range:[2,24,2] type:#integer scale:0.1
	label rm_lbl_bottom "@101craft" pos:[17,125] width:54 height:17
	on rm_chk_mode changed state do
	(
		if state == true then rm_chk_mode.text = "group"
		else rm_chk_mode.text = "single"
	)
	on rm_btn_exe pressed do
	(
		if rm_chk_mode.state == true then
		(
			for n in selection do n.material = meditmaterials [random 1 rm_spn_range.value]
				
			for p in selection where isgrouphead p do
			(
			groupmaterial = meditmaterials [random 1 rm_spn_range.value] /*material editor slot 1 to material editor slot 3*/
			for c in p where isgroupmember c do c.material = groupmaterial
			)
		)
		else for n in selection do n.material = meditmaterials [random 1 rm_spn_range.value]
	)
)
createdialog radMat
