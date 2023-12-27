module core
import builtin.wchar
import winapi
import model

// , prev_instance C.HINSTANCE, cmd_line &u8,
pub fn main(instance C.HINSTANCE,  cmd_show int) int {

	mut state := model.State{}
	ref_state := &state

	// window hook to get any resized window
	g_hook := C.SetWinEventHook ( C.EVENT_MIN, C.EVENT_MAX, unsafe {nil},  fn [ref_state] (ncode int, wparam C.WPARAM, hwnd C.HWND) C.HHOOK {
        	return window_hook(ncode, wparam, hwnd, ref_state)
        }, 0, 0, C.WINEVENT_OUTOFCONTEXT)

	classname := wchar.from_string('Sample Window Class')
	title := wchar.from_string('Learn to Program Windows')
	shellhook := wchar.from_string('SHELLHOOK')
	wc := winapi.WindowClass {
		lpfnWndProc: window_proc
		hInstance: instance
		lpszClassName: classname
		hIcon: C.LoadIconW(unsafe{nil}, 32512)
		hCursor: C.LoadCursorW(unsafe{nil},32512)
	}
	C.RegisterClass(&wc)
	hwnd := C.CreateWindowEx(0, classname, title, C.WS_OVERLAPPEDWINDOW,
	0,0,0,0, unsafe {nil}, 0x0, instance, 0x0)

	if hwnd == unsafe { nil }  {  return 0 }
	// Get all monitors
	C.EnumDisplayMonitors(unsafe {nil}, unsafe {nil}, get_monitor_callback, &state)

	C.ShowWindow(hwnd, cmd_show);
	C.RegisterShellHookWindow(hwnd)
	state.shellhookid = C.RegisterWindowMessageW(shellhook);

	C.SetWindowLongPtr(hwnd, C.GWLP_USERDATA, &state);

	state.handler = hwnd
	// windows := state.windows_by_monitor(monitor_display_1)
	C.EnumWindows(window_watcher_callback, &state)
	render_grid(state)
	msg := C.MSG{}
	for C.GetMessage(&msg, unsafe {nil}, 0, 0) > 0
		{
				C.TranslateMessage(&msg)
				C.DispatchMessage(&msg)
		}

	C.UnhookWinEvent(g_hook)
	return 0
}