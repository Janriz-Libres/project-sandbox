extends CharacterBody2D

@onready var timer: Timer = $Timer

@export var ACCELERATION: int = 300
@export var MAX_SPEED: int = 50
@export var FRICTION: int = 200

enum State {
	IDLE,
	WANDER
}

var state: State = State.IDLE

func _physics_process(delta):
	match (state):
		State.IDLE:
			idle_state()
		State.WANDER:
			wander_state()
	
	move_and_slide()

func idle_state():
	velocity.move_toward(Vector2.ZERO, FRICTION)
	
func wander_state():
	pass
