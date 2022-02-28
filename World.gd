extends Node


onready var gameWorld : ViewportContainer = $GameWorld 
onready var gameWorldViewPort : Viewport = $GameWorld/GameWorldPort 
onready var screenRes : Vector2 =  get_viewport().size

var scaling : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	scaling = screenRes / gameWorldViewPort.size
	gameWorld.rect_scale = scaling
	print(screenRes)
	print(gameWorldViewPort.size)
	print(scaling)
