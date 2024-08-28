extends CharacterBody2D

func _process(_delta):
	self.get_child(0).play("idle")
