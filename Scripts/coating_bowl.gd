# coating_bowl.gd
extends Node3D

@onready var area = $Area3D
@onready var items_display = $Label3D

var player_in_range = false

func _ready():
	add_to_group("coating_bowl")
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	_update_display()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		print("[E] to add items from chopping board")

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

func _unhandled_input(event):
	if player_in_range and event.is_action_pressed("interact"):
		add_from_chopping_board()
		get_viewport().set_input_as_handled()

func add_from_chopping_board():
	var chopping_board = get_tree().get_first_node_in_group("chopping_board")
	if chopping_board and chopping_board.transfer_to_bowl():
		_update_display()
		print("Added items to coating bowl")
	else:
		print("Chopping board is empty!")

func transfer_to_pan():
	if GameManager.bowl_items.size() >= 2:  # Need at least 2 ingredients
		var temp = GameManager.bowl_items.duplicate()
		GameManager.bowl_items.clear()
		_update_display()
		return temp
	else:
		print("Need at least 2 ingredients in bowl!")
		return []

func _update_display():
	if items_display:
		if GameManager.bowl_items.size() > 0:
			items_display.text = "Bowl: " + str(GameManager.bowl_items)
		else:
			items_display.text = "Empty"
