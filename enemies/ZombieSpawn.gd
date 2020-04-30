extends Node2D

var zombie_scene = preload("res://enemies/Zombie.tscn")

var level = 1
const max_level = 5
var health = 50

const start_health = 50


# Called when the node enters the scene tree for the first time.
func _ready():
	$SpawnTimer.connect("timeout", self, "_spawn_enemies")
	$EvolveTimer.connect("timeout", self, "_increase_level")
	
func _process(delta):
	if level < 5:
		$zombie_spawn.frame = level-1
	
func _spawn_enemies():
	for i in range(0, _get_zombies_per_spawn()):
		var z = zombie_scene.instance()
		z.global_position = $SpawnPosition.global_position
		var random_offset = (randi() % 20) + 5
		z.global_position += Vector2(random_offset, random_offset)
		get_node("/root/Game/GameWorld/Enemies").add_child(z)
	
func _increase_level():
	level += 1
	if level > max_level:
		level = max_level
	health = start_health * level
		
func _get_zombies_per_spawn() -> int:
	match level:
		1:
			return 1
		2:
			return 2
		3: 
			return 4
		4:
			return 5
		5:
			return 7
		
	return int(ceil((level * level) / 2.0))

func take_damage(dmg):
	health -= dmg
	if health <= 0:
		_die()
		
func _die():
	queue_free()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
