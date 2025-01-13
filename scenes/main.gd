extends Node

@export var cell_size: int = 16
@export var tail_scene: PackedScene
var tail_segments: Array = [];
var previous_tail_position

func _ready() -> void:
    pass

func _process(_delta: float) -> void:
    pass

func _input(event):
    if event.is_action_pressed("ui_cancel"):
        get_tree().quit()

func add_tail_segment(grid_position):
    var tail_segment = tail_scene.instantiate()
    tail_segment.name = "TailBody" + str(tail_segments.size())
    tail_segment.position = grid_position * cell_size
    tail_segments.push_back(tail_segment)
    
    # I want the tail body to display under the tail end and player
    $Background.call_deferred("add_sibling", tail_segment)

func move_apple_to_random_free_position():
    var grid_position = $Level.get_random_unoccupied_grid_cell()
    $Apple.position = grid_position * cell_size

func new_game():
    $Level.start()

    var grid_position: Vector2 = Vector2(8, 5)    
    $Player.start(grid_position * cell_size)
    $Level.mark_grid_cell_occupied(grid_position)

    for direction in [Vector2.LEFT, Vector2.LEFT, Vector2.DOWN, Vector2.DOWN, Vector2.DOWN]:
        grid_position = grid_position + direction
        add_tail_segment(grid_position)    
        $Level.mark_grid_cell_occupied(grid_position)

    $TailEnd.start(grid_position * cell_size)
    previous_tail_position = grid_position
    
    move_apple_to_random_free_position()
    $Apple.show()
    
    $MoveTimer.start()
    
func game_over():
    $MoveTimer.stop()

    $Level.hide()
    $Player.hide()
    $Apple.hide()
    $TailEnd.hide()
    
    tail_segments.clear()
    get_tree().call_group("tail", "queue_free")

    $HUD.show_game_over_message()

func tick() -> void:
    # TODO: when tail leaves a cell completely it should be marked
    # as unoccupied
    
    var player_grid_position = $Player.position / cell_size

    # pick the last tail segment
    # disable it's collisions so it does not interfere with the player
    # put it in the same spot as player is, before player starts moving
    # as it's now right after the player, push it in front of the segments list
    # but only after collisions were disabled
    var segment_to_move = tail_segments.pop_back()
    var new_tail_end_target_position = tail_segments[-1].position
    
    tail_segments[0].deferred_enable_collisions()
    tail_segments.push_front(segment_to_move)
    segment_to_move.deferred_disable_collisions()
    segment_to_move.set_deferred("position", player_grid_position * cell_size)

    $Player.call_deferred("move")
    
    previous_tail_position = $TailEnd.position / cell_size
    $TailEnd.move(new_tail_end_target_position)

    # mark player's target position as occupied
    var new_player_target_grid_position = $Player.target_position / cell_size
    $Level.mark_grid_cell_occupied(new_player_target_grid_position)

func free_up_previous_tail_position() -> void:
    # only if player is not moving into there in the meantime
    var player_target_grid_position = $Player.target_position / cell_size
    if previous_tail_position != player_target_grid_position:
        $Level.mark_grid_cell_unoccupied(previous_tail_position)

func _on_move_timer_timeout() -> void:
    tick()

func apple_eaten() -> void:
    add_tail_segment(tail_segments[-1].position / cell_size)
    move_apple_to_random_free_position()
    
