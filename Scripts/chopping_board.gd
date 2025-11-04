# chopping_board.gd
extends Node3D

@onready var area = $Area3D
@onready var items_display = $Label3D  # Shows what's on board

var player_in_range = false

func _ready():
	add_to_group("chopping_board")
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	_update_display()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		_show_prompt()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

func _unhandled_input(event):
	if player_in_range and event.is_action_pressed("interact"):
		_show_ingredient_menu()
		get_viewport().set_input_as_handled()

func _show_prompt():
	print("[E] to place ingredient on chopping board")

func _show_ingredient_menu():
	# Show UI to select which ingredient to place
	var menu = get_tree().get_first_node_in_group("cooking_ui")
	if menu:
		menu.show_ingredient_selection("chopping_board")

func add_ingredient(ingredient_name: String) -> bool:
	if GameManager.use_ingredient(ingredient_name):
		GameManager.chopping_board_items.append(ingredient_name)
		_update_display()
		print("Placed %s on chopping board" % ingredient_name)
		return true
	else:
		print("You don't have any %s!" % ingredient_name)
		return false

func transfer_to_bowl():
	if GameManager.chopping_board_items.size() > 0:
		for item in GameManager.chopping_board_items:
			GameManager.bowl_items.append(item)
		GameManager.chopping_board_items.clear()
		_update_display()
		print("Transferred items to bowl")
		return true
	return false

func _update_display():
	if items_display:
		if GameManager.chopping_board_items.size() > 0:
			items_display.text = "Items: " + str(GameManager.chopping_board_items)
		else:
			items_display.text = "Empty"
