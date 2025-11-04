# npc_shop.gd
extends CharacterBody3D

@onready var area = $Area3D
@export var shop_ui_node: NodePath 

var player_in_range = false

func _ready():
	add_to_group("npc_shop")
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		print("[E] to open shop")

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

func _unhandled_input(event):
	if player_in_range and event.is_action_pressed("interact"):
		open_shop()
		get_viewport().set_input_as_handled()

func open_shop():
	# Find the 3D shop UI
	var shop_ui = get_tree().get_first_node_in_group("shop_ui")
	if shop_ui:
		shop_ui.show_shop()
	else:
		print("Shop UI not found!")
