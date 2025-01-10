extends Area2D

const Common = preload("res://lib/common.gd")

signal game_over

@export var cell_size: int = 16
@export var speed: int = 200

var direction: Vector2
var next_direction: Vector2
var target_position: Vector2

func reset_position():
    position = Vector2(cell_size * 8, cell_size * 5)
    target_position = position

func start():
    reset_position()
    direction = Vector2.RIGHT
    next_direction = direction
    $CollisionShape2D.set_deferred("disabled", false)
    show()  
    $MoveTimer.start()
    
func stop():
    hide()
    $MoveTimer.stop()
    game_over.emit()

func _ready():
    hide()
    
    # Initial direction

    
    # var screen_size = get_viewport_rect().size

func _process(delta: float):
    if Input.is_action_pressed("move_right"):
        if move_allowed(Vector2.RIGHT):
            next_direction = Vector2.RIGHT
    elif Input.is_action_pressed("move_left"):
        if move_allowed(Vector2.LEFT):
            next_direction = Vector2.LEFT
    elif Input.is_action_pressed("move_down"):
        if move_allowed(Vector2.DOWN):
            next_direction = Vector2.DOWN
    elif Input.is_action_pressed("move_up"):
        if move_allowed(Vector2.UP):
            next_direction = Vector2.UP

    if position != target_position:
        var previous_position = position
        var velocity = direction * speed
        # enforce new position to be between current and target position
        position = Common.clamped(position + velocity * delta, previous_position, target_position)

func move_allowed(next_direction) -> bool:
    return (direction + next_direction) != Vector2.ZERO

func _on_move_timer_timeout() -> void:
    direction = next_direction
    # enforce target position within screen bounds
    target_position = position + direction * cell_size;

    # if target position was not changed, we hit something, so it's game over
    #if position == target_position:
    #   stop()

func _on_body_entered(body: Node2D) -> void:
    print(body)
    stop()
