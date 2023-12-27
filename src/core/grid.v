module core

import model

fn render_grid(state &model.State) {
	if state.grid.len == 0 {
		update_grid(state)
	}
	for key, grid in state.grid {
		workarea := unsafe { state.workareas[key] }
		for i, w in workarea.windows.get_actives() {
			left := grid[i][0]
			top := grid[i][1]
			width := grid[i][2]
			height := grid[i][3]
			C.MoveWindow(w.ptr, left, top, width, height, 1)
		}
	}
}

fn update_grid(state &model.State) {
	mut state0 := unsafe { &state }
	for _, workarea in state.workareas {
		monitor := state.get_monitor_by_id(workarea.monitor)
		grid := grid_positions(workarea.windows.count_active(), monitor)
		state0.grid[workarea.reference] = grid
	}
}

fn grid_positions(size int, monitor model.Monitor) [][]int {
	total_width := monitor.workarea.width
	total_height := monitor.workarea.height
	initial_left := monitor.workarea.left
	initial_top := monitor.workarea.top
	return match size {
		0 {
			[][]int{}
		}
		1 {
			[
				[initial_left, initial_top, total_width, total_height],
			]
		}
		else {
			width := total_width / size
			mut rets := [][]int{}
			for i := 0; i < size; i++ {
				rets << [initial_left + width * i, 0, width, total_height]
			}
			rets
		}
	}
}
