extends Node2D

@export var cell_size: int = 16
var grid_size: Vector2
var unoccupied_cells = {}

func _ready() -> void:
    grid_size = get_viewport_rect().size / cell_size

func _process(_delta: float) -> void:
    pass

func position_walls() -> void:
    $WallN.position = Vector2.ZERO
    $WallS.position = Vector2(0, grid_size.y - 1) * cell_size
    
    var outer_wall_x_scale = Vector2(grid_size.x, 1)
    $WallN.apply_scale(outer_wall_x_scale)
    $WallS.apply_scale(outer_wall_x_scale)
    
    $WallE.position = Vector2(grid_size.x - 1, 1) * cell_size
    $WallW.position = Vector2(0, 1) * cell_size

    var outer_wall_y_scale = Vector2(1, grid_size.y - 2)
    $WallE.apply_scale(outer_wall_y_scale)
    $WallW.apply_scale(outer_wall_y_scale)

func reset_unoccupied_cells() -> void:
    unoccupied_cells = {}
    for x in range(1, grid_size.x - 1):
        for y in range(1, grid_size.y - 1):
            mark_grid_cell_unoccupied(Vector2(x, y))

func start() -> void:
    position_walls()
    reset_unoccupied_cells()
    show()

func mark_grid_cell_occupied(grid_position: Vector2) -> void:
    unoccupied_cells.erase(grid_position)

func mark_grid_cell_unoccupied(grid_position: Vector2) -> void:
    unoccupied_cells[grid_position] = null
    
func get_random_unoccupied_grid_cell() -> Vector2:
    return unoccupied_cells.keys().pick_random()
