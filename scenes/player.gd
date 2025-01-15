extends Area2D

const Common = preload("res://lib/common.gd")

signal wall_hit
signal apple_eaten
signal finished_moving

@export var move_animation_speed: int = 100

var direction: Vector2
var target_position: Vector2

func _ready():
    pass

func _process(delta: float):
    if position == target_position:
        return

    var velocity = direction * Common.MOVE_ANIMATION_SPEED
    # enforce new position to be between current and target position
    position = Common.clamped(position + velocity * delta, position, target_position)
    if position == target_position:
        finished_moving.emit()

func start(new_position: Vector2):
    position = new_position
    target_position = new_position
    direction = Vector2.ZERO
    $CollisionShape2D.set_deferred("disabled", false)

func is_move_allowed(maybe_next_direction) -> bool:
    return (direction + maybe_next_direction) != Vector2.ZERO

func move(new_position: Vector2) -> void:
    direction = (new_position - position).normalized()
    target_position = new_position

func _on_body_entered(body: Node2D) -> void:
    if (body.name == "Apple"):
        apple_eaten.emit()
    else:
        wall_hit.emit()
