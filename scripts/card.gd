extends Node2D

var _name = null
var _tooltip = null
var _count = null
func _ready():
	pass # Replace with function body.
func _process(delta):
	pass

# The function I call when I make a new card instance
func start(name_card, toolt, cnt):
	_name = name_card
	_tooltip = toolt
	_count = cnt
	$lbl_name.text = "[center]\n\n" + _name
	
# mouse click on card
func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		#Action choosed, go to resolve
		self.position = Vector2(200,330)
		resolve_action(_count)
		
# Enable/Disable tooltip on mouse over
func _on_area_2d_mouse_entered():
	get_node("/root/field/gui/lbl_tooltip").text = "[center]" + _tooltip
	get_node("/root/field/gui/lbl_tooltip").visible = true
func _on_area_2d_mouse_exited():
	get_node("/root/field/gui/lbl_tooltip").visible = false

# resolve player action
func resolve_action(action):
	# table results DEFENCE_ACTION_results Run Def. Pass Def. and Blitz
	# [0] -> Inside Run [1] -> Outside Run [2] -> Short Pass
	# [3] -> Medium Pass [4] Long Pass-> 
	var run_defense_results = []
	run_defense_results.append_array([0,1,2,3,4])
	run_defense_results[0] = [-4,-2,0,0,2,4]
	run_defense_results[1] = [-4,-2,0,0,4,6]
	run_defense_results[2] = [0,2,4,4,6,10]
	run_defense_results[3] = [0,0,6,6,8,16]
	run_defense_results[4] = [-6,0,0,0,0,20]
	var pass_defense_results = []
	pass_defense_results.append_array([0,1,2,3,4])
	pass_defense_results[0] = [0,2,4,4,6,8]
	pass_defense_results[1] = [0,0,4,6,8,12]  
	pass_defense_results[2] = [-2,0,0,0,4,6]
	pass_defense_results[3] = [-4,-2,0,0,0,6]
	pass_defense_results[4] = [-10,-6,-6,0,0,10]
	var blitz_results = []
	blitz_results.append_array([0,1,2,3,4])
	blitz_results[0] = [0,2,4,6,6,8]
	blitz_results[1] = [-4,-2,0,0,4,8]
	blitz_results[2] = [-4,0,4,4,6,10]
	blitz_results[3] = [-6,-4,-2,0,0,8]
	blitz_results[4] = [-10,-10,-6,-6,0,0]
	
	# roll die
	Main.die_roll.clear()
	var keep_rolling = true
	while (keep_rolling):
		var roll = Main.rng.randi()%6
		Main.die_roll.append(roll)
		if roll == 5:
			# fix a case where if you roll 1 and 5 it rolls again
			if Main.die_roll.has(0):
				keep_rolling = false
			else:
				keep_rolling =true
			#failguard
			if (len(Main.die_roll) > 10):
				keep_rolling = false
		elif roll == 0:
			keep_rolling = true
			# No more than 2 rolls to see if there is a fumble
			if (len(Main.die_roll) > 1):
				keep_rolling = false
		else:
			keep_rolling = false
	
	# Get opponent action, player action is "action" in number (0 1 2)
	# op is ["name action" - number action]
	keep_rolling = true
	var temp_yards = 0
	var op = get_opponent_action()
	# Resolve yards
	if Main.player == "attack":
		match (op[1]):
			0:
				temp_yards = run_defense_results[action][Main.die_roll[0]]
			1:
				temp_yards = pass_defense_results[action][Main.die_roll[0]]
			2:
				temp_yards = blitz_results[action][Main.die_roll[0]]
	else:
		match (action):
			0:
				temp_yards = run_defense_results[op[1]][Main.die_roll[0]]
			1:
				temp_yards = pass_defense_results[op[1]][Main.die_roll[0]]
			2:
				temp_yards = blitz_results[op[1]][Main.die_roll[0]]
	var _fumble = false
	# check for double, triple, fumble etc
	# Check number or rolls recorded or just one
	if len(Main.die_roll) > 1:
		#Check fumbles
		if (Main.die_roll[0] == 0) and (Main.die_roll[1] == 0):
			print("fumble")
			_fumble = true
		#Check double if two sixes, triple 3 sixes etc
		elif Main.die_roll[0] == 5:
			var multiplier = 0
			for item in Main.die_roll:
				if item == 5:
					multiplier +=1
			temp_yards = temp_yards * multiplier
	# wait and show results
	
	# TODO: show other card table and roll
	if Main.player == "attack":
		Main.obj_def_cards[op[1]].visible = true
		Main.obj_def_cards[op[1]].position = Vector2(1000,330)
	else:
		Main.obj_att_cards[op[1]].visible = true
		Main.obj_att_cards[op[1]].position = Vector2(1000,330)
	# Show die rolls
	var _die = get_node("/root/field/die")
	for item in Main.die_roll:
		$tmr_card.start()
		_die.visible=true
		_die.go_roll(item)
		_die.position = Vector2(550,330)
		await $tmr_card.timeout

	# second 2s wait
	$tmr_card.start()
	#show yards run
	var _node_yards_r = get_node("/root/field/gui")
	_node_yards_r.yards_runned(temp_yards)
	# wait till here	
	await $tmr_card.timeout
	# hide cards and disable tooltip, yards runned and die
	_die.visible = false
	get_node("/root/field/gui/lbl_yards_run").visible = false
	for item in Main.obj_att_cards:
		item.visible = false
	for item in Main.obj_def_cards:
		item.visible = false
		
	get_node("/root/field/gui/lbl_tooltip").visible = false
	#print(Main.die_roll)
	#print(temp_yards)
	# call Main function(temp_yards) to resolve yards and downs or fumble
	if _fumble:
		get_node("/root/field/gui/")._process_fumble()
	else:
		Main.process_down(temp_yards)
	
# Returns opponent action
func get_opponent_action():
	var op_action
	var roll
	# If playing against CPU
	if Main.opponent == "CPU":
		#Super AI Algorithm implementation
		if Main.player == "attack":
			roll = Main.rng.randi()% 3
			match roll:
				0:
					op_action = "RUN Defense"
				1:
					op_action = "PASS Defense"
				2:
					op_action= "BLITZ Defense"
		else:
			roll = Main.rng.randi()% 5
			match roll:
				0:
					op_action = "Inside RUN"
				1:
					op_action = "Outside RUN"
				2:
					op_action= "Short PASS"
				3: 
					op_action = "Medium PASS"
				4:
					op_action = "Long PASS"
	else:
		print("Not implemented")
	return [op_action, roll]
