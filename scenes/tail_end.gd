extends AnimatableBody2D

const Common = preload("res://lib/common.gd")

@export var move_animation_speed: int = 200

signal tail_left_previous_cell

var direction: Vector2
var target_position: Vector2

func _ready() -> void:
    pass

func _process(delta: float) -> void:
    if position != target_position:
        var velocity = direction * move_animation_speed
        # enforce new position to be between current and target position
        position = Common.clamped(position + velocity * delta, position, target_position)
    elif direction != Vector2.ZERO:
        # snake finished moving to new cell, so previous cell can be cleared
        tail_left_previous_cell.emit()
        direction = Vector2.ZERO

func move(new_target_position: Vector2) -> void:
    direction = (new_target_position - target_position).normalized()
    target_position = new_target_position

func start(new_position: Vector2):
    position = new_position
    target_position = new_position
    direction = Vector2.ZERO
    show()
