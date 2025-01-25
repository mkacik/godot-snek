extends CanvasLayer

signal start_game

func _ready() -> void:
    pass

func _process(_delta: float) -> void:
    pass

func show_game_over_message():
    $GameOverMessage.show()
    await get_tree().create_timer(2.0).timeout
    $StartButton.show()

func show_paused_message():
    $PausedMessage.show()

func hide_paused_message():
    $PausedMessage.hide()

func _on_start_button_pressed() -> void:
    $GameOverMessage.hide()
    $StartButton.hide()
    start_game.emit()
