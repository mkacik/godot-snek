extends CanvasLayer

signal start_game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    $GameOverMessage.hide()
    $StartButton.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass

func show_game_over_message():
    $GameOverMessage.show()
    await get_tree().create_timer(5.0).timeout
    $GameOverMessage.hide()
    $StartButton.show()

func _on_start_button_pressed() -> void:
    $StartButton.hide()
    start_game.emit()
