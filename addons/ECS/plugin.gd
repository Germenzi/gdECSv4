@tool
extends EditorPlugin

# const ECS_SIGNLETON_PATH = "res://addons/ecs/src/ECS.gd"
# const ECS_SINGLETON_NAME = "ECS"

func _enter_tree():
	pass
	# add_autoload_singleton(ECS_SINGLETON_NAME, ECS_SIGNLETON_PATH)


func _exit_tree():
	pass
	# remove_autoload_singleton(ECS_SINGLETON_NAME)


func get_plugin_icon():
	pass
	# return preload("res://addons/ecs/ecs-icon.png")
