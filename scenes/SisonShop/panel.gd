# SisonShop_UI.gd 
extends Panel

@onready var game_manager = get_node("/root/GameManager")  
@onready var grid_container: GridContainer = $GridContainer
@onready var item_flour: Panel = $GridContainer/ItemFlour
@onready var item_oil: Panel = $GridContainer/ItemOil
@onready var close: Button = $Close
@onready var money_label: Label = $MoneyLabel

var previous_mouse_mode: int = Input.MOUSE_MODE_CAPTURED

func _ready():
	# Connect right-click signals for each item
	item_oil.gui_input.connect(_on_item_oil_input)
	item_flour.gui_input.connect(_on_item_flour_input)
	close.pressed.connect(_on_close_pressed)
	
	# Connect to game manager signals to update money display
	game_manager.money_changed.connect(_on_money_changed)
	
	# Make sure we can receive mouse events
	mouse_filter = Control.MOUSE_FILTER_STOP
	item_oil.mouse_filter = Control.MOUSE_FILTER_STOP
	item_flour.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Hide shop initially
	hide()
	# Initialize money display
	_update_money_display()

func _on_close_pressed() -> void:
	hide_shop()
	
func show_shop():
	# Store current mouse mode before changing it
	previous_mouse_mode = Input.get_mouse_mode()
	show()
	# Bring to front
	get_parent().move_child(self, get_parent().get_child_count() - 1)
	# Make mouse visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Update money display when shop opens
	_update_money_display()
	print("Shop opened! Mouse should be visible.")
	print("Player money: $%d" % game_manager.money)

func hide_shop():
	hide()
	# Restore previous mouse mode
	Input.set_mouse_mode(previous_mouse_mode)
	print("Shop closed! Mouse mode restored.")
	print("Remaining money: $%d" % game_manager.money)

func _update_money_display():
	if money_label:
		money_label.text = "$%d" % game_manager.money

func _on_money_changed(new_amount):
	# Update money label whenever money changes
	_update_money_display()
	print("Money updated: $%d" % new_amount)

func _on_item_oil_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var oil_price = game_manager.shop_items["oil"]["price"]
		if game_manager.money >= oil_price:
			if game_manager.buy_ingredient("oil", 1):
				print("Successfully bought oil for $%d! Remaining: $%d" % [oil_price, game_manager.money])
				print("Oil inventory updated. Total oil: %d" % game_manager.ingredients["oil"])
			else:
				print("Failed to buy oil!")
		else:
			print("Not enough money to buy oil! Need $%d, but only have $%d" % [oil_price, game_manager.money])

func _on_item_flour_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var flour_price = game_manager.shop_items["flour"]["price"]
		if game_manager.money >= flour_price:
			if game_manager.buy_ingredient("flour", 1):
				print("Successfully bought flour for $%d! Remaining: $%d" % [flour_price, game_manager.money])
				print("Flour inventory updated. Total flour: %d" % game_manager.ingredients["flour"])
			else:
				print("Failed to buy flour!")
		else:
			print("Not enough money to buy flour! Need $%d, but only have $%d" % [flour_price, game_manager.money])

func _input(event):
	# Close shop when pressing Escape
	if event.is_action_pressed("ui_cancel") and visible:
		hide_shop()
		get_viewport().set_input_as_handled()

func _on_item_oil_gui_input(event: InputEvent) -> void:
	_on_item_oil_input(event)

func _on_item_flour_gui_input(event: InputEvent) -> void:
	_on_item_flour_input(event)
	
