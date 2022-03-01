extends Node2D


onready var bucketCubby : StaticBody2D = $YSort/BucketCubby
onready var worker : KinematicBody2D = $YSort/Worker

func _ready():
	connect_paint_cubbies()
	connect_workers()

func connect_paint_cubbies() -> void:
	var cubbieCount : int = 0
	var paintCubbyNodes : Array
	paintCubbyNodes = get_tree().get_nodes_in_group("PaintCubby")
	while cubbieCount < paintCubbyNodes.size():
		var cubbyNode : StaticBody2D = paintCubbyNodes[cubbieCount]
		print("Connect!")
		cubbyNode.connect("playerNearPaintCubby", self, "_mark_player_near_cubby")
		cubbieCount += 1

func connect_workers() -> void:
	var workerCount : int = 0
	var workerNodes : Array
	workerNodes = get_tree().get_nodes_in_group("Worker")
	while workerCount < workerNodes.size():
		var workerNode : KinematicBody2D = workerNodes[workerCount]
		workerNode.connect("canInteractCubby", self, "_mark_cubby_near_player")
		workerCount += 1

func _mark_player_near_cubby(player_node,cubby_node):
	player_node.markCubbyNearby(cubby_node)

func _mark_cubby_interactable(player_node,cubby_node):
	pass
