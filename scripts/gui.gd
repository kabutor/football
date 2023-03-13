extends Control

var fumble_change_side = false

func _ready():
	pass 
func _process(delta):
	pass

func _update_down_banner():
	$lbl_down.text = "[center][b][outline_size=4][outline_color=000000][color=FF0000]"+ str(Main.down_number) + "st[/color] and " + str(Main.yards_to_down)

func update_score():
	$lbl_player_score.text = "[center][b][outline_size=4][outline_color=000000][color=FF0000]" +  str(Main.player_score)+ "[/color]"
	$lbl_op_score.text =  "[center][b][outline_size=4][outline_color=000000][color=0000FF]" +  str(Main.op_score)+ "[/color]"
func yards_runned(yar):
	$lbl_yards_run.visible = true
	$lbl_yards_run.text = "[center][b][outline_size=4][outline_color=000000][color=FF0000]" + str(yar) +"[/color]"

func _process_fumble():
	$lbl_fumble.visible = true
	var att_roll = Main.rng.randi()%6 +1
	var def_roll = Main.rng.randi()%6 +1
	var _node_die = get_node("/root/field/die")
	# att roll
	$lbl_fumble/tmr_fumble.start()
	_node_die.visible = true
	_node_die.go_roll(att_roll - 1)
	_node_die.position = Vector2(200,330)
	await $lbl_fumble/tmr_fumble.timeout
	# def roll
	$lbl_fumble/tmr_fumble.start()
	_node_die.go_roll(def_roll - 1)
	_node_die.position = Vector2(900,330)
	await $lbl_fumble/tmr_fumble.timeout
	if def_roll > att_roll:
		$lbl_fumble.text = "[center][b][outline_size=1][outline_color=FFFFFF][color=0000FF] Fumble![/color]\nDefence takes the ball!!"
		fumble_change_side = true
	else:
		$lbl_fumble.text = "[center][b][outline_size=1][outline_color=FFFFFF][color=FF0000] Fumble![/color]\nAttack recover the ball!!"
		fumble_change_side = false
	$lbl_fumble/tmr_fumble.wait_time = 2
	$lbl_fumble/tmr_fumble.start()
	# end of fumble
	await $lbl_fumble/tmr_fumble.timeout
	# reset time
	$lbl_fumble/tmr_fumble.wait_time = 1
	$lbl_fumble.visible = false
	_node_die.visible = false
	if fumble_change_side:	
		Main.change_sides()
	else:
		Main.process_down(0)


	
