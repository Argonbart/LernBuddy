extends CharacterBody2D

@onready var npc_sprite = $NPC2Sprite

var point1 = Vector2(90, 250)
var point2 = Vector2(90, 60)

var target = point2
var direction = Vector2.ZERO

func _ready():
	npc_sprite.play("walk_up")

func _physics_process(delta):
	direction = target-position
	if direction.length() < 5:
		if target == point1:
			target = point2
			npc_sprite.play("walk_up")
		else:
			target = point1
			npc_sprite.play("walk_down")
	direction = direction.normalized()
	velocity = direction * 5000 * delta
	move_and_slide()
