extends Node2D

const Common = preload("res://lib/common.gd")
const CELL_SIZE: int = Common.CELL_SIZE

signal game_over

@export var wall_scene: PackedScene
@export var tail_scene: PackedScene
@export var apple_scene: PackedScene

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
    $MoveTimer.wait_time = Common.MOVE_INTERVAL
    # print("Min interval: ", 1.0 * Common.CELL_SIZE / Common.MOVE_ANIMATION_SPEED)
    # print("Current move interval: ", $MoveTimer.wait_time)

    grid_size = get_viewport_rect().size / CELL_SIZE
    cells = Cells.new(grid_size)

func _process(_delta: float) -> void:
    if Input.is_action_pressed("move_right"):
        if $Player.can_move(Vector2.RIGHT):
            next_direction = Vector2.RIGHT
    elif Input.is_action_pressed("move_left"):
        if $Player.can_move(Vector2.LEFT):
            next_direction = Vector2.LEFT
    elif Input.is_action_pressed("move_down"):
        if $Player.can_move(Vector2.DOWN):
            next_direction = Vector2.DOWN
    elif Input.is_action_pressed("move_up"):
        if $Player.can_move(Vector2.UP):
            next_direction = Vector2.UP

func spawn_wall(cell: Vector2, new_name: String) -> void:
    var wall = wall_scene.instantiate()
    wall.name = new_name
    wall.position = cell * CELL_SIZE
    add_child(wall)
    cells.mark_occupied(cell)

func spawn_walls() -> void:
    for x in range(0, grid_size.x):
        spawn_wall(Vector2(x, 0), "WallNorth" + str(x))
        spawn_wall(Vector2(x, grid_size.y - 1), "WallSouth" + str(x))

    # skipping first and last rows because they were covered by loop above
    for y in range(1, grid_size.y - 1):
        spawn_wall(Vector2(0, y), "WallWest" + str(y))
        spawn_wall(Vector2(grid_size.x - 1, y), "WallEast" + str(y))

func spawn_apple() -> void:
    # no need to mark previous cell free: this function is only called on start
    # and when apple is eaten. In latter case, that means snake head is now
    # occupying the position
    var cell = cells.get_random_free_cell()
    $Apple.position = cell * CELL_SIZE
    cells.mark_occupied(cell)

func spawn_tail_segment(cell: Vector2) -> void:
    var tail_segment = tail_scene.instantiate()
    tail_segment.name = "TailSegment" + str(tail_segments.size())
    tail_segment.position = cell * CELL_SIZE
    tail_segments.push_back(tail_segment)

    # This will ensure that new tail segments will be rendered every frame
    # before the Apple, Player and dynamically added walls.
    call_deferred("add_child", tail_segment)
    cells.mark_occupied(cell)

func spawn_player(cell: Vector2) -> void:
    player_cell = cell
    player_target_cell = cell
    $Player.start(cell * CELL_SIZE)
    cells.mark_occupied(cell)

func spawn_tail_end(cell: Vector2) -> void:
    # Tail end is a fake segment that overlaps the last tail segment (when snake
    # is not moving, it overlaps 100%). It's purpose is to make animation smooth
    # at the end of tail. It's already occupied, so no need to mark it.
    tail_end_cell = cell
    tail_end_target_cell = cell
    $TailEnd.start(cell * CELL_SIZE)

func spawn_snake() -> void:
    var cell = Vector2(8, 5)
    spawn_player(cell)

    var tail_segment_relative_positions = [Vector2.LEFT, Vector2.LEFT, Vector2.DOWN, Vector2.DOWN, Vector2.DOWN]
    for direction in tail_segment_relative_positions:
        cell += direction
        spawn_tail_segment(cell)

    spawn_tail_end(cell)

    # Pick staring direction. Can go in one of 3 directions
    var valid_directions = [Vector2.LEFT, Vector2.DOWN, Vector2.RIGHT, Vector2.UP]
    valid_directions.erase(tail_segment_relative_positions[0])
    next_direction = valid_directions.pick_random()

func start() -> void:
    cells.initialize()
    spawn_snake()
    spawn_walls()
    spawn_apple()
    show()
    $MoveTimer.start()

func stop() -> void:
    hide()
    $MoveTimer.stop()
    $Player.stop()
    $TailEnd.stop()
    get_tree().call_group("walls", "queue_free")
    get_tree().call_group("tail", "queue_free")
    tail_segments.clear()

func tick() -> void:
    # 1. Move the player.
    player_target_cell = player_cell + next_direction
    $Player.move(player_target_cell * CELL_SIZE)
    cells.mark_occupied(player_target_cell)

    # 2A. Move the body: pick the last tail segment and pop it where player
    # is moving away from. Before the move collisions need to be disabled,
    # to not interfere with player.
    var last_segment = tail_segments.pop_back()
    last_segment.deferred_disable_collisions()
    last_segment.set_deferred("position", player_cell * CELL_SIZE)
    tail_segments.push_front(last_segment)

    # 2B. Reenable collisions for the now second segment ,that is no longer
    # touching the player.
    tail_segments[1].deferred_enable_collisions()

    # 3. Move the tail end towards the last tail segment until they are in the
    # same cell. Tail segments are not moving on their own, are only moved in
    # this function, so their positions will always be on "whole" cell.
    tail_end_target_cell = tail_segments[-1].position / CELL_SIZE
    $TailEnd.move(tail_end_target_cell * CELL_SIZE)

func _on_player_finished_moving() -> void:
    player_cell = player_target_cell

func _on_tail_end_finished_moving() -> void:
    tail_end_cell = tail_end_target_cell

    # only if player is not moving into there in the meantime
    # var player_target_grid_position = $Level/Player.target_position / cell_size
    # if previous_tail_position != player_target_grid_position:
    #    $Level.mark_grid_cell_unoccupied(previous_tail_position)

func _on_player_apple_eaten() -> void:
    spawn_tail_segment(tail_end_target_cell)
    spawn_apple()

func _on_player_wall_hit() -> void:
    game_over.emit()

func _on_move_timer_timeout() -> void:
    tick()

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
