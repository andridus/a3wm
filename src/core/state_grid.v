module core

pub fn (state &State) replace_grid(grid Grid) &Grid {
	mut state0 := unsafe {&state}
	state0.grids[grid.idx] = grid
	return &state0.grids[grid.idx]
}
pub fn (state &State) add_grid(grid Grid) &Grid {
	mut state0 := unsafe {&state}
	idx := state0.grids.len
	state0.grids << Grid{...grid, idx: idx}
	state0.grids_ptr[grid.uuid] = idx
	return &state0.grids[idx]
}


pub fn (state &State) toggle_grid_direction() {
	// get hwnd by mouse position
	cursor_point := C.POINT{}
	if C.GetCursorPos(&cursor_point) == 1 {
		hwnd := state.get_window_by_mouse_position(cursor_point) or {
			return
		}
		mut grid := state.get_grid_by_hwnd(hwnd.str()) or { return }
		grid.toggle_direction()
		state.replace_grid(grid)
		state.update_render_grid()
	}
}