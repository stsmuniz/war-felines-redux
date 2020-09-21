extends KinematicBody2D

signal money_changed(value)
signal health_ready(value)
signal health_changed(value)

enum States {
	IDLE,
	HURT,
	DIE
}

enum Team {
	BLUE,
	RED
}

export(int) var max_health = 20
export(int) var defense = 0
export(Team) var enemy_team = Team.BLUE
export(int) var incomePerSecond = 50

var health setget set_health
var state
var direction
var readyToAttack = true
var knockback = 100
var money setget set_money

onready var hurtbox = $Hurtbox
onready var animationPlayer = $AnimationPlayer
onready var pigSpawner = $PigSpawner
onready var sprite = $Sprite 
onready var enemySpawnTimer = $EnemySpawnTimer

func _unhandled_key_input(event):
	if event.is_action_pressed("spawn_enemy_1") and enemy_team == Team.BLUE:
		spawn_pig()

func _ready():
	health = max_health
	state = States.IDLE
	self.money = 0
	emit_signal("health_ready", max_health)
	if enemy_team == Team.BLUE:
		sprite.self_modulate = Color(0.2, 0.2, 1.0, 1.0)
		direction = Vector2.LEFT
		hurtbox.set_collision_layer(16)
		hurtbox.set_collision_mask(8)
		pigSpawner.position.x = pigSpawner.position.x
	elif enemy_team == Team.RED:
		sprite.self_modulate = Color(1.0, 0.2, 0.2, 1.0)
		direction = Vector2.RIGHT
		hurtbox.set_collision_layer(32)
		hurtbox.set_collision_mask(4)
		pigSpawner.position.x = -pigSpawner.position.x
		enemySpawnTimer.start()

func _process(delta):
	match state:
		States.IDLE:
			walk(delta)
		States.HURT:
			hurt(delta)
		States.DIE:
			die()

func walk(delta):
	animationPlayer.play("idle")

func spawn_pig():
	if money >= pigSpawner.pig_price() and pigSpawner.spawn_enemy(Team.BLUE):
			self.money -= pigSpawner.pig_price()

func attack():
	animationPlayer.play("attack")
	yield(animationPlayer, "animation_finished")

func hurt(delta):
	animationPlayer.play("hurt")
	yield(animationPlayer, "animation_finished")
	state = States.IDLE

func die():
	animationPlayer.play("die")
	yield(animationPlayer, "animation_finished")
	queue_free()
	
func set_health(value):
	health = value
	emit_signal("health_changed", value)
	if health <= 0:
		state = States.DIE

func set_money(value):
	money = value
	emit_signal("money_changed", value)

func _on_Hurtbox_area_entered(area):
	if state != States.DIE and state != States.HURT:
		state = States.HURT
		self.health = self.health - area.get_parent().attackPower

func _on_MoneyTimer_timeout():
	self.money = self.money + incomePerSecond


func _on_EnemySpawnTimer_timeout():
	if enemy_team == Team.RED:
		pigSpawner.spawn_enemy(Team.RED)
		enemySpawnTimer.wait_time = randi()%8+3


func _on_UI_spawn_enemy(enemy_name):
	spawn_pig()
