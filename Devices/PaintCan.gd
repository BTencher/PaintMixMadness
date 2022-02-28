extends Node2D


# Declare member variables here. Examples:
var redValue : int = 255 setget updateRed
var blueValue : int = 255 setget updateBlue
var greenValue : int = 255 setget updateGreen
var hasLid : bool = false setget closeLid

onready var paintCanInside : Sprite = $PaintCanInside
onready var paintCanBodyClose: Sprite = $PaintCanBodyClose
onready var paintCanCloseLabel : Sprite = $PaintCanCloseLabel

func _ready():
	pass

func updateRed(new_value : int) -> void:
	redValue = new_value
	paintCanInside.modulate = Color( redValue, blueValue, greenValue, 1)
	paintCanCloseLabel.modulate = Color( redValue, blueValue, greenValue, 1)

func updateBlue(new_value : int) -> void:
	blueValue = new_value
	paintCanInside.modulate = Color( redValue, blueValue, greenValue, 1)
	paintCanCloseLabel.modulate = Color( redValue, blueValue, greenValue, 1)

func updateGreen(new_value : int) -> void:
	greenValue = new_value
	paintCanInside.modulate = Color( redValue, blueValue, greenValue, 1)
	paintCanCloseLabel.modulate = Color( redValue, blueValue, greenValue, 1)

func closeLid(new_value : bool) -> void:
	hasLid = new_value
	paintCanBodyClose.visible = hasLid
	paintCanCloseLabel.visible = hasLid
