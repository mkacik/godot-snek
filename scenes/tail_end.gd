extends AnimatableBody2D

const Common = preload("res://lib/common.gd")

signal finished_moving

var direction: Vector2
var target_position: Vector2

func _ready() -> void:
    pass

func _process(delta: float) -> void:
    if position == target_position:
        return

    var velocity = direction * Common.MOVE_ANIMATION_SPEED
    var position_delta = ceil(velocity * delta)
    position = Common.clamped(position + position_delta, position, target_position)
    if position == target_position:
        finished_moving.emit()

func move(new_target_position: Vector2) -> void:
    direction = (new_target_position - target_position).normalized()
    target_position = new_target_position

func start(new_position: Vector2) -> void:
    position = new_position
    target_position = new_position
    direction = Vector2.ZERO

func stop() -> void:
    position = Vector2.ZERO
    target_position = Vector2.ZERO
    direction = Vector2.ZERO
