extends Node2D

@export var cell_size: int = 16
var grid_size: Vector2
var cells: Cells

func _ready() -> void:
    grid_size = get_viewport_rect().size / cell_size
    cells = Cells.new(grid_size)

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

func start() -> void:
    cells.initialize()
    position_walls()
    show()

func mark_grid_cell_occupied(cell: Vector2) -> void:
    cells.mark_occupied(cell)

func mark_grid_cell_unoccupied(cell: Vector2) -> void:
    cells.mark_free(cell)
    
func get_random_unoccupied_grid_cell() -> Vector2:
    return cells.get_random_free_cell()


# This class is used to keep track of free cells to spawn the apples on. When
# picking position at random, there is a risk of selecting cell that snake is
# currently on (or a wall with more complex levels). The longer the snake is,
# the higher risk of not being able to find a free cell randomly in reasonable
# time, so I chose to track the free cells instead, marking them occupied
# when snake enters, and marking them free when tail end leaves.
class Cells extends Node:
    # GDScript does not have sets, but hashmap with null values will do
    var free_cells = {}
    var grid_size

    func _init(new_grid_size: Vector2) -> void:
        grid_size = new_grid_size

    func initialize():
        free_cells.clear()
        for x in range(0, grid_size.x):
            for y in range(0, grid_size.y):
                var cell = Vector2(x, y)
                free_cells[cell] = null

    func mark_free(cell: Vector2) -> void:
        free_cells[cell] = null

    func mark_occupied(cell: Vector2) -> void:
        free_cells.erase(cell)

    func get_random_free_cell() -> Vector2:
        return free_cells.keys().pick_random()
