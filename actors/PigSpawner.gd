extends Position2D

signal pig_cooldown
signal pig_spawnable

onready var pig = load("res://actors/Enemy.tscn")
onready var spawnCooldown = $SpawnCooldown
export(float, 0.5, 5.0, 0.5) var spawn_cooldown_time = 1.0

var spawnable: bool

func _ready():
	spawnable = true
	spawnCooldown.wait_time = spawn_cooldown_time

func pig_price():
	var pig_instance = pig.instance()
	return pig_instance.price

func spawn_enemy(team):
	if spawnable:
		var pig_instance = pig.instance()
		pig_instance.enemy_team = team
		add_child(pig_instance)
		pig_instance.position = position
		spawnable = false
		spawnCooldown.start()
		return true
		emit_signal("pig_cooldown")
	return false


func _on_SpawnCooldown_timeout():
	spawnable = true
	emit_signal('pig_spawnable')
