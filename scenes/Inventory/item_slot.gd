# ItemSlot.gd (Inventory Slots)
extends Panel

@onready var icon: TextureRect = $Icon
@onready var label: Label = $Label

var item_type: String = ""
@onready var game_manager = get_node("/root/GameManager")

func _get_drag_data(at_position: Vector2) -> Variant:
	if icon.texture == null:
		return null
	
	# Check if we actually have this item
	if item_type == "" or game_manager.ingredients.get(item_type, 0) <= 0:
		return null
		
	# Create drag preview
	var preview = TextureRect.new()
	preview.texture = icon.texture
	preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.custom_minimum_size = Vector2(50, 50)
	
	var control = Control.new()
	control.add_child(preview)
	preview.position = -preview.size / 2
	
	set_drag_preview(control)
	
	# Return drag data
	return {
		"type": "inventory_item",
		"item_type": item_type,
		"source_slot": self,
		"texture": icon.texture,
		"from_foodcart": false  # Mark that this is coming from inventory
	}

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	# Accept both inventory items and foodcart items
	return data is Dictionary and data.has("type") and (data["type"] == "inventory_item" or data["type"] == "foodcart_item")

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data.has("from_foodcart") and data["from_foodcart"]:
		# Item is coming from foodcart - return it to inventory
		_return_item_from_foodcart(data)
	else:
		# Item is coming from another inventory slot - handle reorganization
		var source_slot = data["source_slot"]
		
		# Only swap if it's a different slot
		if source_slot != self:
			_swap_items_with_slot(source_slot)

func _return_item_from_foodcart(data: Dictionary):
	var item_type_to_return = data["item_type"]
	var source_slot = data["source_slot"]
	
	# Add the item back to inventory
	game_manager.ingredients[item_type_to_return] = game_manager.ingredients.get(item_type_to_return, 0) + 1
	game_manager.emit_signal("ingredient_changed", item_type_to_return, game_manager.ingredients[item_type_to_return])
	
	# Remove from foodcart slot AND remove 3D item
	source_slot.item_quantity -= 1
	if source_slot.item_quantity <= 0:
		source_slot.clear_slot()  # This will remove the 3D item
	else:
		source_slot.update_display()
	
	print("Returned %s to inventory. Now have: %d" % [
		item_type_to_return, 
		game_manager.ingredients.get(item_type_to_return, 0)
	])

func _swap_items_with_slot(other_slot):
	# Swap item types between two slots
	var temp_type = item_type
	var temp_texture = icon.texture
	
	item_type = other_slot.item_type
	icon.texture = other_slot.icon.texture
	
	other_slot.item_type = temp_type
	other_slot.icon.texture = temp_texture
	
	# Update both labels
	_update_label()
	other_slot._update_label()

func _update_label():
	# Update the label to show current quantity
	if item_type != "":
		var quantity = game_manager.ingredients.get(item_type, 0)
		label.text = str(quantity)
	else:
		label.text = ""
