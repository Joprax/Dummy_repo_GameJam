extends CanvasLayer

func _ready():
	# Get the CenterContainer node (assuming it's a direct child)
	var center = $CenterContainer
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Get the ColorRect node (child of CenterContainer)
	var dot = center.get_child(0)  # Or use $CenterContainer/ColorRect
	if dot is Control:
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
