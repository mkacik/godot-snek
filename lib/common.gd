extends Node

# WATCH OUT! Move speed (in px/s) has to be synchronized with cell size and move
# tick timer. If snake head is not moving out of previous cell fast enough, tail
# segments moving every tick will collide with it.
# MINIMAL_MOVE_INTERVAL ~= CELL_SIZE / MOVE_ANIMATION_SPEED + 0.01
const MOVE_ANIMATION_SPEED: int = 200
const CELL_SIZE: int = 16
const MOVE_INTERVAL: float = 0.2

# Default clamp implementation requires that first argument passed contains
# the min values and second contains the max. This helper function drops this
# requirement.
static func clamped(pos: Vector2, a: Vector2, b: Vector2) -> Vector2:
    var min_pos = Vector2.ZERO
    var max_pos = Vector2.ZERO

    if (a.x < b.x):
        min_pos.x = a.x
        max_pos.x = b.x
    else:
        min_pos.x = b.x
        max_pos.x = a.x

    if (a.y < b.y):
        min_pos.y = a.y
        max_pos.y = b.y
    else:
        min_pos.y = b.y
        max_pos.y = a.y

    return pos.clamp(min_pos, max_pos)
