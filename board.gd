extends Node
class_name Board

# 棋盘尺寸：10列 x 20行
const BOARD_WIDTH := 10
const BOARD_HEIGHT := 20

# 绘制常量
const CELL_SIZE := 30  # 每个格子的像素大小

# 棋盘网格，0表示空，1表示已固定的方块
var grid: Array[Array] = []

# 七种标准俄罗斯方块（Tetromino）的相对坐标
# 使用 Vector2，假设 (0,0) 为旋转轴心
var tetromino_shapes: Dictionary = {
	"I": [
		Vector2(-1, 0),
		Vector2(0, 0),
		Vector2(1, 0),
		Vector2(2, 0)
	],
	"J": [
		Vector2(-1, -1),
		Vector2(-1, 0),
		Vector2(0, 0),
		Vector2(1, 0)
	],
	"L": [
		Vector2(1, -1),
		Vector2(-1, 0),
		Vector2(0, 0),
		Vector2(1, 0)
	],
	"O": [
		Vector2(0, 0),
		Vector2(1, 0),
		Vector2(0, 1),
		Vector2(1, 1)
	],
	"S": [
		Vector2(0, 0),
		Vector2(1, 0),
		Vector2(-1, 1),
		Vector2(0, 1)
	],
	"T": [
		Vector2(0, 0),
		Vector2(-1, 1),
		Vector2(0, 1),
		Vector2(1, 1)
	],
	"Z": [
		Vector2(-1, 0),
		Vector2(0, 0),
		Vector2(0, 1),
		Vector2(1, 1)
	]
}

# ====== 状态变量 ======
var current_type: String = ""          # 当前方块名称
var current_shape: Array[Vector2] = [] # 当前方块的坐标数组
var current_pos: Vector2 = Vector2.ZERO # 当前方块在网格的坐标

# 随机数生成器
var rng := RandomNumberGenerator.new()

# 定时器
var fall_timer: Timer = null

# 初始化函数
func _ready() -> void:
	# 初始化随机数生成器
	rng.randomize()
	
	# 初始化棋盘网格
	initialize_grid()
	
	# 生成第一个方块
	spawn_tetromino()
	
	# 创建并启动定时器
	setup_timer()
	
	# 打印初始棋盘
	print_board()
	
	# 请求初始绘制
	queue_redraw()

# 初始化棋盘网格
func initialize_grid() -> void:
	grid.clear()
	
	for y in range(BOARD_HEIGHT):
		var row := []
		for x in range(BOARD_WIDTH):
			row.append(0)  # 0 表示空位置
		grid.append(row)
	
	print("棋盘初始化完成：%d列 x %d行" % [BOARD_WIDTH, BOARD_HEIGHT])

# 设置定时器
func setup_timer() -> void:
	# 创建定时器节点
	fall_timer = Timer.new()
	add_child(fall_timer)
	
	# 设置定时器属性
	fall_timer.wait_time = 0.5  # 0.5秒间隔
	fall_timer.one_shot = false  # 重复执行
	fall_timer.autostart = true  # 自动启动
	
	# 连接信号 (Godot 4.x 语法)
	fall_timer.timeout.connect(Callable(self, "_on_fall_timer_timeout"))
	
	# 启动定时器
	fall_timer.start()
	
	print("自动下落定时器已启动，间隔: %.1f秒" % fall_timer.wait_time)

# 定时器超时回调
func _on_fall_timer_timeout() -> void:
	tick_down()

# 生成新方块
func spawn_tetromino() -> void:
	# 从7种方块中随机选择一种
	var shape_names = get_all_shape_names()
	var random_index = rng.randi_range(0, shape_names.size() - 1)
	current_type = shape_names[random_index]
	current_shape = get_tetromino_shape(current_type)
	
	# 设置初始位置：顶部中央 (x=4, y=0)
	current_pos = Vector2(4, 0)
	
	print("生成新方块: %s，初始位置: (%d, %d)" % [current_type, int(current_pos.x), int(current_pos.y)])
	
	# 检查生成位置是否有效
	if not is_valid_position(current_pos, current_shape):
		print("游戏结束：无法生成新方块")
		# 停止定时器
		if fall_timer:
			fall_timer.stop()
		return

# 碰撞检测
func is_valid_position(target_pos: Vector2, shape: Array[Vector2]) -> bool:
	for block_pos in shape:
		var world_x = target_pos.x + block_pos.x
		var world_y = target_pos.y + block_pos.y
		
		# 检查是否越过左右边界
		if world_x < 0 or world_x >= BOARD_WIDTH:
			return false
		
		# 检查是否触底
		if world_y >= BOARD_HEIGHT:
			return false
		
		# 检查对应棋盘位置是否已被占用（值不为0）
		if world_y >= 0 and grid[world_y][world_x] != 0:
			return false
	
	return true

# 下落逻辑
func tick_down() -> void:
	var new_pos = current_pos + Vector2(0, 1)
	
	if is_valid_position(new_pos, current_shape):
		# 可以下移，更新位置
		current_pos = new_pos
		print("方块下移一格到: (%d, %d)" % [int(current_pos.x), int(current_pos.y)])
		print_board()
	else:
		# 无法下移，锁定方块
		lock_tetromino()
		spawn_tetromino()
		print_board()
	
	# 请求重绘画面
	queue_redraw()

# 锁定当前方块到棋盘
func lock_tetromino() -> void:
	if current_type == "" or current_shape.size() == 0:
		return
	
	print("锁定方块: %s" % current_type)
	
	for block_pos in current_shape:
		var world_x = current_pos.x + block_pos.x
		var world_y = current_pos.y + block_pos.y
		
		# 只锁定在棋盘范围内的方块
		if world_x >= 0 and world_x < BOARD_WIDTH and world_y >= 0 and world_y < BOARD_HEIGHT:
			grid[world_y][world_x] = 1  # 用1表示已锁定的方块

# 可视化打印棋盘
func print_board() -> void:
	# 模拟清屏效果：输出50个空行
	for i in range(50):
		print("")
	
	print("=== 俄罗斯方块游戏 ===")
	print("当前方块: %s, 位置: (%d, %d)" % [current_type, int(current_pos.x), int(current_pos.y)])
	print("格式: 0=空, 1=固定方块, 2=活动方块")
	print("")
	
	# 创建显示网格
	var display_grid := []
	for y in range(BOARD_HEIGHT):
		var row := []
		for x in range(BOARD_WIDTH):
			row.append(grid[y][x])
		display_grid.append(row)
	
	# 标记当前下落方块为2
	if current_type != "" and current_shape.size() > 0:
		for block_pos in current_shape:
			var world_x = current_pos.x + block_pos.x
			var world_y = current_pos.y + block_pos.y
			if world_x >= 0 and world_x < BOARD_WIDTH and world_y >= 0 and world_y < BOARD_HEIGHT:
				display_grid[world_y][world_x] = 2
	
	# 打印网格
	# 生成列号字符串
	var column_numbers := ""
	for i in range(BOARD_WIDTH):
		column_numbers += str(i)
		if i < BOARD_WIDTH - 1:
			column_numbers += " "
	print("   " + column_numbers)  # 列号
	# 生成上分隔线
	var top_separator := "  +"
	for i in range(BOARD_WIDTH * 2 - 1):
		top_separator += "-"
	top_separator += "+"
	print(top_separator)
	
	for y in range(BOARD_HEIGHT):
		var row_str := "%2d|" % y
		for x in range(BOARD_WIDTH):
			row_str += str(display_grid[y][x])
			if x < BOARD_WIDTH - 1:
				row_str += " "
		row_str += "|"
		print(row_str)
	
	# 生成下分隔线
	var bottom_separator := "  +"
	for i in range(BOARD_WIDTH * 2 - 1):
		bottom_separator += "-"
	bottom_separator += "+"
	print(bottom_separator)
	print("")

# ====== 辅助函数 ======

# 获取指定方块的形状
func get_tetromino_shape(shape_name: String) -> Array[Vector2]:
	if tetromino_shapes.has(shape_name):
		# 从字典获取无类型数组
		var untyped_array = tetromino_shapes[shape_name].duplicate()
		# 创建类型化数组并赋值
		var typed_array: Array[Vector2] = []
		typed_array.assign(untyped_array)
		return typed_array
	return []

# 获取所有方块形状的名称
func get_all_shape_names() -> Array[String]:
	# 从字典获取键并转换为类型化数组
	var keys = tetromino_shapes.keys()
	var typed_array: Array[String] = []
	typed_array.assign(keys)
	return typed_array

# 检查位置是否在棋盘范围内
func is_cell_in_bounds(x: int, y: int) -> bool:
	return x >= 0 and x < BOARD_WIDTH and y >= 0 and y < BOARD_HEIGHT

# 获取棋盘指定位置的值
func get_cell(x: int, y: int) -> int:
	if is_cell_in_bounds(x, y):
		return grid[y][x]
	return -1

# 设置棋盘指定位置的值
func set_cell(x: int, y: int, value: int) -> bool:
	if is_cell_in_bounds(x, y):
		grid[y][x] = value
		return true
	return false

# 清空棋盘
func clear_board() -> void:
	for y in range(BOARD_HEIGHT):
		for x in range(BOARD_WIDTH):
			grid[y][x] = 0

# 停止游戏
func stop_game() -> void:
	if fall_timer:
		fall_timer.stop()
		print("游戏已停止")

# ====== 绘制函数 ======

func _draw() -> void:
	# 绘制游戏边界框
	draw_game_border()
	
	# 绘制已固定的方块
	draw_fixed_blocks()
	
	# 绘制当前活动方块
	draw_current_tetromino()

# 绘制游戏边界框
func draw_game_border() -> void:
	var border_rect := Rect2(
		0, 0,
		BOARD_WIDTH * CELL_SIZE,
		BOARD_HEIGHT * CELL_SIZE
	)
	# 绘制半透明边框
	draw_rect(border_rect, Color(0.5, 0.5, 0.5, 0.3), false, 2.0)

# 绘制已固定的方块
func draw_fixed_blocks() -> void:
	for y in range(BOARD_HEIGHT):
		for x in range(BOARD_WIDTH):
			if grid[y][x] == 1:  # 已固定的方块
				var rect := Rect2(
					x * CELL_SIZE,
					y * CELL_SIZE,
					CELL_SIZE,
					CELL_SIZE
				)
				# 绘制灰色方块
				draw_rect(rect, Color.DARK_GRAY)
				# 绘制边框
				draw_rect(rect, Color(0.2, 0.2, 0.2), false, 1.0)

# 绘制当前活动方块
func draw_current_tetromino() -> void:
	if current_type == "" or current_shape.size() == 0:
		return
	
	# 根据方块类型选择颜色
	var block_color := get_tetromino_color(current_type)
	
	for block_pos in current_shape:
		var world_x = current_pos.x + block_pos.x
		var world_y = current_pos.y + block_pos.y
		
		# 只绘制在棋盘范围内的方块
		if world_x >= 0 and world_x < BOARD_WIDTH and world_y >= 0 and world_y < BOARD_HEIGHT:
			var rect := Rect2(
				world_x * CELL_SIZE,
				world_y * CELL_SIZE,
				CELL_SIZE,
				CELL_SIZE
			)
			# 绘制彩色方块
			draw_rect(rect, block_color)
			# 绘制边框
			draw_rect(rect, block_color.darkened(0.3), false, 1.5)

# 获取方块颜色
func get_tetromino_color(shape_name: String) -> Color:
	match shape_name:
		"I":
			return Color.CYAN
		"J":
			return Color.BLUE
		"L":
			return Color.ORANGE
		"O":
			return Color.YELLOW
		"S":
			return Color.GREEN
		"T":
			return Color.PURPLE
		"Z":
			return Color.RED
		_:
			return Color.WHITE