extends Node


# Called when the node enters the scene tree for the first time.
func _process(delta:float):
#	print(name, " process")
	set_process(false)

func _notification(what):
	match  what:
		NOTIFICATION_PROCESS:
			print(name, " notif process")
