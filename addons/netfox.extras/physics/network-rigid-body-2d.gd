extends RigidBody2D

class_name NetworkRigidBody2D

## A rollback / state synchronizer class for RigidBody2D.
## Set state property path to physics_state to synchronize the state of this body.

@onready var direct_state = PhysicsServer2D.body_get_direct_state(get_rid())

var physics_state: Array:
	get: return get_state()
	set(v): set_state(v)

enum {
	ORIGIN,
	QUAT,
	LIN_VEL,
	ANG_VEL,
	SLEEPING
}

func get_state() -> Array:
	var body_state: Array = [Vector3.ZERO, Quaternion.IDENTITY, Vector3.ZERO, Vector3.ZERO, false]
	body_state[ORIGIN] = direct_state.transform.origin
	body_state[QUAT] = direct_state.transform.basis.get_rotation_quaternion()
	body_state[LIN_VEL] = direct_state.linear_velocity
	body_state[ANG_VEL] = direct_state.angular_velocity
	body_state[SLEEPING] = direct_state.sleeping
	return body_state

func set_state(remote_state: Array) -> void:
	direct_state.transform.origin = remote_state[ORIGIN]
	direct_state.transform.basis = Basis(remote_state[QUAT])
	direct_state.linear_velocity = remote_state[LIN_VEL]
	direct_state.angular_velocity = remote_state[ANG_VEL]
	direct_state.sleeping = remote_state[SLEEPING]
	_rigid_rollback_tick(NetworkTime.ticktime, NetworkRollback.tick)

## Override and apply any logic, forces or impulses to the rigid body.
## The physics engine will run its simulation during rollback_tick with other nodes
func _rigid_rollback_tick(delta, tick):
	pass