extends CanvasLayer

signal start_game

func _ready() -> void:
    $GameOverMessage.hide()
    $StartButton.show()

func _process(_delta: float) -> void:
    pass

func show_game_over_message():
    $GameOverMessage.show()
    await get_tree().create_timer(3.0).timeout
    $GameOverMessage.hide()
    $StartButton.show()

func _on_start_button_pressed() -> void:
    $StartButton.hide()
    start_game.emit()
