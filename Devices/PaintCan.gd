extends Node2D


var paintEndColor : Color
var startColor : Color = Color.white
var temporary_color : Color = startColor

var hasLid : bool = false setget closeLid
var isFilled : bool = false

onready var paintCanInside : Sprite = $PaintCanInside
onready var paintCanBodyClose: Sprite = $PaintCanBodyClose
onready var paintCanCloseLabel : Sprite = $PaintCanCloseLabel

func _ready():
	update_paint_colors(temporary_color)

func set_end_paint_color(paintMachineColor : Color) -> void:
	paintEndColor = paintMachineColor

func update_current_color(int_percent_complete : int) -> void:
	if int_percent_complete < 100:
		temporary_color = Color(lerp(startColor,paintEndColor,float(int_percent_complete)/100.00))#(startColor/255).linear_interpolate(paintEndColor/255,float(int_percent_complete)/100.00)
		update_paint_colors(temporary_color)
		print(temporary_color)
	else:
		temporary_color = paintEndColor
		update_paint_colors(temporary_color)
		print(temporary_color)

func update_paint_colors(v_currentPaintColor : Color) -> void:
	paintCanInside.modulate = v_currentPaintColor
	paintCanCloseLabel.modulate = v_currentPaintColor

func closeLid(new_value : bool) -> void:
	hasLid = new_value
	paintCanBodyClose.visible = hasLid
	paintCanCloseLabel.visible = hasLid
