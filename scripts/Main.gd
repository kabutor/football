extends Node

var rng = RandomNumberGenerator.new()
# attack or defend
var player = null
var opponent = null
var die_roll = []
var yards = null
var yards_to_down = null
var down_number = null
var player_score = null
var op_score = null
var obj_att_cards = []
var obj_def_cards = []
var punt_cards = []

func _ready():
	pass
func _process(delta):
	pass

func move_ball():
	var node_ball = get_node("/root/field/ball")
	node_ball.position = Vector2((9.17*yards) + 123,330)

# when you have to change sides
func change_sides():
	if player == "attack":
		player = "defense"
	else:
		player = "attack"
	Main.yards_to_down = 10
	Main.down_number = 1
	# raw and ugly update banner and draw cards
	get_node("/root/field/gui")._update_down_banner()
	move_ball()
	get_node("/root/field").draw_cards()

func process_down(yards_moved):
	yards_to_down -= yards_moved
	if player == "attack":
		yards += yards_moved
		# bug where you can go farther than 0 defending
		if yards < 0:
			yards=0
		# check if score
		if yards > 100:
			touchdown()	
		# check if down 10 yards
		elif yards_to_down < 1:
			yards_to_down = 10
			down_number = 1
		else:
			down_number +=1
		# if more than 4 downs
		
		if down_number >4:
			change_sides()
	else:
		yards -= yards_moved
		# bug where you can go farther than 0 defending
		if yards > 100:
			yards=100
		# check if score
		if yards < 0:
			touchdown()	
		# check if down 10 yards
		elif yards_to_down < 1:
			yards_to_down = 10
			down_number = 1
		else:
			down_number +=1
		# if more than 4 downs
		
		if down_number >4:
			change_sides()

	# raw and ugly update banner and draw cards
	get_node("/root/field/gui")._update_down_banner()
	move_ball()
	get_node("/root/field").draw_cards()

func process_punt(yards_moved):
	if player == "attack":
		yards += yards_moved
		if yards > 80:
			#touchback
			yards = 80
	else:
		yards -= yards_moved
		if yards < 20:
			yards = 20
	change_sides()
	
func field_goal():
	print("field goal")
	if player == "attack":
		player_score +=3
		yards = 80
	else:
		op_score += 3
		yards = 20
	change_sides()
	
func touchdown():
	print("touchdown")
	if player == "attack":
		player_score += 7
		yards = 80
	else:
		op_score += 7
		yards = 20
	change_sides()
