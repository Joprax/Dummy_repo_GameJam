# Foodcart_UI.gd
extends Panel

@onready var close: Button = $Close
@onready var done: Button = $Done
@onready var grid_container_pan: GridContainer = $GridContainerPan
@onready var grid_container_bowl: GridContainer = $GridContainerBowl
@onready var grid_container_board: GridContainer = $GridContainerBoard

var previous_mouse_mode: int = Input.MOUSE_MODE_CAPTURED

func _ready():
	add_to_group("foodcart_ui")
	close.pressed.connect(_on_close_pressed)
	done.pressed.connect(_on_done_pressed)
	
	# Hide UI initially
	hide()

func _on_close_pressed():
	hide_foodcart()

func _on_done_pressed():
	# Process the cooking logic when Done is pressed
	_process_cooking()
	hide_foodcart()

func _process_cooking():
	# Check what items are in each station and try to cook
	print("Processing cooking stations...")
	
	# Get items from each grid container
	var pan_items = _get_items_from_grid(grid_container_pan)
	var bowl_items = _get_items_from_grid(grid_container_bowl)
	var board_items = _get_items_from_grid(grid_container_board)
	
	print("Pan items: ", pan_items)
	print("Bowl items: ", bowl_items)
	print("Board items: ", board_items)
	
	# Add your cooking logic here
	# Example: if flour and oil are in pan, create cooked food
	# if "flour" in pan_items and "oil" in pan_items:
	#     game_manager.add_cooked_food()
	#     _clear_grid(grid_container_pan)

func _get_items_from_grid(grid: GridContainer) -> Array:
	var items = []
	for slot in grid.get_children():
		if slot.has_method("get_item_type") and slot.item_type != "":
			items.append(slot.item_type)
	return items

func _clear_grid(grid: GridContainer):
	for slot in grid.get_children():
		if slot.has_method("clear_slot"):
			slot.clear_slot()

func show_foodcart():
	# Store current mouse mode before changing it
	previous_mouse_mode = Input.get_mouse_mode()
	show()
	# Bring to front
	get_parent().move_child(self, get_parent().get_child_count() - 1)
	# Make mouse visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print("Foodcart UI opened!")

func hide_foodcart():
	hide()
	# Restore previous mouse mode
	Input.set_mouse_mode(previous_mouse_mode)
	print("Foodcart UI closed!")

func _input(event):
	# Close UI when pressing Escape
	if event.is_action_pressed("ui_cancel") and visible:
		hide_foodcart()
		get_viewport().set_input_as_handled()
