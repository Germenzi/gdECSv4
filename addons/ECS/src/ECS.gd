extends Node

const COMPONENT_TYPE_PROPERTY = "COMPONENT_TYPE"
const COMPONENT_READONLY_META_NAME = "READONLY_COMPONENT"

var entities : Array[Entity] = []
var filters : Array[EntityFilter] = []
var registered_systems : Array[System] = []
var _ptr : int

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
			


func register_system(system:System):
	if system.registered:
		return
	
	registered_systems.append(system)
	system.registered = true


func set_descrete_mode(flag:bool):
	for i in registered_systems:
		i.in_descrete_mode = flag
	
	_ptr = 0


func push_update(): # only for using in descrete mode
	if registered_systems.size() == 0:
		return
	
	registered_systems[_ptr].push_process_entity()
	_ptr = (_ptr + 1)%registered_systems.size()



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
