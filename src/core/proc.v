module core

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
							println(err.str())
							false
						}
						if result {
							update_grid(state)
							render_grid(state)
						}
					}
					C.HSHELL_WINDOWDESTROYED {
						if remove_win(C.HWND(lparam), state) {
							update_grid(state)
							render_grid(state)
						}
					}
					// C.HSHELL_ACTIVATESHELLWINDOW { println('HSHELL_ACTIVATESHELLWINDOW')}
					// C.HSHELL_WINDOWACTIVATED {
					// 	println('HSHELL_WINDOWACTIVATED')
					// 	// render_grid(state)
					// }
					// C.HSHELL_GETMINRECT { println('HSHELL_GETMINRECT')}
					// C.HSHELL_REDRAW { println('HSHELL_REDRAW')}
					// C.HSHELL_TASKMAN { println('HSHELL_TASKMAN')}
					// C.HSHELL_LANGUAGE { println('HSHELL_LANGUAGE')}
					// C.HSHELL_SYSMENU { println('HSHELL_SYSMENU')}
					// C.HSHELL_ENDTASK { println('HSHELL_ENDTASK')}
					// C.HSHELL_ACCESSIBILITYSTATE { println('HSHELL_ACCESSIBILITYSTATE')}
					// C.HSHELL_APPCOMMAND { println('HSHELL_APPCOMMAND')}
					// C.HSHELL_WINDOWREPLACED { println('HSHELL_WINDOWREPLACED')}
					// C.HSHELL_WINDOWREPLACING { println('HSHELL_WINDOWREPLACING')}
					else {}
				}
			}
		}
	}
	return C.DefWindowProcW(hwnd, umsg, wparam, lparam)
}
