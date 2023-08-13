extends Camera2D

export (NodePath) var target

var target_return_enabled = true
var target_return_rate = 0.02

var zoom_sensitivity = 10
var zoom_speed = 0.05

var events = {}
var last_drag_distance = 0

func _process(delta):
	if target and target_return_enabled and events.size() == 0:
		position = lerp(position, get_node(target).position, target_return_rate)

func _unnhandled_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			events[event.index] = event
			if events.size() == 1:
				var ps = 1 #_make_ps()
				#_set_mode(ps)
				get_parent().draw_cell(ps)
		else:
			events.erase(event.index)
	elif event is InputEventScreenDrag:
		events[event.index] = event
		if events.size() == 1:
			print("A")
#			if _is_none():
#				position -= event.relative.rotated(rotation) * zoom.x
#			else:
#				var ps = _make_ps()
#				_set_mode(ps)
#				get_parent().draw_cell(ps)
		elif events.size() == 2:
			var drag_distance = events[0].position.distance_to(events[1].position)
			if abs(drag_distance - last_drag_distance) > zoom_sensitivity:
				var new_zoom = (1 + zoom_speed) if drag_distance < last_drag_distance else (1 - zoom_speed)
				#_clamp_zoom(new_zoom)
				last_drag_distance = drag_distance
#	elif event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_UP:
#		_clamp_zoom(1 / 1.1)
#	elif event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_DOWN:
#		_clamp_zoom(1.1)
	pass
