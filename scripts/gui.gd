extends Control

var fumble_change_side = false

func _ready():
	pass 
func _process(delta):
	pass

func _update_down_banner():
	$lbl_down.text = "[center][b][outline_size=4][outline_color=000000][color=FF0000]"+ str(Main.down_number) + "st[/color] and " + str(Main.yards_to_down)

func yards_runned(yar):
	$lbl_yards_run.visible = true
	$lbl_yards_run.text = "[center][b][outline_size=4][outline_color=000000][color=FF0000]" + str(yar) +"[/color]"

func _process_fumble():
	$lbl_fumble.visible = true
	var att_roll = Main.rng.randi()%6 +1
	var def_roll = Main.rng.randi()%6 +1
	if def_roll > att_roll:
		$lbl_fumble.text = "[center][b][outline_size=4][outline_color=FFFFFF][color=000000] Fumble![/color]\nDefence takes the ball!!"
		fumble_change_side = true
	else:
		$lbl_fumble.text = "[center][b][outline_size=4][outline_color=FFFFFF][color=000000] Fumble![/color]\nAttack recover the ball!!"
		fumble_change_side = false
	$lbl_fumble/tmr_fumble.start()
func _on_tmr_fumble_timeout():
	$lbl_fumble.visible = false
	if fumble_change_side:
		Main.change_sides()
	else:
		Main.process_down(0)
