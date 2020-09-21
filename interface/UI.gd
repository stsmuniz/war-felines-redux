extends Control

signal spawn_enemy(enemy_name)

onready var moneyLabel = $Bottom/MoneyContainer/MoneyLabel
onready var blueHealthBar = $Top/BlueLifeBar/TextureProgress
onready var redHealthBar = $Top/RedLifeBar/TextureProgress
onready var pigButton = $Bottom/EnemyButton/TextureButton



func _on_BlueTower_money_changed(value):
	moneyLabel.text = str(value)

func _on_BlueTower_health_changed(value):
	blueHealthBar.value = value

func _on_RedTower_health_changed(value):
	redHealthBar.value = value

func _on_BlueTower_health_ready(value):
	blueHealthBar.max_value = value
	redHealthBar.value = value

func _on_RedTower_health_ready(value):
	redHealthBar.max_value = value
	redHealthBar.value = value

func _on_TextureButton_pressed():
	emit_signal("spawn_enemy", 'pig')
	pigButton.disabled = true
	

func _on_PigSpawner_pig_spawnable():
	pigButton.disabled = false


func _on_PigSpawner_pig_cooldown():
	print('teste')
	pigButton.disabled = true
