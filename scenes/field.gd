extends Node2D

const card_obj = preload("res://scenes/card.tscn")
const card_attack = [
	{"name":"Inside RUN","tooltip":"This conservative play typically results in short yardage."}, 
	{"name":"Outside RUN", "tooltip":"This play is less conservative than Inside RUN, resulting in more risk and longer yardage."},
	{"name":"Short PASS","tooltip":"This is the most conservative passing play. It typically results in short yardage." },
	{"name":"Medium PASS","tooltip":"This passing play is less conservative than Short PASS, resulting in more risk and longer yardage"},
	{"name":"Long PASS","tooltip":"This play is sometimes called the Hail Mary because you will need to say a prayer for it to work.Very risky, but big gains are possible."}
	]
const card_defend = [
	{"name":"RUN Defense", "tooltip":"Use this formation if you believe your opponent will run the football."},
	{"name":"PASS Defense", "tooltip":"Use this formation if you believe your opponent will pass the football"},
	{"name":"BLITZ Defense", "tooltip":"Use this risky formation if you believe your opponent will attempt a risky play."}
	]
func _ready():
	# create cards
	var cuenta = 0
	for item in card_attack:
		var obj = card_obj.instantiate()
		Main.obj_att_cards.append(obj)
		obj.start(item["name"], item["tooltip"], cuenta)
		if cuenta == 0 or cuenta == 1:
			obj.get_child(0).modulate = Color(0, 0.392157, 0, 1 )
		elif cuenta == 4:
			obj.get_child(0).modulate = Color(0.545098, 0, 0, 1)
		obj.visible = false
		self.add_child(obj)
		cuenta+=1
	cuenta = 0
	for item in card_defend:
		var obj = card_obj.instantiate()
		Main.obj_def_cards.append(obj)
		obj.start(item["name"], item["tooltip"],cuenta)
		if cuenta == 0:
			obj.get_child(0).modulate = Color(0, 0.392157, 0, 1 )
		elif cuenta == 2:
			obj.get_child(0).modulate = Color(0.545098, 0, 0, 1)
		obj.visible = false
		self.add_child(obj)
		cuenta+=1
	# create Field Goal and Punt cards
	var obj = card_obj.instantiate()
	Main.punt_cards.append(obj)
	obj.start("Field Goal", "Try to score a Field Goal, you havo to roll higher than yards/10",10)
	obj.get_child(0).modulate = Color(1, 0.270588, 0, 1)
	obj.visible = false
	self.add_child(obj)
	obj = card_obj.instantiate()
	Main.punt_cards.append(obj)
	obj.start("Punt", "Kick the ball as farther away as you can, distance is die * 10 yards",20)
	obj.get_child(0).modulate = Color(1, 0.270588, 0, 1)
	obj.visible = false
	self.add_child(obj)
	
	new_game()

func _process(delta):
	pass
	
func new_game():
	# set opponent as CPU AI
	Main.opponent = "CPU"
	Main.player_score = 0
	Main.op_score = 0
	# throw a coin to see who start attacking
	var kickoff = Main.rng.randi()%2
	$spr_coin.visible= true
	if kickoff == 0:
		$spr_coin.texture = load("res://icon.svg")
		Main.player = "attack"
		Main.yards = 20
	else:
		$spr_coin.texture = load("res://tails.svg")
		Main.player = "defend"
		Main.yards = 80
	$spr_coin/tmr_coin.start()
	# set ball position yards to the 20, first down
	Main.yards_to_down = 10
	Main.down_number = 1
	Main.move_ball()
	
func _on_tmr_coin_timeout():
	$spr_coin.visible = false
	#start turn after setup
	draw_cards()

# show the cards to the players
func draw_cards():
	print("draw")
	if Main.player == "attack":
		var cont = 250
		for item in Main.obj_att_cards:
			item.position = Vector2(40 + cont,526)
			item.visible = true
			cont += 150
		if Main.down_number == 4:
			cont = 200
			for item in Main.punt_cards:
				item.visible = true
				item.position = Vector2(1100, cont)
				cont +=200
	else:
		var cont = 400
		for item in Main.obj_def_cards:
			item.position = Vector2(40 + cont,526)
			item.visible = true
			cont += 150
			
