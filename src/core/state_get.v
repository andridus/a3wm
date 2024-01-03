module core

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

pub fn (state &State) get_monitor_by_id(id string) Monitor {
	return state.monitors[id]
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