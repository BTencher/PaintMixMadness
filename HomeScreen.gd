extends Node2D

onready var animationPlayer : AnimationPlayer = $FakeWorker/AnimationPlayer
onready var animationTree : AnimationTree = $FakeWorker/AnimationTree
onready var animationState = animationTree.get("parameters/playback")


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = false
	animationState.travel("Walking")



func _on_GUIDE_pressed():
	get_tree().change_scene("res://GUIDE.tscn")


func _on_CREDITS_pressed():
	get_tree().change_scene("res://Credits.tscn")


func _on_PLAY_pressed():
	get_tree().change_scene("res://World.tscn")
