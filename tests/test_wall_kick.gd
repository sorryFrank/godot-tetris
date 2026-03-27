extends SceneTree
## 测试场景 3：旋转踢墙测试
## 输出 JSON 格式的测试结果

const BoardScript = preload("res://board.gd")

var test_results: Array = []

func _init() -> void:
	print("=== 旋转踢墙测试 ===")

func _initialize() -> void:
	run_all_tests()
	output_json_results()
	quit()

func run_all_tests() -> void:
	test_t_piece_left_wall_rotation()
	test_i_piece_right_wall_rotation()
	test_no_wall_penetration()

# ====== 测试用例 1: T 型方块靠左墙顺时针旋转 ======
func test_t_piece_left_wall_rotation() -> void:
	var test_name = "test_t_piece_left_wall_rotation"
	var passed = true
	var error_message = ""
	
	var board = BoardScript.new()
	board.initialize_grid()
	
	# 设置 T 方块
	board.current_type = "T"
	board.current_shape = board.get_tetromino_shape("T")
	
	# T 方块初始形状：[(0,0), (-1,1), (0,1), (1,1)]
	# 这是一个倒 T 形状，轴心在 (0,0)
	
	# 靠左墙放置
	# 如果 position 是 (1, 5)，则方块实际占据：
	# - (0+1, 0+5) = (1, 5) - 轴心
	# - (-1+1, 1+5) = (0, 6) - 左下
	# - (0+1, 1+5) = (1, 6) - 中下
	# - (1+1, 1+5) = (2, 6) - 右下
	board.current_pos = Vector2(1, 5)
	
	# 记录旋转前位置
	var pos_before = Vector2(board.current_pos.x, board.current_pos.y)
	
	# 顺时针旋转
	var rotate_result = board.rotate_piece()
	
	# T 方块旋转后的形状应该是：[(0,0), (-1,-1), (-1,0), (-1,1)]
	# 但如果靠左墙，旋转可能会失败（取决于是否有踢墙机制）
	
	# 检查旋转后是否越界
	var is_valid_after_rotation = true
	for block_pos in board.current_shape:
		var world_x = board.current_pos.x + block_pos.x
		if world_x < 0 or world_x >= board.BOARD_WIDTH:
			is_valid_after_rotation = false
			break
	
	if not is_valid_after_rotation:
		passed = false
		error_message = "旋转后方块越界（穿墙）"
	
	# 记录结果
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"pos_before": {"x": pos_before.x, "y": pos_before.y},
			"pos_after": {"x": board.current_pos.x, "y": board.current_pos.y},
			"rotate_result": rotate_result,
			"valid_after_rotation": is_valid_after_rotation
		}
	})

# ====== 测试用例 2: I 型方块靠右墙逆时针旋转 ======
func test_i_piece_right_wall_rotation() -> void:
	var test_name = "test_i_piece_right_wall_rotation"
	var passed = true
	var error_message = ""
	
	var board = BoardScript.new()
	board.initialize_grid()
	
	# 设置 I 方块
	board.current_type = "I"
	board.current_shape = board.get_tetromino_shape("I")
	
	# I 方块初始形状：[(-1,0), (0,0), (1,0), (2,0)]
	# 这是一个水平 I 形状，轴心在 (0,0)
	
	# 靠右墙放置
	# 如果 position 是 (7, 5)，则方块实际占据：
	# - (-1+7, 0+5) = (6, 5)
	# - (0+7, 0+5) = (7, 5)
	# - (1+7, 0+5) = (8, 5)
	# - (2+7, 0+5) = (9, 5) - 右边缘
	board.current_pos = Vector2(7, 5)
	
	# 记录旋转前位置
	var pos_before = Vector2(board.current_pos.x, board.current_pos.y)
	
	# 尝试旋转（I 方块顺时针旋转会变成垂直）
	var rotate_result = board.rotate_piece()
	
	# I 方块旋转后的形状应该是：[(0,-1), (0,0), (0,1), (0,2)]
	# 但如果没有踢墙机制，可能会失败
	
	# 检查旋转后是否越界
	var is_valid_after_rotation = true
	for block_pos in board.current_shape:
		var world_x = board.current_pos.x + block_pos.x
		var world_y = board.current_pos.y + block_pos.y
		if world_x < 0 or world_x >= board.BOARD_WIDTH or world_y < 0 or world_y >= board.BOARD_HEIGHT:
			is_valid_after_rotation = false
			break
	
	if not is_valid_after_rotation:
		passed = false
		error_message = "旋转后方块越界（穿墙）"
	
	# 记录结果
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"pos_before": {"x": pos_before.x, "y": pos_before.y},
			"pos_after": {"x": board.current_pos.x, "y": board.current_pos.y},
			"rotate_result": rotate_result,
			"valid_after_rotation": is_valid_after_rotation
		}
	})

# ====== 测试用例 3: 验证旋转不会穿墙 ======
func test_no_wall_penetration() -> void:
	var test_name = "test_no_wall_penetration"
	var passed = true
	var error_message = ""
	
	var board = BoardScript.new()
	board.initialize_grid()
	
	# 测试所有方块类型在极端位置的旋转
	var block_types = ["I", "J", "L", "T", "S", "Z"]
	var violations = []
	
	for block_type in block_types:
		board.current_type = block_type
		board.current_shape = board.get_tetromino_shape(block_type)
		
		# 找到靠左墙的最小有效 x 位置
		var left_x = find_min_valid_x(board, block_type)
		board.current_pos = Vector2(left_x, 5)
		
		# 确保初始位置有效
		if not board.is_valid_position(board.current_pos, board.current_shape):
			violations.append("%s 初始位置 (%d, 5) 无效" % [block_type, left_x])
			continue
		
		board.rotate_piece()
		
		# 检查是否越界
		for block_pos in board.current_shape:
			var world_x = int(board.current_pos.x + block_pos.x)
			if world_x < 0:
				violations.append("%s 靠左墙旋转后 x=%d < 0" % [block_type, world_x])
				break
		
		# 找到靠右墙的最大有效 x 位置
		board.current_type = block_type
		board.current_shape = board.get_tetromino_shape(block_type)
		var right_x = find_max_valid_x(board, block_type)
		board.current_pos = Vector2(right_x, 5)
		
		# 确保初始位置有效
		if not board.is_valid_position(board.current_pos, board.current_shape):
			violations.append("%s 初始位置 (%d, 5) 无效" % [block_type, right_x])
			continue
		
		board.rotate_piece()
		
		# 检查是否越界
		for block_pos in board.current_shape:
			var world_x = int(board.current_pos.x + block_pos.x)
			if world_x >= board.BOARD_WIDTH:
				violations.append("%s 靠右墙旋转后 x=%d >= %d" % [block_type, world_x, board.BOARD_WIDTH])
				break
	
	if violations.size() > 0:
		passed = false
		error_message = "发现 %d 个穿墙违规: %s" % [violations.size(), violations[0]]
	
	# 记录结果
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"tested_types": block_types,
			"violations_count": violations.size()
		}
	})

# ====== 辅助函数 ======
func find_min_valid_x(board: Node, block_type: String) -> int:
	var shape = board.get_tetromino_shape(block_type)
	for x in range(board.BOARD_WIDTH):
		if board.is_valid_position(Vector2(x, 5), shape):
			return x
	return 0

func find_max_valid_x(board: Node, block_type: String) -> int:
	var shape = board.get_tetromino_shape(block_type)
	for x in range(board.BOARD_WIDTH - 1, -1, -1):
		if board.is_valid_position(Vector2(x, 5), shape):
			return x
	return board.BOARD_WIDTH - 1

# ====== 输出 JSON 结果 ======
func output_json_results() -> void:
	var output = {
		"test_suite": "wall_kick",
		"timestamp": Time.get_datetime_string_from_system(),
		"total": test_results.size(),
		"passed": test_results.filter(func(r): return r.passed).size(),
		"failed": test_results.filter(func(r): return not r.passed).size(),
		"results": test_results
	}
	
	var json_string = JSON.stringify(output, "  ")
	
	print("\n" + "=".repeat(50))
	print("TEST RESULTS (JSON)")
	print("=".repeat(50))
	print(json_string)
	print("=".repeat(50))
