extends Node2D

@export var cell_size: int = 16

func _ready() -> void:
    position_walls()

func _process(delta: float) -> void:
    pass

func position_walls() -> void:
    var screen_size: Vector2 = get_viewport_rect().size / cell_size

    $WallN.position = Vector2.ZERO
    $WallS.position = Vector2(0, screen_size.y - 1) * cell_size
    
    var outer_wall_x_scale = Vector2(screen_size.x, 1)
    $WallN.apply_scale(outer_wall_x_scale)
    $WallS.apply_scale(outer_wall_x_scale)
    
    $WallE.position = Vector2(screen_size.x - 1, 1) * cell_size
    $WallW.position = Vector2(0, 1) * cell_size

    var outer_wall_y_scale = Vector2(1, screen_size.y - 2)
    $WallE.apply_scale(outer_wall_y_scale)
    $WallW.apply_scale(outer_wall_y_scale)

func show_walls() -> void:
    get_tree().call_group("walls", "show")
    
func start() -> void:
    show_walls()
