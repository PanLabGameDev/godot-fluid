class_name Board
extends Reference

var flow_speed = 1

# Members
var pixels = []
var buffer = []
var resolution = Vector2()

func _init(resolution):
	pixels = []
	self.resolution = resolution

	for i in range(resolution.x * resolution.y):
		pixels.append(0)

func set_pixel(pos, value = 1):
	if pos.x >= 0 and pos.x < resolution.x and pos.y >= 0 and pos.y < resolution.y:
		pixels[conv(pos)] = min(32, pixels[conv(pos)] + value)

func get_pixel(pos):
	if pos.x >= 0 and pos.x < resolution.x and pos.y >= 0 and pos.y < resolution.y:
		return pixels[conv(pos)]
	return 0

func clear_pixel(pos):
	if pos.x > 0 and pos.x < resolution.x and pos.y > 0 and pos.y < resolution.y:
		pixels[conv(pos)] = 0

func conv(pos):
	return pos.y * resolution.x + pos.x

# Buffer methods
func _set_pixel_buffer(x, y, value):
	#printt(x, y, value)
	if 0 <= x and x < resolution.x and  0 <= y and y < resolution.y:
		buffer[conv(Vector2(x, y))] += value

func _get_pixel_board_space(x, y):
	if 0 <= x and x < resolution.x and  0 <= y and y < resolution.y:
		return pixels[conv(Vector2(x, y))]
	else:
		return -1


var prev_tick = 0
func update():
	var new_tick = OS.get_ticks_msec()
	var delta_tick = new_tick - prev_tick
	prev_tick = new_tick
	print(delta_tick, "ms")
	buffer = []
	for p in pixels:
		buffer.append(p)

	for y in resolution.y:
		for x in resolution.x:
			var p = _get_pixel_board_space(x, y)
			if p <= 0:
				continue

			var target_pixel_value = _get_pixel_board_space(x, y+1)
			if target_pixel_value != -1 and target_pixel_value < p:
				_set_pixel_buffer(x, y, -flow_speed)
				_set_pixel_buffer(x, y+1, flow_speed)
			else:
				target_pixel_value = _get_pixel_board_space(x-1, y)
				if target_pixel_value != -1 and target_pixel_value < p:
					_set_pixel_buffer(x, y, -flow_speed)
					_set_pixel_buffer(x-1, y, flow_speed)
				else:
					target_pixel_value = _get_pixel_board_space(x+1, y)
					if target_pixel_value != -1 and target_pixel_value < p:
						_set_pixel_buffer(x, y, -flow_speed)
						_set_pixel_buffer(x+1, y, flow_speed)
	pixels = buffer

func print_board():
	var text = str(OS.get_ticks_msec() / 1000.0) + "\n"
	for y in resolution.y:
		for x in resolution.x:
			text += "[" + str(get_pixel(Vector2(x, y))) + "], "
		text += "\n"
	print(text)
