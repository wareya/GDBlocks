@tool
extends Control

func _ready() -> void:
    anchor_bottom = 1
    anchor_right = 1
    offset_bottom = 0
    offset_right = 0

var dragging = false
func _gui_input(event : InputEvent) -> void:
    if event is InputEventMouseMotion and event.button_mask & (MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_MIDDLE):
        print(event)
        $Field.position += event.relative
    if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
        var up = event.button_index == MOUSE_BUTTON_WHEEL_UP
        var scaler = pow(2.0, 0.25 if up else -0.25)
        var xform = Transform2D()
        xform = Transform2D().translated(-event.position) * xform
        xform = Transform2D().scaled(Vector2.ONE*scaler) * xform
        xform = Transform2D().translated(event.position) * xform
        $Field.transform = xform * $Field.transform
        if $Field.scale.distance_to(Vector2.ONE) < 0.1:
            $Field.scale = Vector2.ONE
            $Field.position = $Field.position.round()
        print(event)
    pass

func _process(delta: float) -> void:
    anchor_bottom = 1
    anchor_right = 1
    offset_bottom = 0
    offset_right = 0
    
    var clusters = {}
    var children : Array = $Field.get_children()
    for child in children:
        var rootmost = child.previous
        if rootmost and rootmost.previous:
            rootmost = rootmost.previous
        if rootmost:
            clusters[child] = rootmost
        else:
            clusters[child] = child
    
    children.sort_custom(func (a : Node, b : Node):
        return clusters[a].position.y < clusters[b].position.y
    )
    for i in children.size():
        $Field.move_child(children[i], i)
    pass
