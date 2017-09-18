--write target biped's mixer tracks into a text file along with animation ranges
--the text file is located inside the scene folder

global root
global mix
global tag
global start
global end
global count = 0

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
		count+=1
		files = (getfiles (tag + count as string + ".txt")).count
	)
	
	f = createfile (tag + count as string + ".txt")
	
	for t = 1 to mix.numtrackgroups do
	(
		tG = gettrackgroup mix t
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
				if cT  == 1 do start = s
				end = (cClip.globend as string)
				e_str = substring end 1 (end.count - 1)
				format "%-% %\n" s_str e_str a to:f
				print (s_str + "-" + e_str + " " + a)
			)
		)
	)
)

try(destroydialog :: mix_list)catch()
rollout mix_list "" width:128 height:96
(
	button btn_101 "look@101craft" pos:[8,8] width:112 height:16 toolTip:"visit 101craft.com"
	button btn_root "select biped" pos:[8,32] width:112 height:24 toolTip:"select biped root handle"
	button btn_compile "compile list" pos:[8,64] width:112 height:24 toolTip:"compile mixer's animation list"	
	
	on btn_root pressed do
	(
		root = $
		mix = root.controller.mixer
		btn_root.text = $.name
	)
	
	on btn_compile pressed do
	(
		tag = (maxfilepath + root.name)
		main()
	)
)
createdialog mix_list
