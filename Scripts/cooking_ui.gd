# cooking_ui.gd
extends CanvasLayer

@onready var panel = $Panel
@onready var ingredient_list = $Panel/VBoxContainer/ItemList
@onready var select_button = $Panel/VBoxContainer/SelectButton
@onready var close_button = $Panel/VBoxContainer/CloseButton
@onready var title_label = $Panel/VBoxContainer/TitleLabel

var current_station = ""

func _ready():
	add_to_group("cooking_ui")
	panel.hide()
	select_button.pressed.connect(_on_select_pressed)
	close_button.pressed.connect(_on_close_pressed)

func show_ingredient_selection(station_name: String):
	current_station = station_name
	title_label.text = "Select Ingredient"
	panel.show()
	get_tree().paused = true
	_populate_ingredients()

func _populate_ingredients():
	ingredient_list.clear()
	for ingredient in GameManager.ingredients.keys():
		var count = GameManager.ingredients[ingredient]
		var text = "%s (x%d)" % [ingredient.capitalize(), count]
		ingredient_list.add_item(text)
		if count == 0:
			var idx = ingredient_list.item_count - 1
			ingredient_list.set_item_disabled(idx, true)

func _on_select_pressed():
	var selected = ingredient_list.get_selected_items()
	if selected.size() == 0:
		return
	
	var ingredient_names = GameManager.ingredients.keys()
	var ingredient = ingredient_names[selected[0]]
	
	if current_station == "chopping_board":
		var board = get_tree().get_first_node_in_group("chopping_board")
		if board:
			board.add_ingredient(ingredient)
	
	_on_close_pressed()

func _on_close_pressed():
	panel.hide()
	get_tree().paused = false
