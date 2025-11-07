# Panel.gd (Inventory UI)
extends Panel

@onready var close: Button = $Close
@onready var game_manager = get_node("/root/GameManager")
@onready var grid_container: GridContainer = $GridContainer

# Store references to item slots
var item_slots: Array = []

func _ready() -> void:
	add_to_group("inventory_ui") 
	close.pressed.connect(_on_close_pressed)
	visibility_changed.connect(_on_visibility_changed)
	
	# Connect to game manager signals
	game_manager.ingredient_changed.connect(_on_ingredient_changed)
	
	# Get all item slots
	_get_item_slots()
	
	# Initialize inventory display
	_update_inventory_display()
	
	visible = false

func _get_item_slots():
	# Clear existing array
	item_slots.clear()
	
	# Find all ItemSlot nodes in the grid container
	for child in grid_container.get_children():
		if child is Panel and child.name.begins_with("ItemSlot"):
			item_slots.append(child)

func _update_inventory_display():
	# Reset all slots first
	for slot in item_slots:
		_clear_slot(slot)
	
	# Populate slots with owned items
	var slot_index = 0
	for ingredient in game_manager.ingredients:
		var quantity = game_manager.ingredients[ingredient]
		if quantity > 0 and slot_index < item_slots.size():
			_populate_slot(item_slots[slot_index], ingredient, quantity)
			slot_index += 1

func _clear_slot(slot: Panel):
	var icon = slot.get_node("Icon") as TextureRect
	var label = slot.get_node("Label") as Label
	
	if icon:
		icon.texture = null
	if label:
		label.text = ""
	slot.item_type = ""

func _populate_slot(slot: Panel, ingredient: String, quantity: int):
	var icon = slot.get_node("Icon") as TextureRect
	var label = slot.get_node("Label") as Label 
	
	if icon:
		# Set the appropriate texture based on ingredient
		match ingredient:
			"oil":
				icon.texture = preload("res://OildaGreat.svg") 
			"flour":
				icon.texture = preload("res://FlourdaGreat.svg") 
			"bread":
				icon.texture = preload("res://icon.svg") 
			"sauce":
				icon.texture = preload("res://icon.svg") 
	
	if label:
		label.text = str(quantity)
		slot.item_type = ingredient

func _on_ingredient_changed(ingredient_name: String, new_amount: int):
	# Update inventory display whenever any ingredient changes
	_update_inventory_display()
	print("Inventory updated: %s now has %d" % [ingredient_name, new_amount])

func _process(delta: float) -> void:
	if Input.get_current_cursor_shape() == CURSOR_FORBIDDEN:
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
	
	# Using Input Map action
	if Input.is_action_just_pressed("toggle_ui"):
		self.visible = !self.visible

func _on_close_pressed() -> void:
	self.visible = false

func _on_visibility_changed() -> void:
	# Release mouse when inventory opens, capture when it closes
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# FIXED: Remove the problematic drag notification code
func _notification(what: int) -> void:
	# Let Godot handle drag notifications automatically
	pass
	
