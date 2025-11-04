# item_card.gd
extends Control

@onready var item_label = $Label
@onready var spinbox = $SpinBox
@onready var checkbox = $CheckBox

@export var item_name: String = "flour"  # Set this in inspector for each card
@export var item_price: int = 5

var is_selected: bool = false

func _ready():
	checkbox.toggled.connect(_on_checkbox_toggled)
	
	# Set the display name
	if item_label:
		item_label.text = item_name.capitalize()
	
	# Set spinbox defaults
	if spinbox:
		spinbox.min_value = 1
		spinbox.max_value = 99
		spinbox.value = 1

func _on_checkbox_toggled(button_pressed: bool):
	is_selected = button_pressed

func get_order() -> Dictionary:
	if is_selected:
		return {
			"item": item_name,
			"quantity": int(spinbox.value),
			"price": item_price
		}
	return {}

func reset_card():
	checkbox.button_pressed = false
	spinbox.value = 1
	is_selected = false
