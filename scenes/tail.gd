extends AnimatableBody2D

func _ready() -> void:
    pass # Replace with function body.

func _process(delta: float) -> void:
    pass

func deferred_enable_collisions() -> void:
    $CollisionShape2D.set_deferred("disabled", false)

func deferred_disable_collisions() -> void:
    $CollisionShape2D.set_deferred("disabled", true)
