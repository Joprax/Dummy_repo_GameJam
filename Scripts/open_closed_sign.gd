# open_closed_sign.gd
extends Node3D

@onready var area = $Area3D
@onready var sign_mesh = $MeshInstance3D  # Your sign visual
@onready var status_label = $Label3D  # Shows "OPEN" or "CLOSED"

var player_in_range = false

func _ready():
	add_to_group("cart_sign")
	add_to_group("interactable")  # ← ADD THIS LINE
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	GameManager.cart_status_changed.connect(_on_cart_status_changed)
	_update_sign()

func on_interact():
	toggle_sign()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		print("[E] to toggle shop status")

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

func _unhandled_input(event):
	if player_in_range and event.is_action_pressed("interact"):
		toggle_sign()
		get_viewport().set_input_as_handled()

func toggle_sign():
	GameManager.toggle_cart()
	_update_sign()

func _on_cart_status_changed(is_open):
	_update_sign()

func _update_sign():
	if status_label:
		if GameManager.is_cart_open:
			status_label.text = "OPEN"
			status_label.modulate = Color.GREEN
		else:
			status_label.text = "CLOSED"
			status_label.modulate = Color.RED
	
	print("Shop is now: %s" % ("OPEN" if GameManager.is_cart_open else "CLOSED"))
