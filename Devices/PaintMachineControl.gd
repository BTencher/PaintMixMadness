extends PopupDialog


#onready var redLabel : Label = $VBoxContainer/HBoxContainer/RedLabel
onready var redSlider : HSlider = $VBoxContainer/HBoxContainer/RedSlider

#onready var blueLabel : Label = $VBoxContainer/HBoxContainer2/BlueLabel
onready var blueSlider : HSlider = $VBoxContainer/HBoxContainer2/BlueSlider

#onready var greenLabel : Label = $VBoxContainer/HBoxContainer3/GreenLabel
onready var greenSlider : HSlider = $VBoxContainer/HBoxContainer3/GreenSlider

onready var paintPreview : ColorRect = $VBoxContainer/HBoxContainer4/PaintPreview

var workerNode : KinematicBody2D
var machineNode : Node2D
var paintState : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func updatePaintPreview()->void:
	paintPreview.color = Color(redSlider.value/255.0,greenSlider.value/255.0,blueSlider.value/255.0, 1)

func _on_RedSlider_value_changed(_value):
#	var percentage : int = round(value*100/redSlider.max_value)
#	redLabel.text = str(percentage) + "%"
	updatePaintPreview()
	
func _on_BlueSlider_value_changed(_value):
#	var percentage : int = round(value*100/blueSlider.max_value)
#	blueLabel.text = str(percentage) + "%"
	updatePaintPreview()
	
func _on_GreenSlider_value_changed(_value):
#	var percentage : int = round(value*100/greenSlider.max_value)
#	greenLabel.text = str(percentage) + "%"
	updatePaintPreview()


func _on_ColorizeButton_button_down():
	#call machine to start spewing paint
	machineNode.run_paint_machine(paintPreview.color)
	#set worker state back to empty hands
	workerNode.release_worker_from_machine()
	queue_free()

func _on_Control_popup_hide():
	workerNode._state = workerNode.States.EMPTY_HANDS
	workerNode.currentBucketNode = null
	workerNode.currentMachineNode = null
	queue_free()
