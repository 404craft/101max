-render diffuse and ambient occlusion (via material override) passes consecutively in mental ray
-limited usability plugin

try(destroydialog ::timeout)catch()

rollout timeout "timeout" width:128 height:160
(
	global c
	global numSeg = 4
	global mProject = 0
	global iMode = 0
	global fframe
	global lframe
	
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
		if classof renderers.current != mental_ray_renderer do renderers.current = mental_ray_renderer()
		mr = renderers.current
		-- generic override mat
		oM = mental_ray ()
		oM.name = "mr_ao"
		oM.surface = Ambient_Reflective_Occlusion__3dsmax ()
		oM.surface.name = "ao_map"
		oM.Surface.Samples = 128

		mr.FinalGatherEnable2 = true
		mr.FGProjectionMode = mProject
		mr.IlluminationCacheMode = iMode
		mr.FGProjectionModeNumSegments = numSeg
		mr.Enable_Material_Override = false
			
		fframe = ot_spn_fframe.value
		lframe = ot_spn_lframe.value
			
		if ot_spn_fframe.value > ot_spn_lframe.value do 
		(
		fframe = ot_spn_lframe.value
		lframe = ot_spn_fframe.value
		)
		
		render camera: c fromframe: fframe toframe: lframe outputFile:(c.name + "D01" + "_" + ".tga") progressbar: true
		-- render ao
		lights.enabled = off
		mr.MaximumSamples = 1
		mr.FinalGatherEnable2 = false
		mr.Enable_Material_Override = true
		if mr.Override_Material == undefined do mr.Override_Material = oM
		render camera: c fromframe: fframe toframe: lframe outputFile:(c.name + "AO1" + "_" + ".tga") progressbar: true
		c = undefined
		ot_btn_cam.text = "<camera>"
		lights.enabled = on
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
		if classof renderers.current != mental_ray_renderer do renderers.current = mental_ray_renderer()
		mr = renderers.current
		mr.FinalGatherEnable2 = true
		case ot_ckb_mode.state of
		(
		true:
			(
			ot_ckb_mode.text = "movie"
			ot_ckb_config.enabled = true
			mProject = 1
			mr.FGProjectionMode = mProject
			iMode = 1
		    mr.IlluminationCacheMode = iMode
			mr.FGProjectionModeNumSegments = numSeg
			)
		default:
               (
			   ot_ckb_mode.text = "still"
			   ot_ckb_config.text = "low"
			   ot_ckb_config.state = false
			   ot_ckb_config.enabled = false
			   numSeg = 4
			   mProject = 0
			   mr.FGProjectionMode = mProject
			   iMode = 0
			   mr.IlluminationCacheMode = iMode
			   )
		
		)
	)
	on ot_ckb_config changed state do
	(
		if ot_ckb_config.state == true then
		(
			ot_ckb_config.text = "high"
			numSeg = 16
			mr.FGProjectionModeNumSegments = numSeg
		)
		else
		(
			ot_ckb_config.text = "low"
			numSeg = 4
			mr.FGProjectionModeNumSegments = numSeg
		)
	)
)
createdialog timeout
