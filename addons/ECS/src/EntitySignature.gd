extends Object

class_name EntitySignature

const NECESSARY_STRING = "NECESSARY_COMPONENTS"
const BANNED_STRING = "BANNED_COMPONENTS"


static func match_entity(signature:Dictionary, entity:Entity):
	if Entity.is_dirty(entity):
		return false
	
	for ncc in signature.get(NECESSARY_STRING, []):
		if not entity.has_component(ncc):
			return false
	
	for bnc in signature.get(BANNED_STRING, []):
		if entity.has_component(bnc):
			return false
	
	return true


static func create_signature(necessary:Array, banned:Array=[]) -> Dictionary:
	return {
		NECESSARY_STRING : necessary.duplicate(),
		BANNED_STRING : banned.duplicate()
	}
