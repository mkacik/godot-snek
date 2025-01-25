extends Node

func _ready() -> void:
    pass

func _process(_delta: float) -> void:
    pass

func _on_hud_start_game() -> void:
    $Level.start()

func _on_level_game_over() -> void:
    $Level.stop()
    $HUD.show_game_over_message()

func _on_level_game_paused() -> void:
    $HUD.show_paused_message()

func _on_level_game_unpaused() -> void:
    $HUD.hide_paused_message()
