extends Node
class_name Board

# 棋盘尺寸：10列 x 20行
const BOARD_WIDTH := 10
const BOARD_HEIGHT := 20

# 棋盘网格，0表示空，其他数字表示不同类型的方块
var grid: Array = []

# 七种标准俄罗斯方块（Tetromino）的相对坐标
# 使用 Vector2，假设 (0,0) 为旋转轴心
var tetromino_shapes := {
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

# ====== 新增：当前方块状态变量 ======
var current_type: String = ""          # 当前方块类型，如 'I', 'T'
var current_shape: Array = []          # 当前方块的坐标数组
var current_pos: Vector2 = Vector2.ZERO # 当前方块核心所在网格坐标

# 随机数生成器
var rng := RandomNumberGenerator.new()

# 初始化函数
func _ready() -> void:
	rng.randomize()  # 初始化随机数生成器
	initialize_grid()
	spawn_tetromino()  # 生成第一个方块
	print_grid()
	print_tetromino_info()

# 初始化棋盘网格
func initialize_grid() -> void:
	grid.clear()
	
	for y in range(BOARD_HEIGHT):
		var row := []
		for x in range(BOARD_WIDTH):
			row.append(0)  # 0 表示空位置
		grid.append(row)
	
	print("棋盘初始化完成：%d列 x %d行" % [BOARD_WIDTH, BOARD_HEIGHT])

# 打印棋盘网格（用于调试）- 升级版
func print_grid() -> void:
	print("=== 棋盘网格 ===")
	print("格式说明：0=空，1=已锁定方块，2=当前下落方块")
	print("行号从顶部(0)到底部(%d)" % (BOARD_HEIGHT - 1))
	print("列号从左(0)到右(%d)" % (BOARD_WIDTH - 1))
	print("当前方块: %s, 位置: (%d, %d)" % [current_type, current_pos.x, current_pos.y])
	print("")
	
	# 创建临时网格用于显示，包含当前下落方块
	var display_grid := []
	for y in range(BOARD_HEIGHT):
		var row := []
		for x in range(BOARD_WIDTH):
			row.append(grid[y][x])
		display_grid.append(row)
	
	# 将当前下落方块标记为2
	if current_type != "" and current_shape.size() > 0:
		for block_pos in current_shape:
			var world_x = current_pos.x + block_pos.x
			var world_y = current_pos.y + block_pos.y
			if world_x >= 0 and world_x < BOARD_WIDTH and world_y >= 0 and world_y < BOARD_HEIGHT:
				display_grid[world_y][world_x] = 2
	
	# 打印网格
	for y in range(BOARD_HEIGHT):
		var row_str := "行 %2d: [" % y
		for x in range(BOARD_WIDTH):
			row_str += str(display_grid[y][x])
			if x < BOARD_WIDTH - 1:
				row_str += " "
		row_str += "]"
		print(row_str)
	
	print("")

# 打印方块信息
func print_tetromino_info() -> void:
	print("=== 俄罗斯方块形状 ===")
	print("共 %d 种标准方块" % tetromino_shapes.size())
	print("")
	
	for shape_name in tetromino_shapes.keys():
		var shape = tetromino_shapes[shape_name]
		print("方块 %s:" % shape_name)
		for i in range(shape.size()):
			var pos = shape[i]
			print("  块 %d: (%d, %d)" % [i, pos.x, pos.y])
		print("")

# 获取棋盘指定位置的值
func get_cell(x: int, y: int) -> int:
	if is_valid_position(x, y):
		return grid[y][x]
	return -1  # 无效位置返回 -1

# 设置棋盘指定位置的值
func set_cell(x: int, y: int, value: int) -> bool:
	if is_valid_position(x, y):
		grid[y][x] = value
		return true
	return false

# 检查位置是否在棋盘范围内
func is_valid_position(x: int, y: int) -> bool:
	return x >= 0 and x < BOARD_WIDTH and y >= 0 and y < BOARD_HEIGHT

# 检查位置是否为空
func is_cell_empty(x: int, y: int) -> bool:
	if is_valid_position(x, y):
		return grid[y][x] == 0
	return false

# 获取棋盘宽度
func get_width() -> int:
	return BOARD_WIDTH

# 获取棋盘高度
func get_height() -> int:
	return BOARD_HEIGHT

# 清空棋盘
func clear_board() -> void:
	for y in range(BOARD_HEIGHT):
		for x in range(BOARD_WIDTH):
			grid[y][x] = 0

# 获取指定方块的形状
func get_tetromino_shape(shape_name: String) -> Array:
	if tetromino_shapes.has(shape_name):
		return tetromino_shapes[shape_name].duplicate()
	return []

# 获取所有方块形状的名称
func get_all_shape_names() -> Array:
	return tetromino_shapes.keys()

# ====== 新增：方块生成、下落和碰撞检测功能 ======

# 生成新方块
func spawn_tetromino() -> void:
	# 从7种方块中随机选择一种
	var shape_names = get_all_shape_names()
	var random_index = rng.randi_range(0, shape_names.size() - 1)
	current_type = shape_names[random_index]
	current_shape = get_tetromino_shape(current_type)
	
	# 设置初始位置：顶部中央
	# x=4 是10列棋盘的中央（0-9，中央是4.5，取整为4）
	# y=1 从第二行开始，给方块留出空间
	current_pos = Vector2(4, 1)
	
	print("生成新方块: %s，初始位置: (%d, %d)" % [current_type, current_pos.x, current_pos.y])
	
	# 检查生成位置是否有效
	if not is_valid_position_for_shape(current_pos, current_shape):
		print("警告：生成位置无效，游戏可能结束")
		# 这里可以添加游戏结束逻辑

# 碰撞检测：检查指定位置和形状是否有效
func is_valid_position_for_shape(target_pos: Vector2, shape: Array) -> bool:
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

# 尝试将方块下移一格
func tick_down() -> bool:
	var new_pos = current_pos + Vector2(0, 1)
	
	if is_valid_position_for_shape(new_pos, current_shape):
		# 可以下移，更新位置
		current_pos = new_pos
		print("方块下移一格到: (%d, %d)" % [current_pos.x, current_pos.y])
		return true
	else:
		# 无法下移，锁定方块并生成新方块
		print("方块无法下移，开始锁定")
		lock_tetromino()
		spawn_tetromino()
		return false

# 锁定当前方块到棋盘
func lock_tetromino() -> void:
	if current_type == "" or current_shape.size() == 0:
		print("错误：没有当前方块可锁定")
		return
	
	print("锁定方块: %s" % current_type)
	
	for block_pos in current_shape:
		var world_x = current_pos.x + block_pos.x
		var world_y = current_pos.y + block_pos.y
		
		# 只锁定在棋盘范围内的方块
		if world_x >= 0 and world_x < BOARD_WIDTH and world_y >= 0 and world_y < BOARD_HEIGHT:
			grid[world_y][world_x] = 1  # 用1表示已锁定的方块
	
	# 检查并消除满行
	check_and_clear_lines()
	
	# 重置当前方块状态
	current_type = ""
	current_shape = []
	current_pos = Vector2.ZERO

# 检查并消除满行
func check_and_clear_lines() -> void:
	var lines_cleared := 0
	
	for y in range(BOARD_HEIGHT - 1, -1, -1):  # 从底部向上检查
		var line_full := true
		
		# 检查这一行是否满
		for x in range(BOARD_WIDTH):
			if grid[y][x] == 0:
				line_full = false
				break
		
		if line_full:
			# 消除这一行
			lines_cleared += 1
			# 将上面的所有行下移
			for yy in range(y, 0, -1):
				for x in range(BOARD_WIDTH):
					grid[yy][x] = grid[yy - 1][x]
			
			# 最上面一行清空
			for x in range(BOARD_WIDTH):
				grid[0][x] = 0
	
	if lines_cleared > 0:
		print("消除了 %d 行" % lines_cleared)

# 移动方块（左/右）
func move_horizontal(direction: int) -> bool:  # direction: -1=左, 1=右
	var new_pos = current_pos + Vector2(direction, 0)
	
	if is_valid_position_for_shape(new_pos, current_shape):
		current_pos = new_pos
		print("方块%s移动一格到: (%d, %d)" % ["左" if direction < 0 else "右", current_pos.x, current_pos.y])
		return true
	else:
		print("方块无法%s移动" % ("左" if direction < 0 else "右"))
		return false

# 旋转方块（简单实现：暂时不实现）
func rotate_tetromino() -> bool:
	print("旋转功能暂未实现")
	return false

# 快速下落（硬降）
func hard_drop() -> void:
	print("执行硬降")
	while tick_down():
		pass  # 持续下落直到无法下落

# 测试函数：在棋盘上放置一个测试方块
func place_test_tetromino() -> void:
	# 在棋盘中央放置一个 I 方块
	var center_x := BOARD_WIDTH / 2
	var center_y := BOARD_HEIGHT / 2
	var shape = get_tetromino_shape("I")
	
	for block_pos in shape:
		var world_x = center_x + block_pos.x
		var world_y = center_y + block_pos.y
		
		if is_valid_position(world_x, world_y):
			set_cell(world_x, world_y, 1)  # 用 1 表示 I 方块
	
	print("测试：在棋盘中央放置了一个 I 方块")
	print_grid()

# ====== 新增：游戏控制函数 ======

# 开始新游戏
func start_new_game() -> void:
	clear_board()
	spawn_tetromino()
	print("新游戏开始")

# 运行一个游戏循环（用于测试）
func run_test_cycle(steps: int = 5) -> void:
	print("=== 开始测试游戏循环 ===")
	for i in range(steps):
		print("步骤 %d:" % (i + 1))
		if not tick_down():
			print("方块已锁定，生成新方块")
		print_grid()
	print("=== 测试结束 ===")