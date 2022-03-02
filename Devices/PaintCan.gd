extends Node2D


# Declare member variables here. Examples:
var redValue : int = 255 setget updateRed
var blueValue : int = 255 setget updateBlue
var greenValue : int = 255 setget updateGreen
var hasLid : bool = false setget closeLid
var isFilled : bool = false

onready var paintCanInside : Sprite = $PaintCanInside
onready var paintCanBodyClose: Sprite = $PaintCanBodyClose
onready var paintCanCloseLabel : Sprite = $PaintCanCloseLabel

func _ready():
	pass

func updateRed(new_value : int) -> void:
	redValue = new_value
	update_paint_colors()

func updateBlue(new_value : int) -> void:
	blueValue = new_value
	update_paint_colors()

func updateGreen(new_value : int) -> void:
	greenValue = new_value
	update_paint_colors()

func update_paint_colors() -> void:
	paintCanInside.modulate = Color( redValue, blueValue, greenValue, 1)
	paintCanCloseLabel.modulate = Color( redValue, blueValue, greenValue, 1)

func closeLid(new_value : bool) -> void:
	hasLid = new_value
	paintCanBodyClose.visible = hasLid
	paintCanCloseLabel.visible = hasLid
