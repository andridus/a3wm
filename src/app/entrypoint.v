module app

import builtin.wchar
import winapi
import core

pub fn entrypoint(instance C.HINSTANCE, cmd_show int) int {
	mut state := core.State{}
	ref_state := &state

	register_hotkeys()
	// window hook to get any resized window
	g_hook := C.SetWinEventHook(C.EVENT_MIN, C.EVENT_MAX, unsafe { nil }, fn [ref_state] (ncode int, wparam C.WPARAM, hwnd C.HWND) C.HHOOK {
		return window_hook(ncode, wparam, hwnd, ref_state)
	}, 0, 0, C.WINEVENT_OUTOFCONTEXT)

	classname := wchar.from_string('Sample Window Class')
	title := wchar.from_string('A3 Window Manager')
	shellhook := wchar.from_string('SHELLHOOK')
	wc := winapi.WindowClass{
		lpfnWndProc: window_proc
		hInstance: instance
		lpszClassName: classname
		hIcon: C.LoadIconW(unsafe { nil }, 32512)
		hCursor: C.LoadCursorW(unsafe { nil }, 32512)
	}
	C.RegisterClass(&wc)
	hwnd := C.CreateWindowEx(0, classname, title, C.WS_OVERLAPPEDWINDOW, 0, 0, 0, 0, unsafe { nil },
		0x0, instance, 0x0)

	if hwnd == unsafe { nil } {
		return 0
	}

	// Get all monitors
	C.EnumDisplayMonitors(unsafe { nil }, unsafe { nil }, get_monitor_callback, &state)

	C.ShowWindow(hwnd, cmd_show)
	C.RegisterShellHookWindow(hwnd)
	state.shellhookid = C.RegisterWindowMessageW(shellhook)
	C.SetWindowLongPtr(hwnd, C.GWLP_USERDATA, &state)
	state.handler = hwnd

	C.EnumWindows(window_watcher_callback, &state)
	render_grid(&state)
	msg := C.MSG{}
	for C.GetMessage(&msg, unsafe { nil }, 0, 0) > 0 {
		map_hotkeys(&msg, &state)
		C.TranslateMessage(&msg)
		C.DispatchMessage(&msg)
	}

	C.UnhookWinEvent(g_hook)
	return 0
}
