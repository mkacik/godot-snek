extends MovingBody

const MovingBody = preload("res://lib/moving_body.gd")

signal wall_hit
signal apple_eaten

func start(new_position: Vector2) -> void:
    super(new_position)
    $CollisionShape2D.set_deferred("disabled", false)

func stop() -> void:
    super()
    $CollisionShape2D.set_deferred("disabled", true)

func can_move(maybe_next_direction: Vector2) -> bool:
    return (direction + maybe_next_direction) != Vector2.ZERO

func _on_body_entered(body: Node2D) -> void:
    if (body.name == "Apple"):
        apple_eaten.emit()
    else:
        wall_hit.emit()
