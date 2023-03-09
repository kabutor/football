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
	new_game()

func _process(delta):
	pass
	
func new_game():
	# set opponent as CPU AI
	Main.opponent = "CPU"
	# throw a coin to see who start attacking
	var kickoff = Main.rng.randi()%2
	$spr_coin.visible= true
	if kickoff == 0:
		print("head")
		$spr_coin.texture = load("res://icon.svg")
		Main.player = "attack"
	else:
		print("tails")
		$spr_coin.texture = load("res://tails.svg")
		Main.player = "defend"
	$spr_coin/tmr_coin.start()
	# set yards to the 20
	Main.yards = 20
	
func _on_tmr_coin_timeout():
	$spr_coin.visible = false
	#start turn after setup
	draw_cards()

# show the cards to the players
func draw_cards():
	print("draw")
	var cuenta = 0
	if Main.player == "attack":
		var cont = 250
		for item in card_attack:
			var obj = card_obj.instantiate()
			obj.start(item["name"], item["tooltip"], cuenta)
			obj.translate(Vector2(40 + cont,526))
			cont += 150
			self.add_child(obj)
			cuenta+=1
	else:
		var cont = 400
		for item in card_defend:
			var obj = card_obj.instantiate()
			obj.start(item["name"], item["tooltip"],cuenta)
			obj.translate(Vector2(40 + cont,526))
			cont += 150
			self.add_child(obj)
			cuenta+=1
