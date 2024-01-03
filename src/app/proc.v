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
			fill_color(hwnd, state)
			return C.LRESULT(0)
		}
		winapi.wm_tray_icon {
				match int(lparam) {
					C.WM_LBUTTONUP {
							toggle_disabled(state)
					}
					C.WM_RBUTTONUP {
							println('Quit application')
							C.PostQuitMessage(0)
							return C.LRESULT(0)
					}
					else {}
				}
		}
		else {
			if state != unsafe { nil } && umsg == state.shellhookid {
				match int(wparam) & 0x7fff {
					C.HSHELL_WINDOWCREATED {
						// fill_color(hwnd, state)
						result := add_win(C.HWND(lparam), state) or {
							false
						}
						if result {
							state.update_render_grid()
							state.render_grid()
						}
					}
					C.HSHELL_WINDOWDESTROYED {
						if remove_win(C.HWND(lparam), state) {
							state.update_render_grid()
							state.render_grid()
						}
					}
					else {}
				}

			}
		}
	}

	return C.DefWindowProcW(hwnd, umsg, wparam, lparam)
}
