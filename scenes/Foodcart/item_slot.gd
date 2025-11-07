# FoodcartSlot.gd (Foodcart Slots)
extends Panel

@onready var icon: TextureRect = $Icon
@onready var label: Label = $Label
@onready var game_manager = get_node("/root/GameManager")

var item_type: String = ""
var item_quantity: int = 0

func _ready():
	# Initialize display
	update_display()
	
	# CRITICAL: Ensure this slot can receive mouse events for drag-and-drop
	mouse_filter = Control.MOUSE_FILTER_STOP

func _get_drag_data(at_position: Vector2) -> Variant:
	# Allow dragging items back to inventory
	if icon.texture == null or item_quantity <= 0:
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
	
	return {
		"type": "foodcart_item",
		"item_type": item_type,
		"source_slot": self,
		"texture": icon.texture,
		"from_foodcart": true  # Mark that this is coming from foodcart
	}

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	# Accept both inventory items and foodcart items (for reorganization)
	return data is Dictionary and data.has("type") and (data["type"] == "inventory_item" or data["type"] == "foodcart_item")

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data.has("from_foodcart") and data["from_foodcart"]:
		# Item is coming from another foodcart slot - handle reorganization
		_handle_foodcart_reorganization(data)
	else:
		# Item is coming from inventory
		var item_type_to_transfer = data["item_type"]
		var source_slot = data["source_slot"]
		
		# Transfer item from inventory to foodcart
		if game_manager.use_ingredient(item_type_to_transfer):
			# Successfully removed from inventory
			_add_item_to_slot(item_type_to_transfer)
			
			# Update the source slot in inventory
			if source_slot.has_method("_update_label"):
				source_slot._update_label()
			
			# SPAWN 3D ITEM ON THE SPECIFIC COOKING STATION
			_spawn_3d_item(item_type_to_transfer)
			
			print("Transferred %s to foodcart. Remaining in inventory: %d" % [
				item_type_to_transfer, 
				game_manager.ingredients.get(item_type_to_transfer, 0)
			])
		else:
			print("No %s available to transfer" % item_type_to_transfer)

func _spawn_3d_item(item_type: String):
	# Get the specific cooking station node from the main scene
	var cooking_station = _get_cooking_station_node()
	if cooking_station:
		# Remove any existing 3D items first from this station
		_remove_3d_items_from_station(cooking_station)
		
		# Spawn the appropriate 3D scene
		var scene_path = _get_3d_scene_path(item_type)
		if scene_path:
			var scene = load(scene_path)
			var instance = scene.instantiate()
			
			# Add as child of the specific cooking station node
			cooking_station.add_child(instance)
			
			# Position relative to the cooking station (adjust height as needed)
			instance.position = Vector3(0, 0.3, 0)  # Slightly above the station
			
			print("Spawned %s on %s" % [item_type, cooking_station.name])

func _remove_3d_items_from_station(cooking_station: Node3D):
	# Remove any existing 3D items from this specific cooking station
	for child in cooking_station.get_children():
		if child.name.begins_with("flour") or child.name.begins_with("oil") or child.has_method("queue_free"):
			child.queue_free()

func _get_cooking_station_node() -> Node3D:
	var grid_container = get_parent()
	
	if grid_container.name == "GridContainerPan":
		return get_tree().get_first_node_in_group("frying_pan")
	elif grid_container.name == "GridContainerBowl":
		return get_tree().get_first_node_in_group("coating_bowl")
	elif grid_container.name == "GridContainerBoard":
		return get_tree().get_first_node_in_group("chopping_board")
	
	return null

func _get_3d_scene_path(item_type: String) -> String:
	match item_type:
		"flour":
			return "res://flour.tscn"
		"oil":
			return "res://oil.tscn"
		# Add bread and sauce later when you have their scenes
		"bread":
			return ""
		"sauce":
			return ""
	return ""

func _handle_foodcart_reorganization(data: Dictionary):
	var source_slot = data["source_slot"]
	var source_item_type = data["item_type"]
	
	# Don't reorganize with ourselves
	if source_slot == self:
		return
	
	if item_type == "":
		# This slot is empty, take the item
		item_type = source_item_type
		icon.texture = data["texture"]
		item_quantity = source_slot.item_quantity
		source_slot.clear_slot()
		
		# Update 3D items for both slots
		_spawn_3d_item(item_type)
		if source_slot.has_method("_get_cooking_station_node"):
			var source_station = source_slot._get_cooking_station_node()
			if source_station:
				_remove_3d_items_from_station(source_station)
		
	elif item_type == source_item_type:
		# Same item type, merge quantities
		item_quantity += source_slot.item_quantity
		source_slot.clear_slot()
		# No need to change 3D items since it's the same type
	else:
		# Different item types, swap
		var temp_type = item_type
		var temp_texture = icon.texture
		var temp_quantity = item_quantity
		
		item_type = source_item_type
		icon.texture = data["texture"]
		item_quantity = source_slot.item_quantity
		
		source_slot.item_type = temp_type
		source_slot.icon.texture = temp_texture
		source_slot.item_quantity = temp_quantity
		source_slot.update_display()
		
		# Update 3D items for both slots
		_spawn_3d_item(item_type)
		if source_slot.has_method("_spawn_3d_item"):
			source_slot._spawn_3d_item(source_slot.item_type)
	
	update_display()

func _add_item_to_slot(new_item_type: String):
	if item_type == "":
		# Slot is empty, add the new item
		item_type = new_item_type
		icon.texture = _get_item_texture(new_item_type)
		item_quantity = 1
	elif item_type == new_item_type:
		# Same item type, increase quantity
		item_quantity += 1
	else:
		# Different item type - replace
		item_type = new_item_type
		icon.texture = _get_item_texture(new_item_type)
		item_quantity = 1
	
	update_display()

func _get_item_texture(item_type: String) -> Texture2D:
	match item_type:
		"oil":
			return preload("res://OildaGreat.svg")
		"flour":
			return preload("res://FlourdaGreat.svg")
		"bread":
			return preload("res://icon.svg")
		"sauce":
			return preload("res://icon.svg")
	return null

func update_display():
	if item_quantity > 0:
		label.text = str(item_quantity)
		if icon.texture == null and item_type != "":
			icon.texture = _get_item_texture(item_type)
	else:
		clear_slot()

func clear_slot():
	# Remove 3D item when slot is cleared
	var cooking_station = _get_cooking_station_node()
	if cooking_station:
		_remove_3d_items_from_station(cooking_station)
	
	item_type = ""
	item_quantity = 0
	icon.texture = null
	label.text = ""
