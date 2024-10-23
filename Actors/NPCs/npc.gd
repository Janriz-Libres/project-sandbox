extends CharacterBody2D

@onready var state_timer: Timer = $StateTimer

@export var MAX_SPEED: int = 80
@export var ACCELERATION: int = 10
@export var FRICTION: int = 10
@export var WANDER_RANGE: int = 32

enum State {
	IDLE,
	WANDER
}

var state: State = State.IDLE
var wander_target: Vector2 = Vector2.ZERO

func _physics_process(delta) -> void:
	match (state):
		State.IDLE:
			idle_state()
		State.WANDER:
			wander_state()
	
	move_and_slide()

func idle_state() -> void:
	velocity.move_toward(Vector2.ZERO, FRICTION)

func wander_state() -> void:
	var distance: float = global_position.distance_to(wander_target)
	
	if (distance <= 4):
		velocity.move_toward(Vector2.ZERO, FRICTION)
	else:
		var direction: Vector2 = global_position.direction_to(wander_target)
		velocity.move_toward(direction * MAX_SPEED, ACCELERATION)

func randomize_state() -> State:
	var random_index: int = randi_range(0, State.size() - 1)
	return State.values()[random_index]

func pick_wander_target() -> Vector2:
	# Step 1: Pick a random angle between 0 and 2 * PI
	var angle: float = randf_range(0, 2 * PI)

	# Step 2: Pick a random distance, scaled by the square root for uniformity
	var distance: float = sqrt(randf()) * WANDER_RANGE

	# Step 3: Convert polar coordinates (distance, angle) to Cartesian coordinates (x, y)
	var x: float = cos(angle) * distance
	var y: float = sin(angle) * distance

	return global_position + Vector2(x, y)

func _on_state_timer_timeout() -> void:
	state = randomize_state()
	if state == State.WANDER:
		wander_target = pick_wander_target()
	
