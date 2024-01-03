module core

fn (state &State) clear_state() {
		mut state0 := unsafe { state }
		state0.windows.clear()
		state0.monitors.clear()
		state0.workareas.clear()
		state0.grids.clear()
		state0.workareas_ptr.clear()
		state0.windows_grid.clear()
		state0.grid_workarea.clear()
		state0.window_workarea.clear()
		state0.render_grid_arr.clear()
}
pub fn (state &State) setup_state(hwnd C.HWND, monitor_callback fn (C.HMONITOR, C.HDC, &C.RECT, &State) int, window_callback fn (C.HWND, &State) int ) {
	// state.clear_state()
	C.EnumDisplayMonitors(unsafe { nil }, unsafe { nil }, monitor_callback, state)
	C.EnumWindows(window_callback, state)
	state.update_render_grid()
	state.render_grid()
}

pub fn (state &State) update_render_grid() {
	if state.disabled { return }
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
		state0.render_grid_arr[ws.uuid] = rets.move()
	}
}
pub fn (state &State) render_grid() {
	if state.disabled { return }
	// state.debug()
	for _, grid in state.render_grid_arr {
		for hwnd_str, rect in grid {
			ptr := unsafe {state.windows[hwnd_str].ptr}
			left := rect[0]
			top := rect[1]
			width := rect[2]
			height := rect[3]
			C.MoveWindow(ptr, left, top, width, height, 1)
		}
	}
}