-render diffuse then ambient occlusion via material override in mental ray
-limited usability plugin

rollout timeout "timeout" width:128 height:160
(
	global c;
	global s;
	global numSeg = 4;
	global mr = renderers.current;
	
	pickbutton ot_btn_cam "<camera>" pos:[10,24] width:112 height:16
	spinner ot_spn_fframe "" pos:[8,48] width:56 height:16 range:[-1.67772e+007,1.67772e+007,0] type:#integer
	spinner ot_spn_lframe "" pos:[64,48] width:56 height:16 range:[-1.67772e+007,1.67772e+007,0] type:#integer
	label lbl1 "timeOut" pos:[45,4] width:64 height:16
	label lbl2 "Label" pos:[72,56] width:0 height:0
	label ot_lbl_bottom "@101craft" pos:[39,141] width:53 height:13
	button ot_btn_render "render" pos:[32,120] width:64 height:16
	button ot_btn_hold "hold" pos:[64,72] width:56 height:16
	checkbutton ot_ckb_power "online" pos:[8,72] width:56 height:16
	checkButton ot_ckb_mode "still" pos:[8,96] width:56 height:16
	checkButton ot_ckb_config "low" pos:[64,96] width:56 height:16 enabled: false
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
		if mr != mental_ray_renderer() do renderers.current = mental_ray_renderer()
		mr = renderers.current
		oM = mental_ray ()
		oM.name = "mr_ao"
		oM.surface = Ambient_Reflective_Occlusion__3dsmax ()
		oM.surface.name = "ao_map"
		oM.Surface.Samples = 128
		if mr.Override_Material == undefined do mr.Override_Material = oM
		max hold;
		ot_btn_hold.text = "fetch";
		s = true;
		mr.FinalGatherEnable2 = on;
		mr.Enable_Material_Override = off;
		render camera: c fromframe: ot_spn_fframe.value toframe: ot_spn_lframe.value outputFile:(c.name + "D01" + "_" + ".tga") progressbar: true;
		delete lights
		mr.MaximumSamples = 1
		mr.FinalGatherEnable2 = off;
		mr.Enable_Material_Override = on;
		render camera: c fromframe: ot_spn_fframe.value toframe: ot_spn_lframe.value outputFile:(c.name + "AO1" + "_" + ".tga") progressbar: true;
		c = undefined
		ot_btn_cam.text = "<camera>"
		if ot_ckb_power.state == true then doscommand "shutdown /s /f"
		else shelllaunch "explorer" (getdir #image)
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
	on ot_ckb_power changed state do
	(
		if ot_ckb_power.state == true then ot_ckb_power.text = "offline"
			else ot_ckb_power.text = "online"
	)
	on ot_ckb_mode changed state do
	(
		if ot_ckb_mode.state == true then 
		(
			try
			(
			mr.FGProjectionMode = 1
			mr.FGProjectionModeNumSegments = numSeg
			mr.IlluminationCacheMode = 1
			)
			catch()
			ot_ckb_mode.text = "movie"
			ot_ckb_config.enabled = true
		)
		else
		(
			ot_ckb_mode.text = "still"
			ot_ckb_config.text = "low"
			ot_ckb_config.state = false
			ot_ckb_config.enabled = false
			numSeg = 4
			try
			(
			mr.FGProjectionMode = 0
			mr.IlluminationCacheMode = 0
			)catch()
		)
	)
	on ot_ckb_config changed state do
	(
		if ot_ckb_config.state == true then
		(
			ot_ckb_config.text = "high"
			numSeg = 16
			mr = renderers.current
			try(mr.FGProjectionModeNumSegments = numSeg)catch()
			print(numSeg)
		)
		else
		(
			ot_ckb_config.text = "low"
			numSeg = 4
			mr = renderers.current
			try(mr.FGProjectionModeNumSegments = 4)catch()
		)
	)
)
createdialog timeout
