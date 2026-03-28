extends SceneTree
## 测试场景：游戏结束功能测试
## 验证 game_over 状态变量和相关逻辑

const BoardScript = preload("res://board.gd")

var test_results: Array = []

func _init() -> void:
	print("=== 游戏结束功能测试 ===")

func _initialize() -> void:
	run_all_tests()
	output_json_results()
	quit()

func run_all_tests() -> void:
	test_game_over_variable_exists()
	test_game_over_initial_state()
	test_game_over_ui_function_exists()
	test_restart_game_function_exists()
	test_game_over_triggered_on_top_out()

# ====== 测试用例 ======

func test_game_over_variable_exists() -> void:
	var test_name = "test_game_over_variable_exists"
	var passed = false
	var error_message = ""
	
	var board = BoardScript.new()
	
	if "game_over" in board:
		passed = true
	else:
		error_message = "board.gd 缺少 game_over 变量"
	
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message
	})

func test_game_over_initial_state() -> void:
	var test_name = "test_game_over_initial_state"
	var passed = false
	var error_message = ""
	
	var board = BoardScript.new()
	
	if "game_over" in board and board.game_over == false:
		passed = true
	else:
		error_message = "game_over 初始值应为 false"
	
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message
	})

func test_game_over_ui_function_exists() -> void:
	var test_name = "test_game_over_ui_function_exists"
	var passed = false
	var error_message = ""
	
	var board = BoardScript.new()
	
	if board.has_method("draw_game_over_ui"):
		passed = true
	else:
		error_message = "board.gd 缺少 draw_game_over_ui 函数"
	
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message
	})

func test_restart_game_function_exists() -> void:
	var test_name = "test_restart_game_function_exists"
	var passed = false
	var error_message = ""
	
	var board = BoardScript.new()
	
	if board.has_method("restart_game"):
		passed = true
	else:
		error_message = "board.gd 缺少 restart_game 函数"
	
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message
	})

func test_game_over_triggered_on_top_out() -> void:
	var test_name = "test_game_over_triggered_on_top_out"
	var passed = false
	var error_message = ""
	
	var board = BoardScript.new()
	board._ready()  # 初始化棋盘
	
	# 填满顶部几行，模拟方块堆到顶
	for x in range(10):
		board.grid[0][x] = 1
		board.grid[1][x] = 1
	
	# 强制生成新方块（应该触发 game_over）
	board.current_type = ""
	board.current_shape = []
	board.spawn_tetromino()
	
	if board.game_over == true:
		passed = true
	else:
		error_message = "顶部堆满时应触发 game_over = true"
	
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message
	})

# ====== 输出结果 ======

func output_json_results() -> void:
	var passed_count = 0
	for result in test_results:
		if result.passed:
			passed_count += 1
	
	var output = {
		"test_suite": "game_over",
		"timestamp": Time.get_datetime_string_from_system(),
		"total": test_results.size(),
		"passed": passed_count,
		"failed": test_results.size() - passed_count,
		"results": test_results
	}
	
	print("\n" + "=".repeat(50))
	print(JSON.stringify(output, "  "))
	print("=".repeat(50))
	
	if passed_count == test_results.size():
		print("✅ 所有测试通过!")
	else:
		print("❌ 有 %d 个测试失败" % (test_results.size() - passed_count))
