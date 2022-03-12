extends Control


var page_count : int = 1 setget update_page

onready var screen1 : TextureRect = $Screen1
onready var screen2 : TextureRect = $Screen2
onready var screen3 : TextureRect = $Screen3
onready var screen4 : TextureRect = $Screen4
onready var screen5 : TextureRect = $Screen5
onready var screen6 : TextureRect = $Screen6
onready var screen7 : TextureRect = $Screen7
onready var previous : Button = $HBoxContainer/PREVIOUS
onready var next : Button = $HBoxContainer/NEXT
onready var complete : Button = $HBoxContainer/COMPLETE

func _ready():
	previous.disabled = true
	complete.disabled = true
	screen1.visible=true
	screen2.visible=false
	screen3.visible=false
	screen4.visible=false
	screen5.visible=false
	screen6.visible=false
	screen7.visible=false


func update_page(value):
	page_count = value
	match page_count:
		1:
			screen1.visible=true
			screen2.visible=false
			screen3.visible=false
			screen4.visible=false
			screen5.visible=false
			screen6.visible=false
			screen7.visible=false
			previous.disabled = true
			next.disabled = false
		2:
			screen1.visible=false
			screen2.visible=true
			screen3.visible=false
			screen4.visible=false
			screen5.visible=false
			screen6.visible=false
			screen7.visible=false
			previous.disabled = false
			next.disabled = false
		3:
			screen1.visible=false
			screen2.visible=false
			screen3.visible=true
			screen4.visible=false
			screen5.visible=false
			screen6.visible=false
			screen7.visible=false
		4:
			screen1.visible=false
			screen2.visible=false
			screen3.visible=false
			screen4.visible=true
			screen5.visible=false
			screen6.visible=false
			screen7.visible=false
		5:
			screen1.visible=false
			screen2.visible=false
			screen3.visible=false
			screen4.visible=false
			screen5.visible=true
			screen6.visible=false
			screen7.visible=false
		6:
			screen1.visible=false
			screen2.visible=false
			screen3.visible=false
			screen4.visible=false
			screen5.visible=false
			screen6.visible=true
			screen7.visible=false
			next.disabled = false
		7:
			screen1.visible=false
			screen2.visible=false
			screen3.visible=false
			screen4.visible=false
			screen5.visible=false
			screen6.visible=false
			screen7.visible=true
			complete.disabled = false
			next.disabled = true
			


func _on_NEXT_pressed():
	self.page_count = self.page_count+1

func _on_PREVIOUS_pressed():
	self.page_count = self.page_count-1


func _on_COMPLETE_pressed():
		get_tree().change_scene("res://HomeScreen.tscn")
