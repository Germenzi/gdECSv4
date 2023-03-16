@tool
extends EditorPlugin

const ECS_SIGNLETON_PATH = "res://addons/ECS/src/ECS.gd"
const ECS_SINGLETON_NAME = "ECS"

const PANEL_SINGLETON_PATH = "res://addons/ECS/DiscreteModeMonitor/DiscreteMonitor.tscn"
const PANEL_SINGLETON_NAME = "DiscreteMonitor"

func _enter_tree():
	add_autoload_singleton(ECS_SINGLETON_NAME, ECS_SIGNLETON_PATH)
	add_autoload_singleton(PANEL_SINGLETON_NAME, PANEL_SINGLETON_PATH)


func _exit_tree():
	remove_autoload_singleton(ECS_SINGLETON_NAME)
	remove_autoload_singleton(PANEL_SINGLETON_NAME)


func get_plugin_icon():
	return preload("res://addons/ECS/ecs-icon.png")
