extends CanvasLayer

func _ready():
	var center = $CenterContainer
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var dot = center.get_child(0)
	if dot is Control:
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(_delta):
	# Hide crosshair when inventory UI is visible
	# Adjust the path to match your scene structure
	var inventory = get_tree().get_first_node_in_group("inventory_ui")
	if inventory and inventory.visible:
		visible = false
	else:
		visible = true
