extends SceneTree
## 测试场景：消行逻辑测试
## 输出 JSON 格式的测试结果

const BoardScript = preload("res://board.gd")

var test_results: Array = []

func _init() -> void:
	print("=== 消行逻辑测试 ===")

func _initialize() -> void:
	run_all_tests()
	output_json_results()
	quit()

func run_all_tests() -> void:
	test_single_line_clear()
	test_floating_block_drop()
	test_multi_line_clear()

# ====== 测试用例 A: 单行消除 ======
func test_single_line_clear() -> void:
	var test_name = "test_single_line_clear"
	var passed = true
	var error_message = ""
	
	var board = BoardScript.new()
	board.initialize_grid()
	
	# 在 y=19 行全部填满（最底层）
	for x in range(board.BOARD_WIDTH):
		board.set_cell(x, 19, 1)
	
	# 验证填充成功
	var filled_count_before = count_filled_in_row(board, 19)
	if filled_count_before != board.BOARD_WIDTH:
		error_message = "预填充失败：y=19 行应有 %d 个格子，实际 %d 个" % [board.BOARD_WIDTH, filled_count_before]
		test_results.append({
			"name": test_name,
			"passed": false,
			"error": error_message,
			"details": {}
		})
		return
	
	# 调用消行检测函数
	var lines_cleared = -1
	var function_exists = true
	
	if board.has_method("check_and_clear_lines"):
		lines_cleared = board.check_and_clear_lines()
	else:
		function_exists = false
		error_message = "check_and_clear_lines() 函数不存在"
		passed = false
	
	# 如果函数存在，验证结果
	if function_exists:
		# 检查 y=19 行是否被清空
		var filled_count_after = count_filled_in_row(board, 19)
		
		if lines_cleared != 1:
			passed = false
			error_message = "返回值应为 1（消除 1 行），实际返回 %d" % lines_cleared
		elif filled_count_after != 0:
			passed = false
			error_message = "y=19 行应被清空，但仍有 %d 个填充格子" % filled_count_after
	
	# 记录结果
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"function_exists": function_exists,
			"filled_before": filled_count_before,
			"filled_after": count_filled_in_row(board, 19) if function_exists else -1,
			"lines_cleared": lines_cleared
		}
	})

# ====== 测试用例 B: 悬空下坠 ======
func test_floating_block_drop() -> void:
	var test_name = "test_floating_block_drop"
	var passed = true
	var error_message = ""
	
	var board = BoardScript.new()
	board.initialize_grid()
	
	# 在 y=19 行全部填满
	for x in range(board.BOARD_WIDTH):
		board.set_cell(x, 19, 1)
	
	# 在 y=18 的位置 (x=5) 放置一个孤立的方块
	board.set_cell(5, 18, 1)
	
	# 验证初始状态
	var filled_y18_before = board.get_cell(5, 18)
	var filled_y19_before = count_filled_in_row(board, 19)
	
	if filled_y18_before != 1:
		error_message = "预填充失败：y=18 位置 (5,18) 应有方块"
		test_results.append({
			"name": test_name,
			"passed": false,
			"error": error_message,
			"details": {}
		})
		return
	
	# 调用消行检测函数
	var lines_cleared = -1
	var function_exists = true
	
	if board.has_method("check_and_clear_lines"):
		lines_cleared = board.check_and_clear_lines()
	else:
		function_exists = false
		error_message = "check_and_clear_lines() 函数不存在"
		passed = false
	
	# 如果函数存在，验证结果
	if function_exists:
		# 检查 y=19 行是否被清空
		var filled_y19_after = count_filled_in_row(board, 19)
		
		# 检查原本 y=18 的孤立方块是否下移到 y=19
		var block_at_y18 = board.get_cell(5, 18)
		var block_at_y19 = board.get_cell(5, 19)
		
		if lines_cleared != 1:
			passed = false
			error_message = "返回值应为 1（消除 1 行），实际返回 %d" % lines_cleared
		elif filled_y19_after != 1:
			passed = false
			error_message = "y=19 行应有 1 个下坠的方块（来自 y=18），实际 %d 个" % filled_y19_after
		elif block_at_y18 != 0:
			passed = false
			error_message = "y=18 位置 (5,18) 应为空（方块已下坠），值为 %d" % block_at_y18
		elif block_at_y19 != 1:
			passed = false
			error_message = "y=19 位置 (5,19) 应有下坠的方块，值为 %d" % block_at_y19
	
	# 记录结果
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"function_exists": function_exists,
			"initial_block_at_y18": filled_y18_before,
			"initial_filled_y19": filled_y19_before,
			"final_block_at_y18": board.get_cell(5, 18) if function_exists else -1,
			"final_block_at_y19": board.get_cell(5, 19) if function_exists else -1,
			"lines_cleared": lines_cleared
		}
	})

# ====== 测试用例 C: 多行消除 ======
func test_multi_line_clear() -> void:
	var test_name = "test_multi_line_clear"
	var passed = true
	var error_message = ""
	
	var board = BoardScript.new()
	board.initialize_grid()
	
	# 在 y=18 和 y=19 行全部填满
	for x in range(board.BOARD_WIDTH):
		board.set_cell(x, 18, 1)
		board.set_cell(x, 19, 1)
	
	# 验证填充成功
	var filled_y18_before = count_filled_in_row(board, 18)
	var filled_y19_before = count_filled_in_row(board, 19)
	
	if filled_y18_before != board.BOARD_WIDTH or filled_y19_before != board.BOARD_WIDTH:
		error_message = "预填充失败：y=18 和 y=19 应各有 %d 个格子" % board.BOARD_WIDTH
		test_results.append({
			"name": test_name,
			"passed": false,
			"error": error_message,
			"details": {}
		})
		return
	
	# 调用消行检测函数
	var lines_cleared = -1
	var function_exists = true
	
	if board.has_method("check_and_clear_lines"):
		lines_cleared = board.check_and_clear_lines()
	else:
		function_exists = false
		error_message = "check_and_clear_lines() 函数不存在"
		passed = false
	
	# 如果函数存在，验证结果
	if function_exists:
		# 检查两行是否都被清空
		var filled_y18_after = count_filled_in_row(board, 18)
		var filled_y19_after = count_filled_in_row(board, 19)
		
		if lines_cleared != 2:
			passed = false
			error_message = "返回值应为 2（消除 2 行），实际返回 %d" % lines_cleared
		elif filled_y18_after != 0 or filled_y19_after != 0:
			passed = false
			error_message = "y=18 和 y=19 行应都被清空，实际 y=18: %d, y=19: %d" % [filled_y18_after, filled_y19_after]
	
	# 记录结果
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"function_exists": function_exists,
			"filled_y18_before": filled_y18_before,
			"filled_y19_before": filled_y19_before,
			"filled_y18_after": count_filled_in_row(board, 18) if function_exists else -1,
			"filled_y19_after": count_filled_in_row(board, 19) if function_exists else -1,
			"lines_cleared": lines_cleared
		}
	})

# ====== 辅助函数 ======
func count_filled_in_row(board: Node, y: int) -> int:
	var count = 0
	for x in range(board.BOARD_WIDTH):
		if board.grid[y][x] != 0:
			count += 1
	return count

# ====== 输出 JSON 结果 ======
func output_json_results() -> void:
	var output = {
		"test_suite": "line_clear",
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
