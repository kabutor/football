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
	print(_count)
	$lbl_name.text = "[center]\n\n" + _name
	
# mouse click on card
func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		#Action choosed, go to resolve
		resolve_action(_name)
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
			keep_rolling =true
			#failgauard
			if (len(Main.die_roll) > 6):
				keep_rolling = false
		elif roll == 0:
			keep_rolling = true
			# No more than 2 rolls to see if there is a fumble
			if (len(Main.die_roll) > 1):
				keep_rolling = false
		else:
			keep_rolling = false
	
	# Get opponent action, player action is "action"
	var op = get_opponent_action()
	
	var attack_code = null
	if Main.player == "attack":
		pass
	
	

# Returns opponent action
func get_opponent_action():
	var op_action
	# If playing against CPU
	if Main.opponent == "CPU":
		#Super AI Algorithm implementation
		if Main.player == "attack":
			var roll = Main.rng.randi()% 3
			match roll:
				0:
					op_action = "RUN Defense"
				1:
					op_action = "PASS Defense"
				2:
					op_action= "BLITZ Defense"
		else:
			var roll = Main.rng.randi()% 5
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
	return op_action
