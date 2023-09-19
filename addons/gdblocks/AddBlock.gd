@tool
extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

@export_node_path var expr_component_1 = null
@export_node_path var expr_component_2 = null


var dragging = false
func _gui_input(event : InputEvent) -> void:
    if event is InputEventMouse:
        dragging = event.button_mask & MOUSE_BUTTON_MASK_LEFT
    
    if dragging:
        var focus_holder := get_viewport().gui_get_focus_owner()
        if focus_holder and focus_holder != self:
            focus_holder.release_focus()
    
    # FIXME only remove if we move at least a few pxiels
    if event is InputEventMouseButton:
        print(event)
        if event.button_index == MOUSE_BUTTON_LEFT:
            if previous:
                if previous.inner == self:
                    previous.inner = null
                if previous.next == self:
                    previous.next = null
                previous = null
            if event.pressed:
                make_on_top()
            else:
                if found_target_node:
                    if found_target_as_inner:
                        if found_target_node.inner:
                            set_final_next(found_target_node.inner)
                        found_target_node.inner = self
                        previous = found_target_node
                    else:
                        if found_target_node.next:
                            set_final_next(found_target_node.next)
                        found_target_node.next = self
                        previous = found_target_node
                make_not_on_top()
    
    # FIXME only move if we move at least a few pxiels
    if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
        #print(event)
        translate(event.relative)
    pass

@export var supports_inner = false

func translate(amount : Vector2):
    position += amount
    if next:
        next.translate(amount)
    if inner:
        inner.translate(amount)

# Called every frame. 'delta' is the elapsed time since the previous frame.
var found_target_node : Control = null
var found_target_as_inner = false
func _process(delta: float) -> void:
    found_target_as_inner = false
    found_target_node = null
    var best_dist = 16.0
    if dragging:
        for _other in get_tree().get_nodes_in_group("CodeBlocks"):
            if _other == self:
                continue
            var other = _other as Control
            var end_point = other.position + Vector2(0, other.calculate_next_height())
            var dist = ((end_point - position)*Vector2(0.5,1.0)).length()
            if dist < best_dist:
                best_dist = dist
                found_target_node = other
            
            if other.supports_inner:
                end_point = other.position + Vector2(inner_left_padding, other.calculate_base_child_height())
                dist = ((end_point - position)*Vector2(0.5,1.0)).length()
                if dist < best_dist:
                    best_dist = dist
                    found_target_node = other
                    found_target_as_inner = true
    else:
        if previous:
            # FIXME support group blocks
            if previous.inner == self:
                position = previous.position + Vector2(inner_left_padding, previous.calculate_base_child_height())
            else:
                position = previous.position + Vector2(0, previous.calculate_next_height())
    
    if has_node("BottomPanel"):
        var first_child = get_children().front()
        if first_child:
            var inner_height = calculate_partial_child_height()
            $BottomPanel.position = Vector2(0, inner_height)
    
    queue_redraw()

func calculate_base_child_height():
    var total = 0
    var first_child = get_children().front()
    if first_child:
        total += first_child.size.y - 2
    return total

func calculate_partial_child_height():
    var total = calculate_base_child_height()
    if inner:
        total += inner.calculate_total_height()
    return total

func calculate_next_height():
    return calculate_child_height()

func calculate_child_height():
    var total = calculate_partial_child_height()
    if has_node("BottomPanel"):
        total += $BottomPanel.size.y - 2
    return total

func calculate_total_height():
    var total = calculate_child_height()
    if next:
        total += next.calculate_total_height()
    return total

const inner_left_padding = 12

var previous : Control = null
var next : Control = null
var inner : Control = null

func set_final_next(other):
    if next:
        next.set_final_next(other)
    else:
        next = other
        other.previous = self

func make_on_top():
    z_index = 1
    if next:
        next.make_on_top()
    if inner:
        inner.make_on_top()

func make_not_on_top():
    z_index = 0
    if next:
        next.make_not_on_top()
    if inner:
        inner.make_not_on_top()

func _draw():
    if dragging and found_target_node:
        var where = Vector2(0, found_target_node.calculate_next_height()) \
            if !found_target_as_inner \
            else Vector2(inner_left_padding, found_target_node.calculate_base_child_height())
        
        var end_point = (found_target_node.position + where - position + Vector2(0, 1)).round()
        draw_line(end_point, end_point + Vector2(found_target_node.size.x, 0), Color(1.0, 0.3, 0.1), 3.0, false)
