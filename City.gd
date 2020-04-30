extends Node2D

var civilian_scene = preload("res://allies/Civilian.tscn")

export var city_name = "The East City"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func spawn_civilians(num):
	for i in range(0, num):
		var civ = civilian_scene.instance()
		civ.global_position = $SpawnPosition.global_position + Vector2(i,i)
		get_node("/root/Game/GameWorld/Civilians").add_child(civ)
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
