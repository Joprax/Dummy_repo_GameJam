# food_cart.gd
extends Node3D

@onready var area = $Area3D
@onready var front_spot = $FrontSpot

var current_customer = null
var is_serving = false
var time_speed: float = 0.5  # Game minutes per real second

func _ready():
	add_to_group("food_cart")
	area.body_entered.connect(_on_body_entered)

func _process(delta):
	if GameManager.is_cart_open:
		GameManager.current_time += delta * time_speed / 60.0
		
		# Auto-close at 8 PM
		if GameManager.current_time >= 20.0:
			print("It's 8 PM! Shop closed. Sold %d foods today." % GameManager.foods_sold)
			GameManager.toggle_cart()

func _on_body_entered(body):
	if body.is_in_group("npc") and GameManager.is_cart_open:
		if current_customer == null and GameManager.cooked_foods > 0:
			body.request_service(self)

func start_serving(npc):
	if current_customer == null and GameManager.cooked_foods > 0:
		current_customer = npc
		is_serving = true
		await get_tree().create_timer(randf_range(2.0, 3.0)).timeout
		finish_serving()

func finish_serving():
	if current_customer:
		if GameManager.sell_food():
			print("Sold food! Money: $%d, Remaining: %d" % [GameManager.money, GameManager.cooked_foods])
		current_customer.finish_shopping()
		current_customer = null
		is_serving = false

func get_front_position() -> Vector3:
	return front_spot.global_position
