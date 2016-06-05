try(destroydialog :: castleGen)catch()

rollout castleGen "" width:136 height:296
(
	
	fn rootParent node = 
	(
		if isvalidnode node do 
		(
		while node.parent != undefined do node = node.parent
		node
		)
	)
		
	pickButton btn1 "platform" pos:[8,8] width:120 height:24
	pickButton btn2 "1/ module" pos:[8,32] width:120 height:24
	pickButton btn3 "2/ module " pos:[8,56] width:120 height:24
	button btn4 "create" pos:[8,264] width:120 height:24
	spinner spn1 "" pos:[8,88] width:56 height:16 range:[0,100,1] type:#integer
	spinner spn2 "" pos:[72,88] width:56 height:16 range:[0,100,1] type:#integer
	
	on btn1 picked obj do
	(
	obj = rootParent obj
	btn1.text = obj.name
	)
	on btn2 picked obj do
	(
	obj = rootParent obj
	btn2.text = obj.name
	)
	on btn3 picked obj do
	(
	obj = rootParent obj
	btn3.text = obj.name
	)
	on btn4 pressed  do
	(
	
	)
)

createDialog castleGen
