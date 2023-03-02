extends Object

class_name Entity

signal enter_ecs
signal exit_ecs


var components : Dictionary = {} # component type : component instance
var _binded_scene : Node
var inside_ecs:bool = false # only for use from ECS singleton!


static func is_dirty(entity):
	return entity == null or \
			not is_instance_valid(entity)


func _init(components:Array=[], autoregister:bool=true):
	if autoregister:
		ECS.register_entity(self)
	
	for i in components:
		add_component(i)


func add_component(comp_instance:Object, readonly:bool=false, overwrite:bool=false):
	if not ECS.is_instance_component(comp_instance):
		push_warning("Trying to add non-component instance as a component to the entity")
		return
	
	var existing : Object = get_component(comp_instance.COMPONENT_TYPE)
	
	if overwrite or existing == null:
		if existing != null and ECS.is_component_readonly(existing):
			push_warning("Cannot overwrite readonly component <{0}> in entity {1}".format([comp_instance.COMPONENT_TYPE, self]))
			return
		
		components[comp_instance.COMPONENT_TYPE] = comp_instance
		
		if readonly:
			ECS.set_component_readonly(comp_instance)
		
		ECS.revise_entity(self)


func has_component(comp_type:String):
	return components.has(comp_type)


func remove_component(comp_type:String):
	if not has_component(comp_type):
		push_warning("Entity <{0}> has no <{1}> component to remove".format([self, comp_type]))
		return
	
	if ECS.is_component_readonly(components[comp_type]):
		push_warning("Cannot remove readonly component <{0}> from entity {1}".format([comp_type, self]))
		return
	
	components.erase(comp_type)
	
	ECS.revise_entity(self)


func get_component(comp_type:String):
	if not has_component(comp_type):
		return null
	
	return components[comp_type]


func get_components_names():
	return components.keys()


func get_components_instances():
	return components.values()


func bind_node(node:Node):
	_binded_scene = node



func _free_binded_scene():
	if _binded_scene != null and is_instance_valid(_binded_scene):
		_binded_scene.queue_free()


func _notification(what):
	match what:
		NOTIFICATION_PREDELETE:
			ECS.unregister_entity(self)
			_free_binded_scene()
