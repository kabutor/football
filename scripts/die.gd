extends Sprite2D
const die_face = [preload("res://pics/dice-six-faces-one.svg"),preload("res://pics/dice-six-faces-two.svg"),
preload("res://pics/dice-six-faces-three.svg"),  preload("res://pics/dice-six-faces-four.svg"), 
preload("res://pics/dice-six-faces-five.svg"),preload("res://pics/dice-six-faces-six.svg")]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func go_roll(face):
	self.texture = die_face[Main.rng.randi()%6]
	var tween = create_tween().set_loops(1)
	tween.set_parallel()
	tween.tween_property(self, "scale",Vector2(0.05,0.05), 0.5)
	tween.tween_property(self, "rotation", TAU, 0.5).as_relative()
	tween.tween_property(self, "scale", Vector2(0.2,0.2), 0.5).set_delay(0.5).from(Vector2(0.05, 0.05))
	$tmr_die.start()
	await $tmr_die.timeout
	self.texture = die_face[face]

