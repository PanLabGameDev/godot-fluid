extends Node2D

# Configuration
const pixel_size = 10
const resolution = Vector2.ONE * 1000

const LINE_COLOR = Color(0.1, 0.1, 0.1)
const fill_rate = 10 # per second # TODO should use delta

# Members
var board
var grid_resolution

var mousepos = Vector2()
var left_mousedown = false
var right_mousedown = false
var cursor_size = 1
var paused = true

func _ready():

	#OS.vsync_enabled = false
	#Engine.target_fps = 200

	resolution.x = int(resolution.x / pixel_size) * pixel_size
	resolution.y = int(resolution.y / pixel_size) * pixel_size

	grid_resolution = Vector2(int(resolution.x / pixel_size), int(resolution.y / pixel_size))
	board = Board.new(grid_resolution)

	OS.window_size = resolution

func screen_pos_to_board_pos(screen_pos):
	return Vector2(int(screen_pos.x / pixel_size), int(screen_pos.y / pixel_size))


var fps_sim = 1000
var sim_frame_counter = 0
var sim_frame_step = 1.0 / fps_sim

func _process(delta):
	update() # Redraw

	if left_mousedown:
		var board_coo = screen_pos_to_board_pos(mousepos)
		brush_draw_pixels(board_coo)
	if right_mousedown:
		var board_coo = screen_pos_to_board_pos(mousepos)
		brush_draw_pixels(board_coo, true)

	if not paused:
		"""
		sim_frame_counter += delta
		if sim_frame_counter >= sim_frame_step:
			sim_frame_counter -= sim_frame_step
			board.update()
		"""
		board.update()
		# """

func brush_draw_pixels(pos, clearing=false):
	var radius = cursor_size
	for y in range(-radius, radius + 1):
		for x in range(-radius, radius + 1):
			var screen_x = pos.x + x
			var screen_y = pos.y + y
			if 0 <= screen_x and screen_x < grid_resolution.x and 0 <= screen_y and screen_y < grid_resolution.y:
				if x*x + y*y < radius * radius: # Make round brush
					if clearing:
						board.clear_pixel(Vector2(screen_x, screen_y))
					else:
						board.set_pixel(Vector2(screen_x, screen_y), fill_rate)

func _draw():
	#_draw_grid()
	_draw_pixels()
	_draw_ui()
	VisualServer.circle

func _draw_pixels():
	var filled = true
	var width = 0

	for y in board.resolution.y:
		for x in board.resolution.x:
			var pp = Vector2(x, y)
			var p = board.get_pixel(pp)
			if p == 0:
				pass
			else:
				var val = inverse_lerp(256, 0, p)
				var col = Color(0, 0, val)
				draw_rect(Rect2(x * pixel_size, y * pixel_size, pixel_size, pixel_size), col, filled)


func _draw_ui():
	draw_arc(mousepos, cursor_size * pixel_size, 0, PI * 2, 64, Color.orange, 2, false)

func _draw_grid():
	for x in range(grid_resolution.x):
		draw_line(Vector2(x * pixel_size, 0), Vector2(x*pixel_size, resolution.y), LINE_COLOR)
	for y in range(grid_resolution.y):
		draw_line(Vector2(0, y * pixel_size), Vector2(resolution.x, y*pixel_size), LINE_COLOR)


func _input(event):
	if event.is_echo():
		return

	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_LEFT:
				left_mousedown = event.is_pressed()
			BUTTON_RIGHT:
				right_mousedown = event.is_pressed()
			BUTTON_WHEEL_UP:
				if event.is_pressed():
					cursor_size += 1
			BUTTON_WHEEL_DOWN:
				if event.is_pressed():
					cursor_size = max(1, cursor_size - 1)
	elif event is InputEventMouseMotion:
		mousepos = event.position
	elif event is InputEventKey:
		match event.scancode:
			KEY_ENTER:
				if event.is_pressed():
					board.update()
					board.print_board()
			KEY_SPACE:
				if event.is_pressed():
					paused = !paused

