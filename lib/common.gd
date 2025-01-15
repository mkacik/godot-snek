extends Node

const MOVE_ANIMATION_SPEED = 100

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
