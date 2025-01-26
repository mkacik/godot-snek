extends CanvasLayer

signal start_game

func _ready() -> void:
    pass

func _process(_delta: float) -> void:
    pass

func show_game_over_message(final_score: int) -> void:
    $ScoreBar.hide()
    $GameOverMessage/FinalScore.text = "score: " + str(final_score)
    $GameOverMessage.show()
    await get_tree().create_timer(2.0).timeout
    $StartButton.text = "RESTART"
    $StartButton.show()

func show_paused_message() -> void:
    $PausedMessage.show()

func hide_paused_message() -> void:
    $PausedMessage.hide()

func update_score(new_score: int) -> void:
    $ScoreBar/Score.text = str(new_score)

func _on_start_button_pressed() -> void:
    $GameOverMessage.hide()
    $StartButton.hide()
    $ScoreBar.show()
    start_game.emit()
