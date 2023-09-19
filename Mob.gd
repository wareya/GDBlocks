extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    for node in get_tree().get_nodes_in_group("Mobs"):
        if node == self:
            continue
        var diff = global_position - node.global_position
        var dist = diff.length()
        var dir = diff.normalized()
        if dist < 128.0:
            global_position += dir*delta*200.0
    pass
