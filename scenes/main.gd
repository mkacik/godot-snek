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
    tail_segments.push_front(tail_segment)
    add_child(tail_segment)

func new_game():
    $Level.start()
    
    # start takes grid position, which will be then multiplied by cell size
    var grid_position: Vector2 = Vector2(8, 5)    
    $Player.start(grid_position)

    grid_position = grid_position + Vector2.LEFT
    add_tail_segment(grid_position)    
    grid_position = grid_position + Vector2.LEFT
    add_tail_segment(grid_position)
    grid_position = grid_position + Vector2.DOWN
    add_tail_segment(grid_position)

    $TailEnd.position = (grid_position + Vector2.DOWN) * cell_size
    
    $MoveTimer.start()
    
func game_over():
    $MoveTimer.stop()
    $HUD.show_game_over_message()

func _on_move_timer_timeout() -> void:
    $Player.move()
