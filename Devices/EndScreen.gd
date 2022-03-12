extends Popup


onready var score : RichTextLabel = $TextureRect/VBoxContainer/Score

func _ready():
	pass # Replace with function body.


func set_score(new_score : String) -> void:
	score.bbcode_text = "[center]" + new_score + "[/center]"


func _on_Button_pressed():
	get_tree().change_scene("res://HomeScreen.tscn")
