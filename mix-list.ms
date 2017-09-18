--write target biped's mixer tracks into a text file along with animation ranges
--the text file is located inside the scene folder
--feed the character data along with the text file into the engine
--###-### clipName

global roo
global mxr
global tag
global srt
global end
global cnt = 0

fn root obj = if isvalidnode obj do 
(
while obj.parent != undefined do obj = obj.parent
obj
)

fn main = 
(
	clearlistener()
	/*
	try(deleteFile (tag + ".txt"))catch()
	file = (getfiles (tag + ".txt")).count
	if file == 0 then f = createFile (tag + ".txt") else f = file
	*/
	while files != 0
	do 
	(
		cnt+=1
        fName = tag + cnt as string + ".txt"
		files = (getfiles (fName)).count
	)
    
	f = createfile (fName)
	
	for t = 1 to mxr.numtrackgroups do
	(
		tG = gettrackgroup mxr t
		tCount = tG.numtracks
		
		for tC = 1 to tCount do
		(
			cTrack = gettrack tG tC
			
			for cT = 1 to cTrack.numclips do
			(
				cClip = getclip cTrack cT
				arr = filterstring cClip.filename "'\'"
				a = arr[arr.count]
				a = substring a 1 (a.count - 4)
				s = cClip.globstart as string
				s_str = substring s 1 (s.count - 1)
				if cT  == 1 do srt = s
				end = (cClip.globend as string)
				e_str = substring end 1 (end.count - 1)
				format "%-% %\n" s_str e_str a to:f
				--print (s_str + "-" + e_str + " " + a)
			)
		)
	)
    
    try(shelllaunch fName "")catch()
)

try(destroydialog :: mix_list)catch()
rollout mix_list "" width:128 height:96
(
	button btn_101 "look@101craft" pos:[8,8] width:112 height:16 toolTip:"visit 101craft.com"
	button btn_root "select biped" pos:[8,32] width:112 height:24 toolTip:"select biped root handle"
	button btn_compile "compile list" pos:[8,64] width:112 height:24 toolTip:"compile mixer's animation list"	
	
	on btn_101 pressed do
	(
		try(shelllaunch "http://101craft.com" "")catch()
	)
	
	on btn_root pressed do
	(
		roo = root $
		mxr = roo.controller.mixer
		btn_root.text = roo.name
	)
	
	on btn_compile pressed do
	(
		tag = (maxfilepath + roo.name)
		main()
	)
)
createdialog mix_list
