extends Control


const start_game = preload("res://World/world.tscn")

# Start game
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(start_game)
