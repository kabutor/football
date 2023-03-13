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
		self.position = Vector2(400,130)
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
	# Resolve yards and punt and field goal 0 - nothing 1- fail 2- success
	var _field_goal = 0
	if Main.player == "attack":
		if action > 5:
			#field goal and Punt
			match (action):
				10:
					temp_yards = 0
					# mark that is at least trying
					_field_goal = 1
					var _difficult = (100 - Main.yards) / 10
					print(Main.die_roll[0])
					if (Main.die_roll[0]+1 > _difficult):
						print("field goal in card")
						_field_goal = 2
				20:
					temp_yards = 10 * (Main.die_roll[0] + 1)
		else:
			# rest of actions
			match (op[1]):
				0:
					temp_yards = run_defense_results[action][Main.die_roll[0]]
				1:
					temp_yards = pass_defense_results[action][Main.die_roll[0]]
				2:
					temp_yards = blitz_results[action][Main.die_roll[0]]
				
	else:
		if op[1] > 5:
			match(op[1]):
				10:
					temp_yards = 0
					# mark that is at least trying
					_field_goal = 1
					var _difficult = (Main.yards) / 10
					print(Main.die_roll[0])
					if (Main.die_roll[0]+1 > _difficult):
						print("field goal in")
						_field_goal = 2
				20:
					temp_yards = 10 * (Main.die_roll[0] + 1)
		else:
			match(action):
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
	
	# show opponent card first, FIELD GOAL and PUNT, then the plays
	if op[1] == 10:
		Main.punt_cards[0].visible = true
		Main.punt_cards[0].position = Vector2(750,130)
	elif op[1] == 20:
		Main.punt_cards[1].visible = true
		Main.punt_cards[1].position = Vector2(750,130)
	elif Main.player == "attack":
		Main.obj_def_cards[op[1]].visible = true
		Main.obj_def_cards[op[1]].position = Vector2(750,130)
	else:
		Main.obj_att_cards[op[1]].visible = true
		Main.obj_att_cards[op[1]].position = Vector2(750,130)
	# Show die rolls
	var _die = get_node("/root/field/die")
	# show FIELD GOAL
	if _field_goal > 0:
		$tmr_card.start()
		var node_goal = get_node("/root/field/gui/lbl_field_goal")
		node_goal.visible = true
		if Main.player == "attack":
			node_goal.text= "\n[center][b][color=000000]FIELD GOAL \n Distance: " + str(100 - Main.yards)
		else:
			node_goal.text= "\n[center][b][color=000000]FIELD GOAL \n Distance: " + str(Main.yards)
		_die.visible=true
		_die.go_roll(Main.die_roll[0])
		_die.position = Vector2(550,330)
		await $tmr_card.timeout
	else:
		for item in Main.die_roll:
			$tmr_card.start()
			_die.visible=true
			_die.go_roll(item)
			_die.position = Vector2(550,330)
			await $tmr_card.timeout
	# second 2s wait
	$tmr_card.start()
	#show yards run except if fumble
	if !(_fumble) and _field_goal == 0:
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
	for item in Main.punt_cards:
		item.visible = false
	get_node("/root/field/gui/lbl_tooltip").visible = false
	get_node("/root/field/gui/lbl_field_goal").visible = false
	#print(Main.die_roll)
	#print(temp_yards)
	# call Main function(temp_yards) to resolve yards and downs or fumble
	if _fumble:
		get_node("/root/field/gui/")._process_fumble()
	elif _field_goal == 3:
		Main.field_goal()
	elif action == 20 or op[1] == 20:
		Main.process_punt(temp_yards)
	else:
		Main.process_down(temp_yards)
	
	

# Returns opponent action
func get_opponent_action():
	var op_action
	var decision = null
	var roll = null
	# If playing against CPU
	if Main.opponent == "CPU":
		var downs_left = 4 - Main.down_number
		# AI Decision will be null until choose
		if Main.player == "attack":
			# CPU defense decision tree Main.rng.randi()%100 is a 100 die
			if Main.yards_to_down <= 4:
				if Main.rng.randi()%100 < (65 + (5 * downs_left) ):
					decision = 0
				else:
					if Main.rng.randi()%100 < 50:
						decision = 1
					else:
						decision = 2
			elif Main.yards_to_down > 4 and Main.yards_to_down <= 10:
				# run defense more likely as more downs are left
				if Main.rng.randi()%100 < (60 + (5 * Main.down_number)):
					decision = 2
				else:
					# no sure about this 
					if Main.rng.randi()%100 < (60 + (Main.down_number * 5)):
						decision = 1
					else:
						decision = 0
			else:
				# if more than 10 yards left
				if Main.rng.randi()%100 < 40:
					decision = 1
				elif Main.rng.randi()%100 < 40:
					decision = 2
				else:
					decision = 0
			#Put a name on the decisions
			match decision:
				0:
					op_action = "RUN Defense"
				1:
					op_action = "PASS Defense"
				2:
					op_action= "BLITZ Defense"
		else:
			# CPU ATTACK decision tree Main.rng.randi()%100 is a 100 die
			# if 1st down
			if downs_left == 3:
				if Main.rng.randi()%100 < 75:
					if Main.rng.randi()%100 <50:
						decision = 0
					else:
						decision = 1
				else:
					if Main.rng.randi()%100 < 50:
						decision = 4
					else:
						if Main.rng.randi()%100 < 70:
							decision = 2
						else:
							decision = 3
			# 2nd down
			elif downs_left == 2:
				# less than 6 yards run inside or short pass 70%
				if Main.yards_to_down <= 5:
					if Main.rng.randi()%100 < 70:
						if Main.rng.randi()%100 <50:
							decision = 0
						else:
							decision = 2
					else:
						# if not 70% Outer run/Med Pass if not 30% hail mary
						if Main.rng.randi()%100 < 70:
							if  Main.rng.randi()%100 < 50:
								decision = 1
							else:
								decision = 3
						else:
							decision = 4
				else:
					# if more thatn 5 yards left 70% Outer run / Med pass
					if Main.rng.randi()%100 < 70:
						if Main.rng.randi()%100 < 50:
							decision = 1
						else:
							decision = 2
					else:
						#if not 50% run 50% long pass
						if Main.rng.randi()%100 < 50:
							decision = 4
						else:
							if Main.rng.randi()%100 < 50:
								decision = 0
							else:
								decision = 3
			# 3rd down
			elif downs_left == 1:
				if Main.yards_to_down <= 5:
					# 3rd down less than 5 yards 70% In run, short pass
					if Main.rng.randi()%100 < 70:
						if Main.rng.randi()%100 < 50:
							decision = 0
						else:
							decision = 2
					else:
						# if not Outer run, Med pass, only 20% long pass
						if Main.rng.randi()%100 < 80:
							if Main.rng.randi()%100 < 50:
								decision = 1
							else:
								decision = 3
						else:
							decision = 4
				#if more than 5 yards
				else:
					# 50% long pass if not 70 % pass short med, the rest run
					if Main.rng.randi()%100 < 50:
						decision = 4
					else:
						if Main.rng.randi()%100 < 70:
							if Main.rng.randi()%100 < 50:
								decision = 2
							else:
								decision = 3
						else:
							#run outer always
							decision = 1
			# 4th down
			else:
				# yards are going down for the CPU
				if Main.yards < 40:
					decision = 10
				elif Main.yards >= 40 and Main.yards < 49:
					# safe play to 4 yards
					if Main.yards_to_down <= 4:
						# sweet spot for 4 or less
						if Main.rng.randi()%100 < 70:
							if Main.rng.randi()%100 < 50:
								decision = 0
							else:
								decision = 2
						else:
							if Main.rng.randi()%100 < 60:
								if Main.rng.randi()%100 < 50:
									decision = 3
								else:
									decision = 1
							else:
								# field goal
								decision = 10
					else:
						# field goal o a long run/ pass
						if Main.rng.randi()%100 < 70:
							decision = 10
						else:
							if Main.rng.randi()%100 < 50:
								decision = 1
							else:
								decision = 3
				else:
					#punt if farther than 50
					decision = 20
			# put name to action
			match decision:
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
				10:
					op_action = "Field Goal"
				20:
					op_action = "Punt"
	else:
		print("Not implemented")
	return [op_action, decision]
