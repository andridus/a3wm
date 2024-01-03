module app

import builtin.wchar
import winapi
import core

pub fn entrypoint(instance C.HINSTANCE, cmd_show int) int {
	mut state := &core.State{}

	register_hotkeys()
	// window hook to get any resized window
	g_hook := C.SetWinEventHook(C.EVENT_MIN, C.EVENT_MAX, unsafe { nil }, fn [state] (ncode int, wparam C.WPARAM, hwnd C.HWND) C.HHOOK {
		return window_hook(ncode, wparam, hwnd, state)
	}, 0, 0, C.WINEVENT_OUTOFCONTEXT)

	classname := wchar.from_string('a3class')
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

	C.ShowWindow(hwnd, C.SW_HIDE)
	C.RegisterShellHookWindow(hwnd)
	state.shellhookid = C.RegisterWindowMessageW(shellhook)
	C.SetWindowLongPtr(hwnd, C.GWLP_USERDATA, state)
	state.handler = hwnd

	state.setup_state(hwnd, get_monitor_callback, window_watcher_callback)

  nid := create_a_notify_icon(hwnd)
	msg := C.MSG{}
	for C.GetMessage(&msg, unsafe { nil }, 0, 0) > 0 {
		map_hotkeys(&msg, state)
		C.TranslateMessage(&msg)
		C.DispatchMessage(&msg)
	}

	C.UnhookWinEvent(g_hook)
	C.Shell_NotifyIconW(C.NIM_DELETE, nid)
	return 0
}

fn create_a_notify_icon(hwnd C.HWND) &C.NOTIFYICONDATAA {

	id_trap_app_icon := 5000
	nid := &C.NOTIFYICONDATAA{
		szTip: c'A3wm Configuration'
		cbSize: sizeof(C.NOTIFYICONDATAA)
		hWnd: hwnd
		uID: id_trap_app_icon
		uFlags: C.NIF_ICON | C.NIF_MESSAGE | C.NIF_TIP
		uCallbackMessage: winapi.wm_tray_icon
		hIcon: C.LoadIconW(unsafe {nil}, C.IDI_APPLICATION)
	}
	C.Shell_NotifyIconA(C.NIM_ADD, nid)
	return nid
}