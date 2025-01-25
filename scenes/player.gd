extends Area2D

const Common = preload("res://lib/common.gd")

signal wall_hit
signal apple_eaten
signal finished_moving

var direction: Vector2
var target_position: Vector2
var paused: bool

func _ready():
    pass

func _process(delta: float):
    if paused:
        return

    if position == target_position:
        return

    var velocity = direction * Common.MOVE_ANIMATION_SPEED
    var position_delta = velocity * delta
    position = Common.clamped(position + position_delta, position, target_position)
    if position == target_position:
        finished_moving.emit()

func start(new_position: Vector2) -> void:
    position = new_position
    target_position = new_position
    direction = Vector2.ZERO
    paused = false
    $CollisionShape2D.set_deferred("disabled", false)

func stop() -> void:
    position = Vector2.ZERO
    target_position = Vector2.ZERO
    direction = Vector2.ZERO
    paused = true
    $CollisionShape2D.set_deferred("disabled", true)

func pause() -> void:
    paused = true

func unpause() -> void:
    paused = false

func move(new_position: Vector2) -> void:
    direction = (new_position - position).normalized()
    target_position = new_position

func can_move(maybe_next_direction: Vector2) -> bool:
    return (direction + maybe_next_direction) != Vector2.ZERO

func _on_body_entered(body: Node2D) -> void:
    if (body.name == "Apple"):
        apple_eaten.emit()
    else:
        wall_hit.emit()
