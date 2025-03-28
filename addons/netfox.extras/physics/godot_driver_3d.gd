extends PhysicsDriver

class_name PhysicsDriver3D

# Physics driver based on netfox ticks
# Requires a custom build of Godot with https://github.com/godotengine/godot/pull/76462

var scene_collision_objects: Array = []
var collision_objects_snapshots: Dictionary[int, Dictionary] = {}

func _init_physics_space() -> void:
	physics_space = get_viewport().world_3d.space
	PhysicsServer3D.space_set_active(physics_space, false)

	get_tree().node_added.connect(node_added)
	get_tree().node_removed.connect(node_removed)
	scan_tree()

func _physics_step(delta) -> void:
	PhysicsServer3D.space_step(physics_space, delta)
	PhysicsServer3D.space_flush_queries(physics_space)
	
func _snapshot_space(tick: int) -> void:
	var rid_states: Dictionary[RID, Array] = {}
	for element in scene_collision_objects:
		var rid = element.get_rid()
		rid_states[rid] = get_body_states(rid)

	collision_objects_snapshots[tick] = rid_states

func _rollback_space(tick) -> void:
	if snapshots.has(tick):
		var rid_states = collision_objects_snapshots[tick]
		for rid in rid_states.keys():
			set_body_states(rid, rid_states[rid])


func get_body_states(rid: RID) -> Array:
	var body_state: Array = [Vector3.ZERO, Quaternion.IDENTITY, Vector3.ZERO, Vector3.ZERO]
	body_state[0] = PhysicsServer3D.body_get_state(rid, PhysicsServer3D.BODY_STATE_TRANSFORM)
	body_state[1] = PhysicsServer3D.body_get_state(rid, PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY)
	body_state[2] = PhysicsServer3D.body_get_state(rid, PhysicsServer3D.BODY_STATE_ANGULAR_VELOCITY)
	body_state[3] = PhysicsServer3D.body_get_state(rid, PhysicsServer3D.BODY_STATE_SLEEPING)
	return body_state

func set_body_states(rid: RID, body_state: Array) -> void:
	PhysicsServer3D.body_set_state(rid, PhysicsServer3D.BODY_STATE_TRANSFORM, body_state[0])
	PhysicsServer3D.body_set_state(rid, PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY, body_state[1])
	PhysicsServer3D.body_set_state(rid, PhysicsServer3D.BODY_STATE_ANGULAR_VELOCITY, body_state[2])
	PhysicsServer3D.body_set_state(rid, PhysicsServer3D.BODY_STATE_SLEEPING, body_state[3])

func scan_tree():
	scene_collision_objects.clear()
	scene_collision_objects = get_all_children(get_node('/root'))

func get_all_children(in_node: Node) -> Array:
	var nodes = []
	nodes = in_node.find_children("*", "CollisionObject3D", true, false)
	return nodes

func node_added(node: Node) -> void:
	if node is CollisionObject3D:
		scene_collision_objects.append(node)

func node_removed(node: Node) -> void:
	if node is CollisionObject3D:
		scene_collision_objects.erase(node)
