module app

import core

fn window_hook(ncode int, wparam C.WPARAM, hwnd C.HWND, state &core.State) C.HHOOK {
	match int(wparam) {
		C.EVENT_SYSTEM_MINIMIZESTART {
			state.inactivate_window(hwnd)
			state.update_render_grid()
			render_grid(state)
		}
		C.EVENT_SYSTEM_MINIMIZEEND {
			state.activate_window(hwnd)
			state.update_render_grid()
			render_grid(state)
		}
		C.EVENT_SYSTEM_MOVESIZESTART {
			rect := C.RECT{}
			C.GetWindowRect(hwnd, &rect)
			state.start_window_resizing(hwnd, rect)
			// render_grid(state)
		}
		C.EVENT_SYSTEM_MOVESIZEEND {
			rect := C.RECT{}
			C.GetWindowRect(hwnd, &rect)
			state.end_window_resizing(hwnd, rect)
			render_grid(state)
		}
		else {}
	}
	return C.CallNextHookEx(unsafe { nil }, ncode, wparam, &hwnd)
}
