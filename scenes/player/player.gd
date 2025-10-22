extends CharacterBody2D

##################################################
enum PlayerState {
	IDLE,
	RUN
}
enum PlayerDirection {
	LEFT,
	RIGHT
}

const RUN_SPEED = 300.0

var current_state: PlayerState = PlayerState.IDLE
var current_direction: PlayerDirection = PlayerDirection.RIGHT

@onready var animated_node: AnimatedSprite2D = $AnimatedSprite2D

##################################################
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var input_direction := Input.get_axis("ui_left", "ui_right")
	if input_direction:
		velocity.x = input_direction * RUN_SPEED
		current_state = PlayerState.RUN
		if input_direction > 0:
			current_direction = PlayerDirection.RIGHT
		else:
			current_direction = PlayerDirection.LEFT
	else:
		velocity.x = move_toward(velocity.x, 0, RUN_SPEED)
		current_state = PlayerState.IDLE
	
	_set_state(current_state, current_direction)
	move_and_slide()

##################################################
func _set_state(state: PlayerState, direction: PlayerDirection) -> void:
	match state:
		PlayerState.IDLE:
			animated_node.play("idle")
		PlayerState.RUN:
			animated_node.play("run")
	
	match direction:
		PlayerDirection.LEFT:
			animated_node.flip_h = true
		PlayerDirection.RIGHT:
			animated_node.flip_h = false
		_:
			pass
