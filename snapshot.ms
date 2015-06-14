-- alternative batch render dialogue
-- limited functionality plugin

rollout snap_shot "snapshot" width:160 height:300
(
	label sn_lbl_top "snapshot" pos:[17,8] width:50 height:16
	label sn_lbl_bottom "@101craft" pos:[90,275] width:57 height:17
	listbox sn_lbx_cam "" pos:[16,128] width:128 height:10
	dropdownList sn_ddl_cam "" pos:[16,32] width:128 height:21
	spinner sn_spn_lframe "" pos:[33,104] width:104 height:16 range:[-10000,10000,0] type:#integer
	spinner sn_spn_fframe "" pos:[32,80] width:104 height:16 range:[-10000,10000,0] type:#integer scale:0.1
	checkbox sp_chk_ao "AO" pos:[16,272] width:48 height:24
	button sp_btn_delete "update" pos:[88,56] width:48 height:16
	button sp_btn_append "append" pos:[24,56] width:48 height:16
	
	on sn_lbx_cam selected sel do
	(
		
		)
	on sn_lbx_cam doubleClicked sel do
	(
		
		)
	on sn_ddl_cam selected sel do
	(
		)
	on sn_spn_lframe changed val do
	(
		
		)
	on sn_spn_lframe buttondown do
	(
		
		)
	on sn_spn_lframe buttonup do
	(
		
		)
	on sn_spn_fframe changed val do
	(
		
		)
	on sn_spn_fframe buttondown do
	(
		
		)
	on sn_spn_fframe buttonup do
	(
		
		)
	on sp_chk_ao changed state do
	(
		
		)
	on sp_btn_delete pressed do
	(
		
		)
	on sp_btn_append pressed do
	(
		sn_ddl_cam.items = append sn_ddl_cam.items ($.name as string)
		)
)
createdialog snap_shot
