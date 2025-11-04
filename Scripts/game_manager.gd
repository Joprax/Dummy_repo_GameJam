# game_manager.gd
extends Node

# Player inventory
var money: int = 200
var ingredients: Dictionary = {
	"flour": 0,      # Changed from "meat"
	"oil": 0,        # Changed from "vegetables"
	"bread": 0,
	"sauce": 0
}

# Cooking stations state
var chopping_board_items: Array = []  # Items on chopping board
var bowl_items: Array = []  # Items in coating bowl
var cooked_foods: int = 0  # Ready to sell

# Food cart state
var is_cart_open: bool = false
var current_time: float = 8.0  # 8:00 AM
var foods_sold: int = 0

# Shop catalog
var shop_items: Dictionary = {
	"flour": {"price": 5, "description": "Flour for baking"},
	"oil": {"price": 3, "description": "Cooking oil"},
	"bread": {"price": 3, "description": "Soft bread"},
	"sauce": {"price": 4, "description": "Special sauce"}
}

signal money_changed(new_amount)
signal ingredient_changed(ingredient_name, new_amount)
signal cart_status_changed(is_open)
signal time_changed(hour)
signal cooked_food_changed(amount)

func buy_ingredient(ingredient_name: String, quantity: int = 1) -> bool:
	if not shop_items.has(ingredient_name):
		return false
	
	var total_cost = shop_items[ingredient_name]["price"] * quantity
	
	if money >= total_cost:
		money -= total_cost
		ingredients[ingredient_name] += quantity
		emit_signal("money_changed", money)
		emit_signal("ingredient_changed", ingredient_name, ingredients[ingredient_name])
		return true
	return false

func use_ingredient(ingredient_name: String) -> bool:
	if ingredients.has(ingredient_name) and ingredients[ingredient_name] > 0:
		ingredients[ingredient_name] -= 1
		emit_signal("ingredient_changed", ingredient_name, ingredients[ingredient_name])
		return true
	return false

func add_cooked_food():
	cooked_foods += 1
	emit_signal("cooked_food_changed", cooked_foods)

func sell_food():
	if cooked_foods > 0:
		cooked_foods -= 1
		foods_sold += 1
		money += 20  # Price per food
		emit_signal("money_changed", money)
		emit_signal("cooked_food_changed", cooked_foods)
		return true
	return false

func toggle_cart():
	is_cart_open = !is_cart_open
	if is_cart_open:
		current_time = 8.0
		foods_sold = 0
	emit_signal("cart_status_changed", is_cart_open)

func reset_day():
	# Call this at end of day or when needed
	chopping_board_items.clear()
	bowl_items.clear()
	is_cart_open = false
	current_time = 8.0
	foods_sold = 0
