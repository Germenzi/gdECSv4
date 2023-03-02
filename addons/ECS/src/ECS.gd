extends Node

const COMPONENT_TYPE_PROPERTY = "COMPONENT_TYPE"
const COMPONENT_READONLY_META_NAME = "READONLY_COMPONENT"

signal entered_descrete_mode
signal exited_descrete_mode


var entities : Array[Entity] = []
var filters : Array[EntityFilter] = []
var in_descrete_mode : bool = false

var _systems_queue : Array[System] = []


func _enter_tree():
	get_tree().node_added.connect(_on_node_added)

func register_filter(filter:EntityFilter):
	if filter.registered:
		return
	
	filters.append(filter)
	
	for ent in entities:
		if EntitySignature.match_entity(filter.entity_signature, ent):
			filter.add_entity(ent)
	
	filter.registered = true
	filter.was_registered.emit()


func unregister_filter(filter:EntityFilter):
	if not filter.registered:
		return
	
	filter.pre_unregister.emit()
	
	filters.erase(filter)
	filter.valid_entities = []
	filter.registered = false


func register_entity(entity:Entity):
	if entity.inside_ecs:
		return
	
	entities.append(entity)
	
	entity.enter_ecs.emit()
	entity.inside_ecs = true
	
	revise_entity(entity)


func unregister_entity(entity:Entity):
	if not entity.inside_ecs:
		return
	
	entities.erase(entity)
	
	for filter in filters:
		if entity in filter.valid_entities:
			filter.remove_entity(entity)
	
	entity.exit_ecs.emit()
	entity.inside_ecs = false


func clear_entities():
	for ent in entities.duplicate():
		ent.free()


func revise_entity(entity:Entity):
	if not entity.inside_ecs:
		return
	
	for filter in filters:
		if EntitySignature.match_entity(filter.entity_signature, entity):
			if not entity in filter.valid_entities:
				filter.add_entity(entity)
		
		elif entity in filter.valid_entities:
				filter.remove_entity(entity)


func push_update():
	if _systems_queue.is_empty():
		push_warning("...")
		return
	
	var system : System = _systems_queue.pop_front()
	
	system.push_process()
	
	_systems_queue.append(system)


func enter_descrete_mode():
	if in_descrete_mode:
		push_warning("......")
		return
	
	_fill_system_queue(get_tree().root)
	
	for s in _systems_queue:
		s.enter_descrete_mode()
	
	in_descrete_mode = true
	
	entered_descrete_mode.emit()


func exit_descrete_mode():
	if not in_descrete_mode:
		push_warning("dkirr")
		return
	
	for s in _systems_queue:
		s.exit_descrete_mode()
	
	_systems_queue = []
	in_descrete_mode = false
	exited_descrete_mode.emit()


func is_instance_component(instance:Object):
	return COMPONENT_TYPE_PROPERTY in instance


func is_component_readonly(instance:Object):
	if not is_instance_component(instance):
		return false
	
	return instance.has_meta(COMPONENT_READONLY_META_NAME)


func set_component_readonly(instance:Object):
	if not is_instance_component(instance):
		return false
	
	instance.set_meta(COMPONENT_READONLY_META_NAME, 0)


func _fill_system_queue(node:Node):
	if node is System:
		_systems_queue.append(node)
	
	for i in node.get_children():
		_fill_system_queue(i)


func _on_node_added(node:Node):
	if node is System and in_descrete_mode:
		push_warning("eljgle")
