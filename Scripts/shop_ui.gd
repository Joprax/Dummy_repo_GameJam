# shop_ui_3d.gd
extends Panel

@onready var money_label = $MoneyLabel
@onready var buy_button = $Button  # The "Buy" button
@onready var close_button = $Button2  # The "Close" button

# Get all ItemCard instances
@onready var item_cards = [
	$"ItemCard(Flour)",
	$"ItemCard(Oil)"
	# Add more if you have more cards
]

var shop_visible: bool = false

func _ready():
	add_to_group("shop_ui")
	buy_button.pressed.connect(_on_buy_pressed)
	close_button.pressed.connect(_on_close_pressed)
	hide_shop()
	_update_money_display()

func show_shop():
	shop_visible = true
	visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_update_money_display()
	print("Shop opened")

func hide_shop():
	shop_visible = false
	visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Reset all cards
	for card in item_cards:
		if card:
			card.reset_card()
	print("Shop closed")

func _on_buy_pressed():
	var total_cost = 0
	var orders = []
	
	# Collect all checked items
	for card in item_cards:
		if card:
			var order = card.get_order()
			if not order.is_empty():
				orders.append(order)
				total_cost += order["price"] * order["quantity"]
	
	if orders.size() == 0:
		print("No items selected!")
		return
	
	# Check if player has enough money
	if GameManager.money >= total_cost:
		# Process purchase
		for order in orders:
			GameManager.buy_ingredient(order["item"], order["quantity"])
		
		print("Purchased items! Total cost: $%d" % total_cost)
		_update_money_display()
		
		# Reset cards after purchase
		for card in item_cards:
			if card:
				card.reset_card()
	else:
		print("Not enough money! Need $%d, have $%d" % [total_cost, GameManager.money])

func _on_close_pressed():
	hide_shop()

func _update_money_display():
	if money_label:
		money_label.text = "$%d" % GameManager.money

func _unhandled_input(event):
	if shop_visible and event.is_action_pressed("ui_cancel"):
		hide_shop()
		get_viewport().set_input_as_handled()
