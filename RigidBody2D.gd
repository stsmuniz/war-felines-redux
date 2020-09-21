extends KinematicBody2D

enum States {
	IDLE,
	ATTACK,
	HURT,
	DIE
}

enum Team {
	BLUE,
	RED
}

export(int) var max_health = 5
export(int) var attackPower = 1
export(int) var velocity = 15
export(int) var defense = 0
export(float, 0.5, 5.0, 0.5) var attack_cooldown = 1.0
export(float, 0, 10, 0.1) var attack_speed = 0
export(Team) var enemy_team = Team.BLUE
export(AtlasTexture) var enemy_sprite: AtlasTexture
export(bool) var knockbackable = true
export(bool) var can_attack = true
export(int) var price = 300

var health setget set_health
var state
var direction
var readyToAttack = true
var knockback = 50

onready var hitbox = $Hitbox
onready var hurtbox = $Hurtbox
onready var sprite: Sprite  = $Sprite
onready var animationPlayer = $AnimationPlayer
onready var enemyDetectionArea = $EnemyDetectionArea
onready var attackCooldownTimer = $AttackCooldown


func _ready():
	health = max_health
	state = States.IDLE
	attackCooldownTimer.wait_time = attack_cooldown
	if enemy_sprite != null:
		sprite.region_enabled = true
		sprite.texture = enemy_sprite.atlas
		sprite.region_rect = enemy_sprite.region
	
	if enemy_team == Team.BLUE:
		direction = Vector2.LEFT
		sprite.self_modulate = Color(0.2, 0.2, 1.0, 1.0)
		sprite.flip_h = true
		hitbox.set_collision_layer(4)
		hitbox.set_collision_mask(32)
		hurtbox.set_collision_layer(16)
		hurtbox.set_collision_mask(8)
		enemyDetectionArea.set_collision_layer(1)
		enemyDetectionArea.set_collision_mask(32)
		hitbox.position.x = -hitbox.position.x
	elif enemy_team == Team.RED:
		direction = Vector2.RIGHT
		sprite.self_modulate = Color(0.64, 0.12, 0.64, 1.0)
		sprite.flip_h = false
		hitbox.set_collision_layer(8)
		hitbox.set_collision_mask(16)
		hurtbox.set_collision_layer(32)
		hurtbox.set_collision_mask(4)
		enemyDetectionArea.set_collision_layer(2)
		enemyDetectionArea.set_collision_mask(16)
		hitbox.position.x = hitbox.position.x

func _process(delta):
	match state:
		States.IDLE:
			walk(delta)
		States.ATTACK:
			if can_attack:
				attack()
		States.HURT:
			hurt(delta)
		States.DIE:
			die()

func walk(delta):
	animationPlayer.play("idle")
	move_and_collide((velocity * delta) * direction)

func attack():
	animationPlayer.play("attack")
	yield(animationPlayer, "animation_finished")
	if attackCooldownTimer.is_stopped():
		attackCooldownTimer.start()

func hurt(delta):
	if knockbackable:
		move_and_collide((knockback * delta) * -direction)
	animationPlayer.play("hurt")
	yield(animationPlayer, "animation_finished")
	state = States.IDLE

func die():
	animationPlayer.play("die")
	yield(animationPlayer, "animation_finished")
	queue_free()
	
func set_health(value):
	health = value
	if health <= 0:
		state = States.DIE

func _on_AttackCooldown_timeout():
	readyToAttack = true
	if state != States.DIE:
		state = States.IDLE

func _on_EnemyDetectionArea_area_entered(area):
	if state == States.IDLE:
		state = States.ATTACK

func _on_Hurtbox_area_entered(area):
	if state != States.DIE and state != States.HURT:
		state = States.HURT
		self.health = self.health - area.get_parent().attackPower
