module core

pub struct State {
pub mut:
	handler      			C.HWND
	shellhookid  			u32
	windows 					map[string]Window
	monitors          map[string]Monitor
	workareas         []Workarea
	grids 						[]Grid

	grids_ptr 				map[string]int
	workareas_ptr 			map[string]int
	windows_grid 			map[string]string
	grid_workarea 		map[string]string
	window_workarea   map[string]string


	render_grid       map[string]map[string][]int
	current_window    ?C.HWND
	next_window_position WindowPosition = .horizontal
}
pub fn (state &State) get_workarea_by_grid(grid_uuid string) !&Workarea {
	wa_uuid := state.grid_workarea[grid_uuid]
	if grid_uuid != '' {
		return state.get_workarea_by_uuid(wa_uuid)
	} else {
		return error('not found workarea by grid uuid')
	}
}
pub fn  (state &State) get_workarea_by_uuid(uuid string) &Workarea {
	wa_idx := state.workareas_ptr[uuid]
	wa := &state.workareas[wa_idx]
	return wa
}
pub fn (state &State) get_grid_by_hwnd(hwnd string) !&Grid {
	grid_uuid := state.windows_grid[hwnd]
	if grid_uuid != '' {
		return state.get_grid_by_uuid(grid_uuid)
	} else {
		return error('not found grid by hwnd')
	}
}
pub fn  (state &State) get_grid_by_uuid(uuid string) &Grid {
	grid_idx := state.grids_ptr[uuid]
	grid := &state.grids[grid_idx]
	return grid
}
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

pub fn (state &State) get_monitor_by_id(id string) Monitor {
	return state.monitors[id]
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
pub fn (state &State) get_window_by_mouse_position(point C.POINT) !C.HWND {
	for _, wa in state.workareas {
		grid := state.get_grid_by_uuid(wa.grid_idx)
		finded, hwnd := state.get_window_by_mouse_position_deep_grid(grid, point)
		if finded {
			return unsafe {state.windows[hwnd].ptr}
		}
	}
	return error('not found window')
}
fn (state &State) get_window_by_mouse_position_deep_grid(grid &Grid, point C.POINT) (bool, string) {
	if grid.rect.has_point(point) {
		if grid.all_actives() {
			rect_elem1 :=  grid.get_elem_rect_for1()
			rect_elem2 :=  grid.get_elem_rect_for2()
			if rect_elem1.has_point(point) {
				return state.get_window_by_mouse_position_deep(grid.elem1, point)
			} else if rect_elem2.has_point(point) {
				return state.get_window_by_mouse_position_deep(grid.elem2, point)
			}
		} else {
			if grid.active1 {
				return state.get_window_by_mouse_position_deep(grid.elem1, point)
			}
			else if grid.active2 {
				return state.get_window_by_mouse_position_deep(grid.elem2, point)
			}
		}
	}
	return false, ''
}
fn (state &State) get_window_by_mouse_position_deep(gw GridWindow, point C.POINT) (bool, string ) {
	match gw {
		GridAddress {
			grid := state.get_grid_by_uuid(gw)
			return state.get_window_by_mouse_position_deep_grid(grid, point )
		}
		WindowAddress {
			return true, gw
		}
		None {
			return false, ''
		}
	}
}
pub fn (state &State) remove_window(hwnd string) bool {
	mut state0 := unsafe {&state}
	state0.windows_grid.delete(hwnd)
	state0.windows.delete(hwnd)
	return true
}
pub fn (state &State) replace_workarea(workarea Workarea) &Workarea {
	mut state0 := unsafe {&state}
	state0.workareas[workarea.idx] = workarea
	return &state0.workareas[workarea.idx]
}
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
pub fn (state &State) update_render_grid() {
	mut state0 := unsafe {&state}
	for _, ws in state.workareas {
		mut rets := map[string][]int{}
		if ws.fullscreen.valid {
			rets[ws.fullscreen.hwnd	] = ws.fullscreen.rect
		}else{
			grid := state.get_grid_by_uuid(ws.grid_idx)
			rects0 := grid.get_deep_rects(state) or {
				debug(err.msg())
				return }
			for hwnd, r in rects0 {
				rets[hwnd] = r
			}

		}
		debug('rendered')
		state0.render_grid[ws.uuid] = rets.move()
	}
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

pub fn (state &State) debug() {
	// clear_screen()
	dump(state.workareas)
	for k, g in state.render_grid {
		println('\nworkarea: $k')
		for k0, g0 in g {
			win := unsafe { state.windows[k0] }
			title := win.title.substr_with_check(0,14) or {
				win.title.substr(0,win.title.len)
			}
			s := '{L: ${g0[0]}   T: ${g0[1]}   W: ${g0[2]}   H: ${g0[3]}}'
			println('\t${title} ${s}')
		}
	}
}

