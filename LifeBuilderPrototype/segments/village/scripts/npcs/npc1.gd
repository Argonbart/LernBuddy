extends CharacterBody2D

@onready var npc_sprite = $NPC1Sprite

var point1 = Vector2(550, 60)
var point2 = Vector2(-130, 60)

var target = point2
var direction = Vector2.ZERO

func _ready():
	npc_sprite.play("walk_left")

func _physics_process(delta):
	direction = target-position
	if direction.length() < 5:
		if target == point1:
			target = point2
		else:
			target = point1
		npc_sprite.flip_h = !npc_sprite.flip_h
	direction = direction.normalized()
	velocity = direction * 5000 * delta
	move_and_slide()
