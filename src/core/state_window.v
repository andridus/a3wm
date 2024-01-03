module core

pub fn (state &State) add_window(window Window) {
	mut state0 := unsafe {&state}
	state0.windows[window.ptr.str()] = window
}
pub fn (state &State) update_windows_grid_reference_from_grid(grid &Grid) {
	mut state0 := unsafe {&state}
	elem1 := grid.elem1.get_window_address() or { return }
	state0.windows_grid[elem1] = grid.uuid
	elem2 := grid.elem2.get_window_address() or { return }
	state0.windows_grid[elem2] = grid.uuid
}
pub fn (state &State) add_windows_reference(window Window, grid Grid, workarea &Workarea) {
	mut state0 := unsafe { &state }
	window_ptr := window.ptr.str()
	state0.windows[window_ptr] = window
	state0.window_workarea[window_ptr] = workarea.uuid
	state0.grid_workarea[grid.uuid] = workarea.uuid
	state0.workareas_ptr[workarea.uuid] = workarea.idx
	state0.grids_ptr[grid.uuid] = grid.idx
	state0.windows_grid[window_ptr] = grid.uuid
}
pub fn (state &State) set_next_window_to(pos WindowPosition) {
	mut state0 := *state
	state0.next_window_position = pos
}
pub fn (state &State) remove_window(hwnd string) bool {
	mut state0 := unsafe {&state}
	state0.windows_grid.delete(hwnd)
	state0.windows.delete(hwnd)
	return true
}

pub fn (state &State) activate_window(hwnd C.HWND) {
	mut state0 := unsafe {&state}
	for _, mut wa in state0.workareas {
		for mut w in wa.windows {
			if w.ptr == hwnd {
				w.active = true
			}
		}
	}
}

pub fn (state &State) inactivate_window(hwnd C.HWND) {
	mut state0 := unsafe {&state}
	for _, mut wa in state0.workareas {
		for mut w in wa.windows {
			if w.ptr == hwnd {
				w.active = false
			}
		}
	}
}

pub fn (state &State) swap_window_position(current C.HWND, target C.HWND) {
	if state.grids.len == 0 { return }

	mut gd1 := state.get_grid_by_hwnd(current.str()) or { return }
	mut gd2 := state.get_grid_by_hwnd(target.str()) or { return }
	pos1 := gd1.which_elem_position(current.str())
	pos2 := gd2.which_elem_position(target.str())
	gd1.replace_window(pos1, target)
	gd2.replace_window(pos2, current)
}

pub fn (state &State) start_window_resizing(hwnd C.HWND, rect C.RECT) {
	// grid := state.get_grid_by_hwnd(hwnd.str()) or { return }
	// el := grid.which_elem_position(hwnd.str())
}
pub fn (state &State) end_window_resizing(hwnd C.HWND, rect C.RECT) {
	if state.grids.len == 0 { return }
	grid := state.get_grid_by_hwnd(hwnd.str()) or { return }
	match grid.parse_axis(rect, hwnd, state) {
		.nothing { }
		.drag_axis { }
		.swap_window {
			cursor_point := C.POINT{}
			if C.GetCursorPos(&cursor_point) == 1 {
				ptr := state.get_window_by_mouse_position(cursor_point) or {
					return
				}
				state.swap_window_position(hwnd, ptr)
			}
		}
	}
	state.replace_grid(grid)
	state.update_render_grid()
}


pub fn (state &State) set_window_to_fullscreen() {
	hwnd :=C.GetForegroundWindow()
	if hwnd == 0x0 {
		return
	}
	mut grid := state.get_grid_by_hwnd(hwnd.str()) or { return }
	wa := state.get_workarea_by_grid(grid.uuid) or {return}
	if wa.fullscreen.valid {
		wa.unset_fullscreen()
	} else {
		monitor := state.monitors[wa.monitor]
		wa.set_fullscreen(grid, hwnd.str(), monitor)
	}
	state.replace_workarea(wa)
	state.update_render_grid()
}