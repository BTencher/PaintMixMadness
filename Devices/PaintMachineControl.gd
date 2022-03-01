extends PopupDialog


onready var redLabel : Label = $VBoxContainer/HBoxContainer/RedLabel
onready var redSlider : HSplitContainer = $VBoxContainer/HBoxContainer/RedSlider

onready var blueLabel : Label = $VBoxContainer/HBoxContainer2/BlueLabel
onready var blueSlider : HSplitContainer = $VBoxContainer/HBoxContainer2/BlueSlider

onready var greenLabel : Label = $VBoxContainer/HBoxContainer3/GreenLabel
onready var greenSlider : HSplitContainer = $VBoxContainer/HBoxContainer3/GreenSlider

onready var paintPreview : ColorRect = $VBoxContainer/PaintPreview

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func updatePaintPreview()->void:
	paintPreview.color = Color(redSlider.value,blueSlider.value,greenSlider.value, 1)

func _on_RedSlider_value_changed(value):
	var percentage : int = round(value/redSlider.max_value)*100
	redLabel.text = str(percentage) + "%"
	updatePaintPreview()
	
func _on_BlueSlider_value_changed(value):
	var percentage : int = round(value/blueSlider.max_value)*100
	blueLabel.text = str(percentage) + "%"
	updatePaintPreview()
	
func _on_GreenSlider_value_changed(value):
	var percentage : int = round(value/greenSlider.max_value)*100
	greenLabel.text = str(percentage) + "%"
	updatePaintPreview()
