extends Control

enum cell {
	WALL,
	BOX,
	NONE,
	PLAYER
}

onready var buttons = [\
	[$CanvasLayer/P/VB/Wall, cell.WALL],
	[$CanvasLayer/P/VB/Box, cell.BOX], \
	[$CanvasLayer/P/VB/Player, cell.PLAYER]]

var type = cell.WALL
var processing = false
var mode = false

var min_zoom = 0.1
var max_zoom = 5
var zoom_sensitivity = 10
var zoom_speed = 0.05

var _previousPosition: Vector2 = Vector2(0, 0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_UP:
		$Camera2D.zoom /= 1.1
	elif event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_DOWN:
		$Camera2D.zoom *= 1.1
	elif event is InputEventScreenTouch and event.pressed:
		_previousPosition = event.position
		if type != cell.NONE:
			var ps = _make_ps()
			if type == cell.WALL:
				mode = $TileMap.get_cell(ps.x,ps.y) == -1
			else:
				mode = $WallMap.get_cell(ps.x,ps.y) == -1
			draw_cell(ps)
	elif event is InputEventScreenDrag:
		if _is_none():
			$Camera2D.position += (_previousPosition - event.position)*$Camera2D.zoom
			_previousPosition = event.position
		else:
			var ps = _make_ps()
			draw_cell(ps)

func _make_ps():
	return ((get_global_mouse_position() - Vector2(3,3))/6).round()

func draw_cell(ps):
	if type == cell.WALL:
		$TileMap.set_cell(ps.x, ps.y, 1 if mode else -1)
	elif type == cell.BOX:
		$WallMap.set_cell(ps.x, ps.y, 1 if mode else -1)
	elif type == cell.PLAYER:
		$WallMap.set_cell(ps.x, ps.y, 0 if mode else -1)

func _is_none() -> bool:
	return type == cell.NONE

func _is_wall() -> bool:
	return type == cell.WALL

func _is_box() -> bool:
	return type == cell.BOX

func _is_player() -> bool:
	return type == cell.PLAYER

func _set_mode(ps):
	if _is_wall():
		get_parent().mode = get_parent().get_node("TileMap").get_cell(ps.x,ps.y) != 1
	else:
		get_parent().mode = get_parent().get_node("TileMap").get_cell(ps.x,ps.y) != 1

func _on_Settings_toggled(button_pressed: bool) -> void:
	$TileMap.clear()
	$WallMap.clear()

func _change_sprite(sprite: AtlasTexture, is_pressed: bool, new_type: int):
	var pos = sprite.region.position
	if is_pressed and type == new_type:
		sprite.region = Rect2(Vector2(pos.x + 17, pos.y), sprite.region.size)
	elif !is_pressed:
		sprite.region = Rect2(Vector2(pos.x - 17, pos.y), sprite.region.size)
	for b in buttons:
		if b[0].icon != sprite and type == b[1] and !b[0].pressed:
			print(cell.keys()[b[1]])
			var b_pos = b[0].icon.region.position
			b[0].icon.region = Rect2(Vector2(b_pos.x + 17, b_pos.y), b[0].icon.region.size)
			b[0].update()
			b[0].pressed = true
	if type == new_type:
		type = cell.NONE
	elif !is_pressed:
		type = new_type

func _on_Wall_toggled(button_pressed: bool) -> void:
	if !processing:
		processing = true
		_change_sprite($CanvasLayer/P/VB/Wall.icon, button_pressed, cell.WALL)
		processing = false

func _on_Box_toggled(button_pressed: bool) -> void:
	if !processing:
		processing = true
		_change_sprite($CanvasLayer/P/VB/Box.icon, button_pressed, cell.BOX)
		processing = false

func _on_Player_toggled(button_pressed: bool) -> void:
	if !processing:
		processing = true
		_change_sprite($CanvasLayer/P/VB/Player.icon, button_pressed, cell.PLAYER)
		processing = false


func _on_VSlider_value_changed(value: float) -> void:
	$Camera2D.zoom = Vector2(value, value)
	pass # Replace with function body.
