--move list position position controller's animation frames en masse
for o in selection do
(
	t = getkeytime o.pos.controller[2].controller 2
	o.pos.controller.setactive 2
	animate on at time t o.position.y = o.position.y + -3000
)

--move position controller's animation frames en masse
for o in selection do
(
	t = getkeytime o.pos.controller 1
	animate on
	at time t o.position.y = o.position.y + 3000
)
