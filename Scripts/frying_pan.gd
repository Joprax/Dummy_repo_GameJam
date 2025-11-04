# frying_pan.gd
extends Node3D

@onready var area = $Area3D
@onready var status_label = $Label3D
@onready var cooking_timer = $CookingTimer

var player_in_range = false
var is_cooking = false
var cooking_items: Array = []

func _ready():
	add_to_group("frying_pan")
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	cooking_timer.timeout.connect(_on_cooking_finished)
	cooking_timer.one_shot = true
	_update_display()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		if not is_cooking:
			print("[E] to start frying")

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

func _unhandled_input(event):
	if player_in_range and event.is_action_pressed("interact"):
		if not is_cooking:
			start_cooking()
		get_viewport().set_input_as_handled()

func start_cooking():
	var bowl = get_tree().get_first_node_in_group("coating_bowl")
	if bowl:
		cooking_items = bowl.transfer_to_pan()
		if cooking_items.size() > 0:
			is_cooking = true
			cooking_timer.start(5.0)  # 5 seconds to cook
			print("Started cooking... Wait 5 seconds")
			_update_display()
		else:
			print("Bowl doesn't have enough ingredients!")

func _on_cooking_finished():
	is_cooking = false
	GameManager.add_cooked_food()
	print("Food is ready! Total cooked foods: %d" % GameManager.cooked_foods)
	cooking_items.clear()
	_update_display()

func _update_display():
	if status_label:
		if is_cooking:
			var time_left = cooking_timer.time_left
			status_label.text = "Cooking... %.1fs" % time_left
		elif cooking_items.size() > 0:
			status_label.text = "Ready to cook"
		else:
			status_label.text = "Empty pan"

func _process(delta):
	if is_cooking:
		_update_display()
