extends Node2D

const Common = preload("res://lib/common.gd")

@export var cell_size: int = 32
@export var speed: int = 400

var max_pos: Vector2
var min_pos: Vector2

var direction: Vector2
var target_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
    min_pos = Vector2.ZERO

    var screen_size = get_viewport_rect().size
    var max_x = (floori(screen_size.x / cell_size) - 1) * cell_size
    var max_y = (floori(screen_size.y / cell_size) - 1) * cell_size
    max_pos = Vector2(max_x, max_y)

    direction = Vector2.ZERO
    target_position = position
    
    $AnimatedSprite2D.animation = "idle"
    $AnimatedSprite2D.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
    # if moving is in progress, animate 
    
    
    # allow movement only if player was not already moving
    if direction == Vector2.ZERO:    
        if Input.is_action_pressed("move_right"):
            direction.x += 1
            $AnimatedSprite2D.animation = "right"
        if Input.is_action_pressed("move_left"):
            direction.x -= 1
            $AnimatedSprite2D.animation = "left"
        if Input.is_action_pressed("move_down"):
            direction.y += 1
            $AnimatedSprite2D.animation = "down"
        if Input.is_action_pressed("move_up"):
            direction.y -= 1
            $AnimatedSprite2D.animation = "up"

        if direction.length() != 0:
            # enforce target position within screen bounds
            target_position = Common.clamped(position + direction * cell_size, min_pos, max_pos);           
            # if target position was not a valid one, we hit something, so it's game over
            if position == target_position:
                $AnimatedSprite2D.animation = "angry"
        else:
            $AnimatedSprite2D.animation = "idle"
            
    
    if position != target_position:
        var previous_position = position
        var velocity = direction * speed
        
        # enforce new position to be between current and target position
        position = Common.clamped(position + velocity * delta, previous_position, target_position)
    else:
        direction = Vector2.ZERO
        
func _on_move_timer_timeout() -> void:
    # if new direction was selected, use it; if not, use previously selected one
    pass
