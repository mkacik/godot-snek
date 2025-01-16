extends Node

func _ready() -> void:
    pass

func _process(_delta: float) -> void:
    pass

func new_game():
    $Level.start()

func game_over():
    $Level.stop()
    $HUD.show_game_over_message()
