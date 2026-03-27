extends SceneTree
## 测试场景 2：死方块碰撞与锁定测试
## 输出 JSON 格式的测试结果

const BoardScript = preload("res://board.gd")

var test_results: Array = []

func _init() -> void:
	print("=== 死方块碰撞与锁定测试 ===")

func _initialize() -> void:
	run_all_tests()
	output_json_results()
	quit()

func run_all_tests() -> void:
	test_collision_with_obstacle()
	test_lock_to_grid()

# ====== 测试用例 1: 碰撞检测 ======
func test_collision_with_obstacle() -> void:
	var test_name = "test_collision_with_obstacle"
	var passed = true
	var error_message = ""
	
	var board = BoardScript.new()
	board.initialize_grid()
	
	# 在 y=18 位置放置障碍物（硬编码）
	board.set_cell(4, 18, 1)  # 中间位置放一个障碍物
	board.set_cell(5, 18, 1)
	board.set_cell(6, 18, 1)
	
	# 使用 O 方块
	board.current_type = "O"
	board.current_shape = board.get_tetromino_shape("O")
	
	# 将 O 方块放在障碍物上方三格
	# O 方块形状：[(0,0), (1,0), (0,1), (1,1)]
	# 如果 position 是 (4, 14)，则方块占据 (4,14), (5,14), (4,15), (5,15)
	# 下落到 y=15 后占据 (4,15), (5,15), (4,16), (5,16)
	# 下落到 y=16 后占据 (4,16), (5,16), (4,17), (5,17)
	# 下落到 y=17 后占据 (4,17), (5,17), (4,18), (5,18) - 与障碍物碰撞
	board.current_pos = Vector2(4, 14)
	
	# 记录初始位置
	var initial_pos = Vector2(board.current_pos.x, board.current_pos.y)
	
	# 第一次下落：应该成功（移动到 y=15）
	var move1 = board.move(0, 1)
	
	if not move1:
		passed = false
		error_message = "第一次下落应该成功（从 y=14 到 y=15），但失败了"
	else:
		# 第二次下落：应该成功（移动到 y=16）
		var move2 = board.move(0, 1)
		
		if not move2:
			passed = false
			error_message = "第二次下落应该成功（从 y=15 到 y=16），但失败了"
		else:
			# 第三次下落：应该失败（碰撞障碍物）
			var move3 = board.move(0, 1)
			
			if move3:
				passed = false
				error_message = "第三次下落应该因碰撞而失败，但成功了"
			elif board.current_pos.y != initial_pos.y + 2:
				passed = false
				error_message = "碰撞后 y 坐标应保持为 %d，实际为 %d" % [initial_pos.y + 2, board.current_pos.y]
	
	# 记录结果
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"obstacle_row": 18,
			"obstacle_cells": [[4, 18], [5, 18], [6, 18]],
			"initial_pos": {"x": initial_pos.x, "y": initial_pos.y},
			"final_pos": {"x": board.current_pos.x, "y": board.current_pos.y}
		}
	})

# ====== 测试用例 2: 锁定到网格 ======
func test_lock_to_grid() -> void:
	var test_name = "test_lock_to_grid"
	var passed = true
	var error_message = ""
	
	var board = BoardScript.new()
	board.initialize_grid()
	
	# 在底部放置障碍物（y=19）
	for x in range(board.BOARD_WIDTH):
		board.set_cell(x, 19, 1)
	
	# 使用 I 方块（水平放置）
	board.current_type = "I"
	board.current_shape = board.get_tetromino_shape("I")
	
	# I 方块形状：[(-1,0), (0,0), (1,0), (2,0)]，所有块的 y 偏移都是 0
	# position (5, 17) 时，实际占据 x=4,5,6,7, y=17
	# 下落到 y=18 后，占据 (4,18), (5,18), (6,18), (7,18) - 不会与 y=19 碰撞
	# 下落到 y=19 后，会与障碍物碰撞并锁定
	board.current_pos = Vector2(5, 17)
	
	# 记录初始网格状态（统计非零单元格数量）
	var initial_filled_count = count_filled_cells(board)
	
	# 第一次 tick_down：下落到 y=18
	board.tick_down()
	
	# 第二次 tick_down：尝试下落到 y=19，碰撞并锁定
	board.tick_down()
	
	# 检查方块是否被锁定
	var final_filled_count = count_filled_cells(board)
	
	# 期望：网格中增加 4 个填充单元格（I 方块有 4 个块）
	var expected_added = 4
	var actual_added = final_filled_count - initial_filled_count
	
	if actual_added != expected_added:
		passed = false
		error_message = "应增加 %d 个填充单元格，实际增加了 %d 个" % [expected_added, actual_added]
	
	# 记录结果
	test_results.append({
		"name": test_name,
		"passed": passed,
		"error": error_message,
		"details": {
			"initial_filled_count": initial_filled_count,
			"final_filled_count": final_filled_count,
			"cells_added": actual_added
		}
	})

# ====== 辅助函数 ======
func count_filled_cells(board: Node) -> int:
	var count = 0
	for y in range(board.BOARD_HEIGHT):
		for x in range(board.BOARD_WIDTH):
			if board.grid[y][x] != 0:
				count += 1
	return count

# ====== 输出 JSON 结果 ======
func output_json_results() -> void:
	var output = {
		"test_suite": "collision_lock",
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
