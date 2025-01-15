extends Node2D

signal game_over

@export var wall_scene: PackedScene
@export var tail_scene: PackedScene
@export var apple_scene: PackedScene

@export var cell_size: int = 16
var grid_size: Vector2
var cells: Cells

# All relevant positions that need tracking, all expressed as grid cell.
# Storing them in Level class allows for making moving child nodes cell-size
# agnostic
var next_direction

var player_cell
var player_target_cell
var tail_end_cell
var tail_end_target_cell
var tail_segments = []

func _ready() -> void:
    grid_size = get_viewport_rect().size / cell_size
    cells = Cells.new(grid_size)

func _process(delta: float):
    if Input.is_action_pressed("move_right"):
        if $Player.is_move_allowed(Vector2.RIGHT):
            next_direction = Vector2.RIGHT
    elif Input.is_action_pressed("move_left"):
        if $Player.is_move_allowed(Vector2.LEFT):
            next_direction = Vector2.LEFT
    elif Input.is_action_pressed("move_down"):
        if $Player.is_move_allowed(Vector2.DOWN):
            next_direction = Vector2.DOWN
    elif Input.is_action_pressed("move_up"):
        if $Player.is_move_allowed(Vector2.UP):
            next_direction = Vector2.UP

func spawn_wall(cell: Vector2):
    var wall = wall_scene.instantiate()
    wall.position = cell * cell_size
    add_child(wall)
    cells.mark_occupied(cell)

func spawn_walls() -> void:
    for x in range(0, grid_size.x):
        # only top and bottom rows
        for y in [0, grid_size.y - 1]:
            spawn_wall(Vector2(x, y))
    
    # skipping first and last rows because they were covered by loop above
    for y in range(1, grid_size.y - 1):
        for x in [0, grid_size.x - 1]:
            spawn_wall(Vector2(x, y))
            
func spawn_apple() -> void:
    # no need to mark previous cell free: this function is only called on start
    # and when apple is eaten. In latter case, that means snake head is now
    # occupying the position
    var cell = cells.get_random_free_cell()
    $Apple.position = cell * cell_size
    cells.mark_occupied(cell)

func spawn_tail_segment(cell: Vector2):
    var tail_segment = tail_scene.instantiate()
    tail_segment.name = "TailBody" + str(tail_segments.size())
    tail_segment.position = cell * cell_size
    tail_segments.push_back(tail_segment)
    add_child(tail_segment)
    cells.mark_occupied(cell)

func spawn_player(cell: Vector2):
    player_cell = cell
    $Player.start(cell * cell_size)
    cells.mark_occupied(cell)

func spawn_snake():
    var cell = Vector2(8, 5)    
    spawn_player(cell)

    for direction in [Vector2.LEFT, Vector2.LEFT, Vector2.DOWN, Vector2.DOWN, Vector2.DOWN]:
        cell += direction
        spawn_tail_segment(cell) 
        
    # finally, pick starting direction
    next_direction = [Vector2.DOWN, Vector2.LEFT, Vector2.UP].pick_random()

func start() -> void:
    cells.initialize()
    spawn_snake()
    spawn_walls()
    spawn_apple()    
    show()

func mark_grid_cell_occupied(cell: Vector2) -> void:
    cells.mark_occupied(cell)

func mark_grid_cell_unoccupied(cell: Vector2) -> void:
    cells.mark_free(cell)
    
func get_random_unoccupied_grid_cell() -> Vector2:
    return cells.get_random_free_cell()

func tick() -> void:
    player_target_cell = player_cell + next_direction
    print(player_target_cell)
    $Player.move(player_target_cell * cell_size)
    cells.mark_occupied(player_target_cell)


func _on_player_finished_moving() -> void:
     player_cell = player_target_cell

func _on_move_timer_timeout() -> void:
    pass # Replace with function body.

func _on_player_wall_hit() -> void:
    # timer stop
    hide()
    game_over.emit()


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
