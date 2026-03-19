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

# 初始化函数
func _ready() -> void:
	initialize_grid()
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

# 打印棋盘网格（用于调试）
func print_grid() -> void:
	print("=== 棋盘网格 ===")
	print("格式说明：0=空，数字=方块类型")
	print("行号从顶部(0)到底部(%d)" % (BOARD_HEIGHT - 1))
	print("列号从左(0)到右(%d)" % (BOARD_WIDTH - 1))
	print("")
	
	for y in range(BOARD_HEIGHT):
		var row_str := "行 %2d: [" % y
		for x in range(BOARD_WIDTH):
			row_str += str(grid[y][x])
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