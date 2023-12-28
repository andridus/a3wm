module app

import winapi

fn window_proc(hwnd C.HWND, umsg int, wparam C.WPARAM, lparam C.HWND) C.LRESULT {
	mut state := C.GetWindowLongPtr(hwnd, C.GWLP_USERDATA)
	match umsg {
		C.WM_CREATE {}
		C.WM_DESTROY {
			C.PostQuitMessage(0)
			return C.LRESULT(0)
		}
		C.WM_PAINT {
			ps := winapi.PaintStruct{}
			hdc := C.BeginPaint(hwnd, &ps)
			C.FillRect(hdc, &ps.rcPaint, winapi.Color.windowframe)
			C.EndPaint(hwnd, &ps)
			return C.LRESULT(0)
		}
		else {
			if state != unsafe { nil } && umsg == state.shellhookid {
				match int(wparam) & 0x7fff {
					C.HSHELL_WINDOWCREATED {
						result := add_win(C.HWND(lparam), state) or {
							false
						}
						if result {
							state.update_render_grid()
							render_grid(state)
						}
					}
					C.HSHELL_WINDOWDESTROYED {
						if remove_win(C.HWND(lparam), state) {
							state.update_render_grid()
							render_grid(state)
						}
					}
					else {}
				}

			}
		}
	}

	return C.DefWindowProcW(hwnd, umsg, wparam, lparam)
}
