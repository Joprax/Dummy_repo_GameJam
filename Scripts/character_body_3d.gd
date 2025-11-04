extends CharacterBody3D

@onready var agent = $NavigationAgent3D
@export var speed := 2.5
@export var walk_area_center := Vector3.ZERO
@export var walk_radius := 8.0
@export var idle_time_range := Vector2(2.0, 5.0)
@export var cart_visit_chance := 0.3  # 30% chance to visit cart after idle

enum State { WANDERING, IDLE, GOING_TO_CART, AT_CART, LEAVING_CART }

var current_state = State.WANDERING
var idle_timer := 0.0
var target_cart = null

func _ready():
	add_to_group("npc")
	randomize()
	walk_area_center = global_position
	
	# Wait for navigation to be ready
	await get_tree().physics_frame
	_pick_new_target()

func _physics_process(delta):
	match current_state:
		State.WANDERING:
			_handle_wandering(delta)
		State.IDLE:
			_handle_idle(delta)
		State.GOING_TO_CART:
			_move_towards_target(delta)
		State.AT_CART:
			velocity = Vector3.ZERO
			# Wait for cart to finish serving
		State.LEAVING_CART:
			_handle_wandering(delta)

func _handle_wandering(delta):
	if agent.is_navigation_finished():
		# Reached destination, go idle
		current_state = State.IDLE
		idle_timer = randf_range(idle_time_range.x, idle_time_range.y)
		velocity = Vector3.ZERO
	else:
		_move_towards_target(delta)

func _handle_idle(delta):
	idle_timer -= delta
	velocity = Vector3.ZERO
	
	if idle_timer <= 0.0:
		# Randomly decide: visit cart or keep wandering
		if randf() < cart_visit_chance:
			_try_visit_cart()
		else:
			current_state = State.WANDERING
			_pick_new_target()

func _try_visit_cart():
	var carts = get_tree().get_nodes_in_group("food_cart")
	if carts.size() > 0:
		target_cart = carts[0]  # or pick random if multiple
		var front_pos = target_cart.get_front_position()
		agent.set_target_position(front_pos)
		current_state = State.GOING_TO_CART
		print("NPC decided to visit food cart")
	else:
		# No cart found, just wander
		current_state = State.WANDERING
		_pick_new_target()

func request_service(cart):
	# Called by the cart when NPC enters Area3D
	if current_state == State.GOING_TO_CART and target_cart == cart:
		current_state = State.AT_CART
		velocity = Vector3.ZERO
		print("NPC arrived at cart, waiting for service")
		cart.start_serving(self)

func finish_shopping():
	# Called by cart when done serving
	print("NPC finished shopping, returning to wander")
	current_state = State.WANDERING
	target_cart = null
	_pick_new_target()

func _move_towards_target(delta):
	if not agent.is_navigation_finished():
		var next_pos = agent.get_next_path_position()
		var dir = (next_pos - global_position).normalized()
		
		# Smooth rotation
		var target_rot = atan2(dir.x, dir.z)
		rotation.y = lerp_angle(rotation.y, target_rot, 5.0 * delta)
		
		velocity = dir * speed
		move_and_slide()

func _pick_new_target():
	var nav_map = agent.get_navigation_map()
	var tries = 0
	
	while tries < 10:
		var random_offset = Vector3(
			randf_range(-walk_radius, walk_radius),
			0,
			randf_range(-walk_radius, walk_radius)
		)
		var test_pos = walk_area_center + random_offset
		
		var nav_pos = NavigationServer3D.map_get_closest_point(nav_map, test_pos)
		
		if nav_pos != Vector3.ZERO:
			agent.set_target_position(nav_pos)
			return
		
		tries += 1
	
	# Fallback
	agent.set_target_position(walk_area_center)
