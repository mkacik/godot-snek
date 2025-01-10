extends Node

@export var cell_size: int = 16
@export var tail_scene: PackedScene

var tail_segments: Array = [];

func _ready() -> void:
    pass

func _process(_delta: float) -> void:
    pass

func add_tail_segment(grid_position):
    var tail_segment = tail_scene.instantiate()
    tail_segment.position = grid_position * cell_size
    tail_segments.push_back(tail_segment)
    # add_child(tail_segment)
    $Background.add_sibling(tail_segment)

func new_game():
    $Level.start()
    
    # start takes grid position, which will be then multiplied by cell size
    var grid_position: Vector2 = Vector2(8, 5)    
    $Player.start(grid_position * cell_size)

    for direction in [Vector2.LEFT, Vector2.LEFT, Vector2.DOWN, Vector2.DOWN, Vector2.DOWN]:
        grid_position = grid_position + direction
        add_tail_segment(grid_position)    

    $TailEnd.start(grid_position * cell_size)
    
    $MoveTimer.start()
    
func game_over():
    $MoveTimer.stop()

    $Player.hide()
    $TailEnd.hide()
    tail_segments.clear()
    get_tree().call_group("tail", "queue_free")
    
    $HUD.show_game_over_message()

func tick() -> void:
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

    $Player.move()
    $TailEnd.move(new_tail_end_target_position)

func _on_move_timer_timeout() -> void:
    tick()
