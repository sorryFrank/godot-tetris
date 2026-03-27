extends SceneTree
## 测试场景 1：边界限制测试
## 输出 JSON 格式的测试结果

const BoardScript = preload("res://board.gd")

var test_results: Array = []

func _init() -> void:
	print("=== 边界限制测试 ===")

func _initialize() -> void:
	run_all_tests()
	output_json_results()
	quit()

func run_all_tests() -> void:
	test_left_boundary()
	test_right_boundary()
	test_bottom_boundary()

# ====== 测试用例 A: 左边界限制 ======
func test_left_boundary() -> void:
	var test_name = "test_left_boundary"
	var passed = true
	var error_message = ""
	
	var board = BoardScript.new()
	board.initialize_grid()
	
	# 设置 O 方块（2x2，便于测试）
	board.current_type = "O"
	board.current_shape = board.get_tetromino_shape("O")
	
	# 放置在左边缘 (x=0)
	board.current_pos = Vector2(0, 5)
	
	# 记录初始位置
	var initial_pos = Vector2(board.current_pos.x, board.current_pos.y)
	
	# 尝试向左移动
	var move_result = board.move(-1, 0)
	
	# 断言：移动失败，位置保持不变
	if move_result == true:
		passed = false
		error_message = "左边界应该阻止移动，但 move() 返回 true"
	elif board.current_pos.x != initial_pos.x:
		passed = false
		error_message = "x 坐标应保持为 %d，实际为 %d" % [initial_pos.x, board.current_pos.x]
	
	# 记录结果
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"initial_pos": {"x": initial_pos.x, "y": initial_pos.y},
			"final_pos": {"x": board.current_pos.x, "y": board.current_pos.y},
			"move_result": move_result
		}
	})

# ====== 测试用例 B: 右边界限制 ======
func test_right_boundary() -> void:
	var test_name = "test_right_boundary"
	var passed = true
	var error_message = ""
	
	var board = BoardScript.new()
	board.initialize_grid()
	
	# 使用 O 方块（宽度为 2）
	board.current_type = "O"
	board.current_shape = board.get_tetromino_shape("O")
	
	# O 方块右边缘极限位置：x=8（因为 O 方块宽度为 2，占据 x=8 和 x=9）
	board.current_pos = Vector2(8, 5)
	
	# 记录初始位置
	var initial_pos = Vector2(board.current_pos.x, board.current_pos.y)
	
	# 尝试向右移动
	var move_result = board.move(1, 0)
	
	# 断言：移动失败，位置保持不变
	if move_result == true:
		passed = false
		error_message = "右边界应该阻止移动，但 move() 返回 true"
	elif board.current_pos.x != initial_pos.x:
		passed = false
		error_message = "x 坐标应保持为 %d，实际为 %d" % [initial_pos.x, board.current_pos.x]
	
	# 记录结果
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"block_type": "O",
			"initial_pos": {"x": initial_pos.x, "y": initial_pos.y},
			"final_pos": {"x": board.current_pos.x, "y": board.current_pos.y},
			"move_result": move_result
		}
	})

# ====== 测试用例 C: 底部边界限制 ======
func test_bottom_boundary() -> void:
	var test_name = "test_bottom_boundary"
	var passed = true
	var error_message = ""
	
	var board = BoardScript.new()
	board.initialize_grid()
	
	# 使用 O 方块
	board.current_type = "O"
	board.current_shape = board.get_tetromino_shape("O")
	
	# 底部边缘：y=19（O 方块高度为 2，占据 y=18 和 y=19）
	# 所以极限位置是 y=18
	board.current_pos = Vector2(4, 18)
	
	# 记录初始位置
	var initial_pos = Vector2(board.current_pos.x, board.current_pos.y)
	
	# 尝试向下移动
	var move_result = board.move(0, 1)
	
	# 断言：移动失败，位置保持不变
	if move_result == true:
		passed = false
		error_message = "底部边界应该阻止移动，但 move() 返回 true"
	elif board.current_pos.y != initial_pos.y:
		passed = false
		error_message = "y 坐标应保持为 %d，实际为 %d" % [initial_pos.y, board.current_pos.y]
	
	# 记录结果
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"initial_pos": {"x": initial_pos.x, "y": initial_pos.y},
			"final_pos": {"x": board.current_pos.x, "y": board.current_pos.y},
			"move_result": move_result
		}
	})

# ====== 输出 JSON 结果 ======
func output_json_results() -> void:
	var output = {
		"test_suite": "boundary",
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
