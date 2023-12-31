module app

import core

fn render_grid(state &core.State) {
	if state.render_grid.len == 0 {
		state.update_render_grid()
	}
	// state.debug()
	for _, grid in state.render_grid {
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
