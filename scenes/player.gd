extends Node2D

const Common = preload("res://lib/common.gd")

@export var cell_size: int = 32
@export var speed: int = 200

var max_pos: Vector2
var min_pos: Vector2

var direction: Vector2
var next_direction: Vector2

var target_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
    min_pos = Vector2.ZERO

    var screen_size = get_viewport_rect().size
    var max_x = (floori(screen_size.x / cell_size) - 1) * cell_size
    var max_y = (floori(screen_size.y / cell_size) - 1) * cell_size
    max_pos = Vector2(max_x, max_y)

    direction = Vector2.RIGHT
    next_direction = direction
    target_position = position
    
    $AnimatedSprite2D.animation = "idle"
    $AnimatedSprite2D.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
    if Input.is_action_pressed("move_right"):
        next_direction = Vector2.RIGHT
        $AnimatedSprite2D.animation = "right"
    elif Input.is_action_pressed("move_left"):
        next_direction = Vector2.LEFT
        $AnimatedSprite2D.animation = "left"
    elif Input.is_action_pressed("move_down"):
        next_direction = Vector2.DOWN
        $AnimatedSprite2D.animation = "down"
    elif Input.is_action_pressed("move_up"):
        next_direction = Vector2.UP
        $AnimatedSprite2D.animation = "up"

    if position != target_position:
        var previous_position = position
        var velocity = direction * speed
        # enforce new position to be between current and target position
        position = Common.clamped(position + velocity * delta, previous_position, target_position)
        
func _on_move_timer_timeout() -> void:
    direction = next_direction
    # enforce target position within screen bounds
    target_position = Common.clamped(position + direction * cell_size, min_pos, max_pos);
    # if target position was not changed, we hit something, so it's game over
    if position == target_position:
        $AnimatedSprite2D.animation = "angry"
