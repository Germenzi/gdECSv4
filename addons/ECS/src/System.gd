extends Node

class_name System

@export
var active : bool = true


var registered : bool = false
var entity_filter : EntityFilter
var in_discrete_mode : bool = false


func push_process():
	if in_discrete_mode:
		set_process(true)


func enter_discrete_mode():
	set_process(false)
	in_discrete_mode = true


func exit_discrete_mode():
	set_process(true)
	in_discrete_mode = false


func _enter_tree():
	entity_filter = EntityFilter.new(
		EntitySignature.create_signature(
			get_necessary_components(),
			get_banned_components()
		)
	)
	
	ECS.register_filter(entity_filter)


func _exit_tree():
	ECS.unregister_filter(entity_filter)


func _process(delta:float):
	_process_entities(delta)
	
	if in_discrete_mode:
		set_process(false)


func _process_entities(delta:float):
	if not active:
		return
	
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
