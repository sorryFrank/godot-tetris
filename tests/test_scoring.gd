extends SceneTree
## 测试场景：计分系统测试
## 输出 JSON 格式的测试结果
## 注意：这些测试预期失败，因为计分功能尚未实现

const BoardScript = preload("res://board.gd")

var test_results: Array = []

func _init() -> void:
	print("=== 计分系统测试 ===")

func _initialize() -> void:
	run_all_tests()
	output_json_results()
	quit()

func run_all_tests() -> void:
	test_score_variable_exists()
	test_level_variable_exists()
	test_combo_variable_exists()
	test_calculate_score_function_exists()
	test_single_line_score()
	test_multi_line_score()
	test_combo_bonus()
	test_level_multiplier()

# ====== 测试用例 0: 变量和函数存在性检查 ======
func test_score_variable_exists() -> void:
	var test_name = "test_score_variable_exists"
	var passed = false
	var error_message = ""
	
	var board = BoardScript.new()
	
	# 检查是否有 score 变量
	if "score" in board:
		passed = true
	else:
		error_message = "board.gd 缺少 score 变量"
	
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"variable_name": "score",
			"exists": passed
		}
	})

func test_level_variable_exists() -> void:
	var test_name = "test_level_variable_exists"
	var passed = false
	var error_message = ""
	
	var board = BoardScript.new()
	
	# 检查是否有 level 变量
	if "level" in board:
		passed = true
	else:
		error_message = "board.gd 缺少 level 变量"
	
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"variable_name": "level",
			"exists": passed
		}
	})

func test_combo_variable_exists() -> void:
	var test_name = "test_combo_variable_exists"
	var passed = false
	var error_message = ""
	
	var board = BoardScript.new()
	
	# 检查是否有 combo 变量
	if "combo" in board:
		passed = true
	else:
		error_message = "board.gd 缺少 combo 变量"
	
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"variable_name": "combo",
			"exists": passed
		}
	})

func test_calculate_score_function_exists() -> void:
	var test_name = "test_calculate_score_function_exists"
	var passed = false
	var error_message = ""
	
	var board = BoardScript.new()
	
	# 检查是否有 calculate_score 函数
	if board.has_method("calculate_score"):
		passed = true
	else:
		error_message = "board.gd 缺少 calculate_score() 函数"
	
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"function_name": "calculate_score",
			"exists": passed
		}
	})

# ====== 测试用例 A: 单行消除计分 ======
func test_single_line_score() -> void:
	var test_name = "test_single_line_score"
	var passed = false
	var error_message = ""
	
	var board = BoardScript.new()
	board.initialize_grid()
	
	# 初始化状态
	if "score" in board:
		board.score = 0
	if "level" in board:
		board.level = 1
	if "combo" in board:
		board.combo = 0
	
	# 在 y=19 行全部填满（最底层）
	for x in range(board.BOARD_WIDTH):
		board.set_cell(x, 19, 1)
	
	# 调用消行（假设消行后会自动计分）
	var lines_cleared = 0
	if board.has_method("check_and_clear_lines"):
		lines_cleared = board.check_and_clear_lines()
	
	# 检查得分
	var expected_score = 100  # 等级1，消除1行，得分 = 100 × 1.1 = 110
	# 注意：根据计分规则，等级1加成是 (1 + 1 × 0.1) = 1.1
	# 但测试要求说"断言：得分 = 100"，可能是等级加成从0开始？
	# 重新理解：等级=1时，加成系数 = (1 + 1 × 0.1) = 1.1
	# 但任务说"新游戏，等级=1，消除1行，断言：得分=100"
	# 可能是等级从0开始计数？或者等级加成不包含在基础测试？
	# 暂时按任务要求，预期得分=100（可能是基础分）
	
	if "score" in board:
		var actual_score = board.score
		if actual_score == 100:
			passed = true
		else:
			error_message = "消除1行后得分应为 100，实际为 %d" % actual_score
	else:
		error_message = "score 变量不存在，无法验证计分"
	
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"lines_cleared": lines_cleared,
			"expected_score": 100,
			"actual_score": board.get("score") if "score" in board else null
		}
	})

# ====== 测试用例 B: 多行消除计分 ======
func test_multi_line_score() -> void:
	var test_name = "test_multi_line_score"
	var passed = false
	var error_message = ""
	
	var board = BoardScript.new()
	board.initialize_grid()
	
	# 初始化状态
	if "score" in board:
		board.score = 0
	if "level" in board:
		board.level = 1
	if "combo" in board:
		board.combo = 0
	
	var total_expected = 0
	var test_passed = true
	var details = {}
	
	# === 消除2行 ===
	for x in range(board.BOARD_WIDTH):
		board.set_cell(x, 18, 1)
		board.set_cell(x, 19, 1)
	
	var lines_2 = 0
	if board.has_method("check_and_clear_lines"):
		lines_2 = board.check_and_clear_lines()
	
	total_expected += 300  # 消除2行 = 300分
	var score_after_2 = board.get("score") if "score" in board else null
	
	if score_after_2 == null:
		error_message = "score 变量不存在"
		test_passed = false
	elif score_after_2 != total_expected:
		error_message = "消除2行后得分应为 %d，实际为 %d" % [total_expected, score_after_2]
		test_passed = false
	
	details["after_2_lines"] = {
		"expected": total_expected,
		"actual": score_after_2,
		"lines_cleared": lines_2
	}
	
	# === 消除3行 ===
	if test_passed:
		for x in range(board.BOARD_WIDTH):
			board.set_cell(x, 17, 1)
			board.set_cell(x, 18, 1)
			board.set_cell(x, 19, 1)
		
		var lines_3 = 0
		if board.has_method("check_and_clear_lines"):
			lines_3 = board.check_and_clear_lines()
		
		# 消除3行 = 500分 + 50连击奖励（combo从1变为2）
		total_expected += 500 + 50  # 含连击奖励
		var score_after_3 = board.get("score") if "score" in board else null
		
		if score_after_3 != total_expected:
			error_message = "再消除3行后总得分应为 %d，实际为 %d" % [total_expected, score_after_3]
			test_passed = false
		
		details["after_3_lines"] = {
			"expected": total_expected,
			"actual": score_after_3,
			"lines_cleared": lines_3
		}
	
	# === 消除4行（Tetris）===
	if test_passed:
		for x in range(board.BOARD_WIDTH):
			board.set_cell(x, 16, 1)
			board.set_cell(x, 17, 1)
			board.set_cell(x, 18, 1)
			board.set_cell(x, 19, 1)
		
		var lines_4 = 0
		if board.has_method("check_and_clear_lines"):
			lines_4 = board.check_and_clear_lines()
		
		# 消除4行 = 800分 + 100连击奖励（combo从2变为3）
		total_expected += 800 + 100  # 含连击奖励
		var score_after_4 = board.get("score") if "score" in board else null
		
		if score_after_4 != total_expected:
			error_message = "再消除4行后总得分应为 %d，实际为 %d" % [total_expected, score_after_4]
			test_passed = false
		
		details["after_4_lines"] = {
			"expected": total_expected,
			"actual": score_after_4,
			"lines_cleared": lines_4
		}
	
	passed = test_passed
	
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": details
	})

# ====== 测试用例 C: 连击奖励 ======
func test_combo_bonus() -> void:
	var test_name = "test_combo_bonus"
	var passed = false
	var error_message = ""
	
	var board = BoardScript.new()
	board.initialize_grid()
	
	# 初始化状态
	if "score" in board:
		board.score = 0
	if "level" in board:
		board.level = 1
	if "combo" in board:
		board.combo = 0
	
	var details = {}
	
	# === 第一次消除（无连击）===
	for x in range(board.BOARD_WIDTH):
		board.set_cell(x, 19, 1)
	
	var lines_1 = 0
	if board.has_method("check_and_clear_lines"):
		lines_1 = board.check_and_clear_lines()
	
	var score_after_1st = board.get("score") if "score" in board else null
	var expected_after_1st = 100  # 消除1行 = 100分，无连击奖励
	
	details["first_clear"] = {
		"expected": expected_after_1st,
		"actual": score_after_1st,
		"lines_cleared": lines_1,
		"combo": board.get("combo") if "combo" in board else null
	}
	
	# === 第二次消除（连击=2，连击分=1×50=50）===
	# 需要等待一小段时间后再次消除才触发连击
	# 但在测试中我们模拟连续消除
	for x in range(board.BOARD_WIDTH):
		board.set_cell(x, 19, 1)
	
	var lines_2 = 0
	if board.has_method("check_and_clear_lines"):
		lines_2 = board.check_and_clear_lines()
	
	# 总分 = 第一次100 + 第二次(100基础 + 50连击) = 250
	var expected_total = 250
	var score_after_2nd = board.get("score") if "score" in board else null
	var combo_after_2nd = board.get("combo") if "combo" in board else null
	
	details["second_clear"] = {
		"expected_total": expected_total,
		"actual": score_after_2nd,
		"lines_cleared": lines_2,
		"combo": combo_after_2nd
	}
	
	if score_after_2nd == null:
		error_message = "score 变量不存在"
	elif score_after_2nd == expected_total:
		passed = true
	else:
		error_message = "两次连续消除后总得分应为 %d（含连击奖励），实际为 %d" % [expected_total, score_after_2nd]
	
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": details
	})

# ====== 测试用例 D: 等级加成 ======
func test_level_multiplier() -> void:
	var test_name = "test_level_multiplier"
	var passed = false
	var error_message = ""
	
	var board = BoardScript.new()
	board.initialize_grid()
	
	# 初始化状态
	if "score" in board:
		board.score = 0
	if "level" in board:
		board.level = 2  # 设置等级为2
	else:
		error_message = "level 变量不存在，无法设置等级"
		test_results.append({
			"name": test_name,
			"passed": false,
			"error": error_message,
			"details": {}
		})
		return
	
	if "combo" in board:
		board.combo = 0
	
	# 在 y=19 行全部填满
	for x in range(board.BOARD_WIDTH):
		board.set_cell(x, 19, 1)
	
	# 调用消行
	var lines_cleared = 0
	if board.has_method("check_and_clear_lines"):
		lines_cleared = board.check_and_clear_lines()
	
	# 等级2加成：1.0 + (2-1) × 0.1 = 1.1
	# 最终得分 = 100 × 1.1 = 110
	var expected_score = 110
	var actual_score = board.get("score") if "score" in board else null
	
	if actual_score == null:
		error_message = "score 变量不存在"
	elif actual_score == expected_score:
		passed = true
	else:
		error_message = "等级2消除1行后得分应为 %d（含等级加成），实际为 %d" % [expected_score, actual_score]
	
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"level": 2,
			"lines_cleared": lines_cleared,
			"expected_score": expected_score,
			"actual_score": actual_score,
			"multiplier": 1.1
		}
	})

# ====== 输出 JSON 结果 ======
func output_json_results() -> void:
	var output = {
		"test_suite": "scoring",
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
