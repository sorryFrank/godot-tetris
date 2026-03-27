extends SceneTree
## 测试方块生成和下落功能
## 输出 JSON 格式的测试结果

# 预加载 Board 脚本
const BoardScript = preload("res://board.gd")

var test_results: Array = []

func _init() -> void:
	print("=== 开始测试 ===")

func _initialize() -> void:
	# 运行测试
	run_all_tests()
	
	# 输出 JSON 结果
	output_json_results()
	
	# 退出
	quit()

func run_all_tests() -> void:
	# 测试 1: 方块生成
	test_spawn_tetromino()
	
	# 测试 2: 方块下落
	test_tick_down()

# ====== 测试用例 1: 方块生成 ======
func test_spawn_tetromino() -> void:
	var test_name = "test_spawn_tetromino"
	var passed = true
	var error_message = ""
	
	# 创建 Board 实例（不添加到场景树）
	var board = BoardScript.new()
	
	# 手动初始化（因为 _ready 不会执行）
	board.initialize_grid()
	board.spawn_tetromino()
	
	# 验证方块是否生成
	if board.current_type == "":
		passed = false
		error_message = "current_type 为空，方块未生成"
	elif board.current_shape.size() == 0:
		passed = false
		error_message = "current_shape 为空，方块形状未设置"
	elif board.current_pos == Vector2.ZERO:
		passed = false
		error_message = "current_pos 为 (0,0)，初始位置不正确"
	else:
		# 验证初始位置是否在顶部中央 (x=4)
		if board.current_pos.x != 4:
			passed = false
			error_message = "初始 x 位置应为 4，实际为 %d" % board.current_pos.x
		elif board.current_pos.y != 0:
			passed = false
			error_message = "初始 y 位置应为 0，实际为 %d" % board.current_pos.y
	
	# 验证方块类型是否在有效范围内
	var valid_types = ["I", "J", "L", "O", "S", "T", "Z"]
	if passed and board.current_type not in valid_types:
		passed = false
		error_message = "方块类型 %s 不在有效范围内" % board.current_type
	
	# 记录结果
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"type": board.current_type,
			"position": {"x": board.current_pos.x, "y": board.current_pos.y},
			"shape_size": board.current_shape.size()
		}
	})

# ====== 测试用例 2: 方块下落 ======
func test_tick_down() -> void:
	var test_name = "test_tick_down"
	var passed = true
	var error_message = ""
	
	# 创建 Board 实例（不添加到场景树）
	var board = BoardScript.new()
	
	# 手动初始化
	board.initialize_grid()
	board.spawn_tetromino()
	
	# 记录初始位置
	var initial_type = board.current_type
	var initial_pos = Vector2(board.current_pos.x, board.current_pos.y)  # 复制值
	
	# 执行下落
	board.tick_down()
	
	# 验证位置是否下移
	var expected_y = initial_pos.y + 1
	
	if board.current_pos.y != expected_y:
		# 检查是否因为触底而被锁定并生成新方块
		# 这种情况下 current_type 可能已改变
		var was_locked = false
		for y in range(board.BOARD_HEIGHT):
			for x in range(board.BOARD_WIDTH):
				if board.grid[y][x] == 1:
					was_locked = true
					break
			if was_locked:
				break
		
		# 如果方块被锁定且生成了新方块，也算通过
		if was_locked and board.current_type != "":
			# 新方块生成成功
			passed = true
		elif not was_locked and board.current_type == initial_type:
			passed = false
			error_message = "方块未下移。期望 y=%d，实际 y=%d" % [expected_y, board.current_pos.y]
	
	# 如果下移成功，验证方块位置确实变化了
	if passed and board.current_pos.y == expected_y:
		# 验证方块没有穿透到无效位置
		if not board.is_valid_position(board.current_pos, board.current_shape):
			passed = false
			error_message = "方块移动到了无效位置"
	
	# 记录结果
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"initial_type": initial_type,
			"initial_pos": {"x": initial_pos.x, "y": initial_pos.y},
			"final_type": board.current_type,
			"final_pos": {"x": board.current_pos.x, "y": board.current_pos.y}
		}
	})

# ====== 输出 JSON 结果 ======
func output_json_results() -> void:
	var output = {
		"test_suite": "basic_drop",
		"timestamp": Time.get_datetime_string_from_system(),
		"total": test_results.size(),
		"passed": test_results.filter(func(r): return r.passed).size(),
		"failed": test_results.filter(func(r): return not r.passed).size(),
		"results": test_results
	}
	
	var json_string = JSON.stringify(output, "  ")
	
	# 分隔线
	print("\n" + "=".repeat(50))
	print("TEST RESULTS (JSON)")
	print("=".repeat(50))
	print(json_string)
	print("=".repeat(50))
