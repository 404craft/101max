-render diffuse then AO
-limited usability

rollout timeout "timeout" width:128 height:136
(
	global c;
	global s;
	
	pickbutton ot_btn_cam "<camera>" pos:[10,24] width:112 height:16
	spinner ot_spn_fframe "" pos:[8,48] width:56 height:16 range:[-1000,1000,0] type:#integer
	spinner ot_spn_lframe "" pos:[64,48] width:56 height:16 range:[-1000,1000,0] type:#integer
	label lbl1 "timeOut" pos:[46,4] width:64 height:16
	label lbl2 "Label" pos:[72,56] width:0 height:0
	label ot_lbl_bottom "@101craft" pos:[39,116] width:53 height:13
	button ot_btn_render "render" pos:[32,96] width:64 height:16
	button ot_btn_hold "hold" pos:[16,72] width:96 height:16
	on ot_btn_cam picked obj do
	(
		if superclassof obj == camera then 
		(
		ot_btn_cam.text = obj.name
		c = obj
		)
		else messagebox ("select a camera")
	)
	on ot_btn_render pressed do
	(
		if c != undefined then
		(
		mr = renderers.current
		if mr != mental_ray_renderer() do mr = mental_ray_renderer()
		mr = renderers.current
		max hold;
		ot_btn_hold.text = "fetch";
		s = true;
		mr.FinalGatherEnable2 = on;
		mr.Enable_Material_Override = off;
		render camera: c fromframe: ot_spn_fframe.value toframe: ot_spn_lframe.value outputFile:(c.name + "D" + "_" + ".tga");
		delete lights
		mr.MaximumSamples = 1
		mr.FinalGatherEnable2 = off;
		mr.Enable_Material_Override = on;
		render camera: c fromframe: ot_spn_fframe.value toframe: ot_spn_lframe.value outputFile:(c.name + "AO" + "_" + ".tga");
		c = undefined
		ot_btn_cam.text = "<camera>"
		)
		else messagebox ("select a camera")
	)
	on ot_btn_hold pressed do
	(
		if s == true then
		(
		max fetch
		s = false
		ot_btn_hold.text = "hold"
		)
		else
		(
		max hold
		s = true
		ot_btn_hold.text = "fetch"
		)
	)
)
createdialog timeout
