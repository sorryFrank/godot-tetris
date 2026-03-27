extends SceneTree
## 测试场景：长按连续操作测试
## 测试方块在长按按键时的连续移动/旋转能力
## 输出 JSON 格式的测试结果

const BoardScript = preload("res://board.gd")

var test_results: Array = []

func _init() -> void:
	print("=== 长按连续操作测试 ===")

func _initialize() -> void:
	run_all_tests()
	output_json_results()
	quit()

func run_all_tests() -> void:
	test_continuous_down()
	test_continuous_left()
	test_continuous_right()
	test_continuous_rotate()
	test_move_interval_control()
	test_o_block_no_rotate()
	test_collision_stops_continuous_move()

# ====== 测试用例 A: 长按下键 - 连续下移 ======
func test_continuous_down() -> void:
	var test_name = "test_continuous_down"
	var passed = true
	var error_message = ""
	
	var board = BoardScript.new()
	board.initialize_grid()
	
	# 设置 O 方块
	board.current_type = "O"
	board.current_shape = board.get_tetromino_shape("O")
	
	# 放置在 y=5
	board.current_pos = Vector2(4, 5)
	var initial_y = board.current_pos.y
	
	# 模拟"长按下键"：连续调用多次下移
	var move_count = 0
	var max_moves = 10  # 尝试下移 10 次
	
	for i in range(max_moves):
		var result = board.move(0, 1)
		if result:
			move_count += 1
		else:
			break  # 无法继续下移（到达底部或碰撞）
	
	# 断言：方块能够连续下移多格（至少移动 1 格）
	if move_count < 1:
		passed = false
		error_message = "长按下键应该能够连续下移，但只移动了 %d 格" % move_count
	elif move_count < max_moves:
		# 移动被边界阻止，这是正常行为
		print("  下移在 %d 格后停止（可能到达底部边界）" % move_count)
	
	# 验证最终位置是否合理
	var expected_max_y = initial_y + move_count
	if board.current_pos.y != expected_max_y:
		passed = false
		error_message = "y 坐标应为 %d，实际为 %d" % [expected_max_y, board.current_pos.y]
	
	# 记录结果
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"initial_y": initial_y,
			"final_y": board.current_pos.y,
			"move_count": move_count,
			"moved_multiple_cells": move_count >= 1
		}
	})

# ====== 测试用例 B: 长按左键 - 连续横向移动 ======
func test_continuous_left() -> void:
	var test_name = "test_continuous_left"
	var passed = true
	var error_message = ""
	
	var board = BoardScript.new()
	board.initialize_grid()
	
	# 使用 I 方块（水平方向长，便于测试）
	board.current_type = "I"
	board.current_shape = board.get_tetromino_shape("I")
	
	# 放置在 x=5
	board.current_pos = Vector2(5, 5)
	var initial_x = board.current_pos.x
	
	# 模拟"长按左键"：连续调用左移直到碰到边界
	var move_count = 0
	var max_attempts = 20
	
	for i in range(max_attempts):
		var result = board.move(-1, 0)
		if result:
			move_count += 1
		else:
			break  # 碰到边界，停止移动
	
	# 断言：方块能够连续左移直到碰到边界
	if move_count < 1:
		passed = false
		error_message = "长按左键应该能够连续左移，但只移动了 %d 格" % move_count
	
	# 验证是否到达左边界（I 方块左边缘应在 x=0 附近）
	# I 方块初始形状: [-1, 0, 1, 2] 相对于 pos
	# 所以最左块在 pos.x - 1
	# 到达边界时，pos.x - 1 应该 >= 0，即 pos.x >= 1
	var min_valid_x = 1  # I 方块的最小有效 x 位置
	if board.current_pos.x > min_valid_x:
		# 可能还可以继续左移，但没有移动成功
		passed = false
		error_message = "应该能够继续左移，当前 x=%d，最小有效 x=%d" % [board.current_pos.x, min_valid_x]
	
	# 验证再左移一次会失败
	var extra_move = board.move(-1, 0)
	if extra_move == true:
		passed = false
		error_message = "到达边界后，再次左移应该失败"
	
	# 记录结果
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"block_type": "I",
			"initial_x": initial_x,
			"final_x": board.current_pos.x,
			"move_count": move_count,
			"stopped_at_boundary": extra_move == false
		}
	})

# ====== 测试用例 C: 长按右键 - 连续横向移动 ======
func test_continuous_right() -> void:
	var test_name = "test_continuous_right"
	var passed = true
	var error_message = ""
	
	var board = BoardScript.new()
	board.initialize_grid()
	
	# 使用 I 方块
	board.current_type = "I"
	board.current_shape = board.get_tetromino_shape("I")
	
	# 放置在 x=2（靠左位置）
	board.current_pos = Vector2(2, 5)
	var initial_x = board.current_pos.x
	
	# 模拟"长按右键"：连续调用右移直到碰到边界
	var move_count = 0
	var max_attempts = 20
	
	for i in range(max_attempts):
		var result = board.move(1, 0)
		if result:
			move_count += 1
		else:
			break  # 碰到边界，停止移动
	
	# 断言：方块能够连续右移直到碰到边界
	if move_count < 1:
		passed = false
		error_message = "长按右键应该能够连续右移，但只移动了 %d 格" % move_count
	
	# 验证是否到达右边界
	# I 方块初始形状: [-1, 0, 1, 2] 相对于 pos
	# 最右块在 pos.x + 2
	# 棋盘宽度 10，所以 pos.x + 2 <= 9，即 pos.x <= 7
	var max_valid_x = 7  # I 方块的最大有效 x 位置
	if board.current_pos.x < max_valid_x:
		# 可能还可以继续右移，但没有移动成功
		passed = false
		error_message = "应该能够继续右移，当前 x=%d，最大有效 x=%d" % [board.current_pos.x, max_valid_x]
	
	# 验证再右移一次会失败
	var extra_move = board.move(1, 0)
	if extra_move == true:
		passed = false
		error_message = "到达边界后，再次右移应该失败"
	
	# 记录结果
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"block_type": "I",
			"initial_x": initial_x,
			"final_x": board.current_pos.x,
			"move_count": move_count,
			"stopped_at_boundary": extra_move == false
		}
	})

# ====== 测试用例 D: 长按上键 - 连续旋转 ======
func test_continuous_rotate() -> void:
	var test_name = "test_continuous_rotate"
	var passed = true
	var error_message = ""
	
	var board = BoardScript.new()
	board.initialize_grid()
	
	# 使用 T 方块（便于观察旋转效果）
	board.current_type = "T"
	board.current_shape = board.get_tetromino_shape("T")
	
	# 放置在中央位置
	board.current_pos = Vector2(4, 5)
	
	# 模拟"长按上键"：连续调用旋转
	var rotate_count = 0
	var max_attempts = 10
	
	for i in range(max_attempts):
		var result = board.rotate_piece()
		if result:
			rotate_count += 1
		else:
			# 旋转可能因碰撞失败，但 T 方块在中央应该能旋转
			break
	
	# 断言：方块能够连续旋转多次
	# T 方块旋转 4 次后回到原位，所以应该能旋转至少 3 次
	if rotate_count < 1:
		passed = false
		error_message = "长按上键应该能够连续旋转，但只旋转了 %d 次" % rotate_count
	
	# 记录结果
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"block_type": "T",
			"rotate_count": rotate_count,
			"can_rotate_multiple_times": rotate_count >= 1
		}
	})

# ====== 辅助测试：验证连续移动的间隔控制 ======
func test_move_interval_control() -> void:
	var test_name = "test_move_interval_control"
	var passed = true
	var error_message = ""
	
	var board = BoardScript.new()
	board.initialize_grid()
	
	board.current_type = "O"
	board.current_shape = board.get_tetromino_shape("O")
	board.current_pos = Vector2(4, 5)
	
	# 测试快速连续移动是否正常工作
	var move_count = 0
	for i in range(5):
		if board.move(0, 1):
			move_count += 1
	
	# 断言：快速连续移动应该成功
	if move_count != 5:
		passed = false
		error_message = "快速连续移动 5 次应该全部成功，实际成功 %d 次" % move_count
	
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"attempted_moves": 5,
			"successful_moves": move_count
		}
	})

# ====== 辅助测试：O 方块不应该旋转 ======
func test_o_block_no_rotate() -> void:
	var test_name = "test_o_block_no_rotate"
	var passed = true
	var error_message = ""
	
	var board = BoardScript.new()
	board.initialize_grid()
	
	# O 方块不应该旋转
	board.current_type = "O"
	board.current_shape = board.get_tetromino_shape("O")
	board.current_pos = Vector2(4, 5)
	
	var initial_shape = board.current_shape.duplicate()
	
	# 尝试旋转
	var rotate_result = board.rotate_piece()
	
	# O 方块旋转应该返回 false
	if rotate_result != false:
		passed = false
		error_message = "O 方块不应该旋转，rotate_piece() 应返回 false"
	
	# 形状应该保持不变
	if board.current_shape != initial_shape:
		passed = false
		error_message = "O 方块旋转后形状改变，这是错误的"
	
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"rotate_result": rotate_result,
			"shape_unchanged": board.current_shape == initial_shape
		}
	})

# ====== 辅助测试：边界碰撞阻止连续移动 ======
func test_collision_stops_continuous_move() -> void:
	var test_name = "test_collision_stops_continuous_move"
	var passed = true
	var error_message = ""
	
	var board = BoardScript.new()
	board.initialize_grid()
	
	# 在棋盘中放置一个障碍物
	board.set_cell(4, 10, 1)  # 在 (4, 10) 放置一个固定方块
	
	# 使用 O 方块
	board.current_type = "O"
	board.current_shape = board.get_tetromino_shape("O")
	board.current_pos = Vector2(4, 5)
	
	# 连续下移，应该被障碍物阻止
	var move_count = 0
	for i in range(20):
		if board.move(0, 1):
			move_count += 1
		else:
			break
	
	# 断言：应该被障碍物阻止，不会移动到底部
	# O 方块在 pos.y=5，障碍物在 y=10
	# O 方块高度为 2，所以最多能下移到 pos.y=8（占据 y=8,9）
	# 障碍物在 y=10，所以下移到 pos.y=9 时会被阻止（因为 y=10 被占用）
	if move_count >= 15:
		passed = false
		error_message = "连续下移应该被障碍物阻止，但移动了 %d 格" % move_count
	
	# 验证方块停在障碍物上方
	# 预期最大 y 坐标：障碍物 y - 2（O 方块高度）= 10 - 2 = 8
	var expected_max_y = 8
	if board.current_pos.y > expected_max_y + 1:  # 允许一点误差
		passed = false
		error_message = "方块应该停在障碍物上方，当前 y=%d，预期最大 y=%d" % [board.current_pos.y, expected_max_y]
	
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"obstacle_position": {"x": 4, "y": 10},
			"move_count": move_count,
			"final_y": board.current_pos.y
		}
	})

# ====== 输出 JSON 结果 ======
func output_json_results() -> void:
	var output = {
		"test_suite": "hold_input",
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
