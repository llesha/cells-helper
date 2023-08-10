extends Control

var _previousPosition: Vector2 = Vector2(0, 0)
var _moveCamera: bool = false
var children = []
var type = cell.WALL
onready var buttons = [\
	[$CanvasLayer/VB/Wall, cell.WALL],
	[$CanvasLayer/VB/Box, cell.BOX], \
	[$CanvasLayer/VB/Player, cell.PLAYER]]
var processing = false
var mode = false

enum cell {
	WALL,
	BOX,
	NONE,
	PLAYER
}

func _ready() -> void:
	pass # Replace with function body.

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			_previousPosition = event.position
			_moveCamera = true
		else:
			_moveCamera = false
	elif event is InputEventMouseMotion and _moveCamera and type == cell.NONE:
		$Camera2D.position += (_previousPosition - event.position)*$Camera2D.zoom
		_previousPosition = event.position
	elif event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_UP:
		$Camera2D.zoom /= 1.1
	elif event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_DOWN:
		$Camera2D.zoom *= 1.1
	elif(event is InputEventScreenTouch and event.pressed):
		if type != cell.NONE:
			var ps = _make_ps()
			if type == cell.WALL:
				mode = $TileMap.get_cell(ps.x,ps.y) != 1 # TODO
			else:
				mode = $WallMap.get_cell(ps.x,ps.y) != 1
			draw_cell(ps)
	elif event is InputEventScreenTouch:
		print($TileMap.get_used_rect())
	elif event is InputEventScreenDrag:
		var ps = _make_ps()
		draw_cell(ps)
	elif event is InputEventKey:
		if event.pressed and event.scancode == KEY_A:
			$Camera2D.position.x -= 5
		if event.pressed and event.scancode == KEY_D:
			$Camera2D.position.x += 5
		if event.pressed and event.scancode == KEY_W:
			$Camera2D.position.y -= 5
		if event.pressed and event.scancode == KEY_S:
			$Camera2D.position.y += 5
		if event.pressed and event.scancode == KEY_Q:
			$Camera2D.zoom *= 1.1
		if event.pressed and event.scancode == KEY_E:
			$Camera2D.zoom /= 1.1

func _make_ps():
	return ((get_global_mouse_position()- Vector2(3,3))/6).round()

func draw_cell(ps):
	if type == cell.WALL:
		$TileMap.set_cell(ps.x, ps.y, 1 if mode else -1)
	elif type == cell.BOX:
		$WallMap.set_cell(ps.x, ps.y, 1 if mode else -1)
	elif type == cell.PLAYER:
		$WallMap.set_cell(ps.x, ps.y, 0 if mode else -1)

func _on_Settings_toggled(button_pressed: bool) -> void:
	pass

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
	#print(cell.keys()[type], cell.keys())

func _on_Wall_toggled(button_pressed: bool) -> void:
	if !processing:
		processing = true
		#print("Wall")
		_change_sprite($CanvasLayer/VB/Wall.icon, button_pressed, cell.WALL)
		processing = false


func _on_Box_toggled(button_pressed: bool) -> void:
	if !processing:
		processing = true
		#print("Box")
		_change_sprite($CanvasLayer/VB/Box.icon, button_pressed, cell.BOX)
		processing = false

func _on_Player_toggled(button_pressed: bool) -> void:
	if !processing:
		processing = true
		#print("Player")
		_change_sprite($CanvasLayer/VB/Player.icon, button_pressed, cell.PLAYER)
		processing = false
