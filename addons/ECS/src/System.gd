extends Node

class_name System

@export
var active : bool = true:
	set(v):
		set_process(v)
	get:
		return can_process()


var entity_filter : EntityFilter
var in_discrete_mode : bool = false

var _allow_push : bool = false


func _enter_tree():
	entity_filter = EntityFilter.new(
		EntitySignature.create_signature(
			get_necessary_components(),
			get_banned_components()
		)
	)
	
	set_process(active)
	
	ECS.register_filter(entity_filter)


func _exit_tree():
	ECS.unregister_filter(entity_filter)


func _process(delta:float):
	if in_discrete_mode and not _allow_push:
		return
	
	_process_entities(delta)
	
	if in_discrete_mode:
		_allow_push = false


func push_process():
	if in_discrete_mode:
		_allow_push = true


func _process_entities(delta:float):
	for i in entity_filter.valid_entities:
		on_entity_process(i, delta)


# virtual
func on_entity_process(entity:Entity, delta:float):
	pass

# virtual
func get_necessary_components() -> Array:
	return []

# virtual
func get_banned_components() -> Array:
	return []
