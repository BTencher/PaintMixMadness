extends Node2D


onready var bucketCubby : StaticBody2D = $YSort/BucketCubby
onready var worker : KinematicBody2D = $YSort/Worker

func _ready():
	bucketCubby.connect("checkBodyCanGrabPaint", self, "_check_if_can_grab_paint")


func _check_if_can_grab_paint(body):
	print(body)
