module core

import model

fn window_hook(ncode int, wparam C.WPARAM, hwnd C.HWND, state &model.State) C.HHOOK {
	mut state0 := unsafe { &state }
	match int(wparam) {
		C.EVENT_SYSTEM_MINIMIZESTART {
			state0.inactivate_window(hwnd)
			update_grid(state)
			render_grid(state)
		}
		C.EVENT_SYSTEM_MINIMIZEEND {
			state0.activate_window(hwnd)
			update_grid(state)
			render_grid(state)
		}
		// C.EVENT_SYSTEM_MOVESIZESTART {
		//     monitor := get_monitor_by_win(hwnd, state) or {
		//         println('monitor not found')
		//         return C.CallNextHookEx(unsafe {nil}, ncode, wparam, &hwnd)
		//     }
		//     state0.start_window_resizing(hwnd, monitor)
		//     render_grid(state)
		// }
		C.EVENT_SYSTEM_MOVESIZEEND {
			rect := C.RECT{}
			C.GetWindowRect(hwnd, &rect)
			state0.end_window_resizing(hwnd, rect)
			render_grid(state)
		}
		else {}
	}
	return C.CallNextHookEx(unsafe { nil }, ncode, wparam, &hwnd)
}
