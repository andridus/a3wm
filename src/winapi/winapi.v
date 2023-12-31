module winapi

import core

type C.WPARAM = u32
type C.LPARAM = u32

@[typedef]
pub struct C.NOTIFYICONDATAA{
		cbSize u32
		hWnd C.HWND
		uID int
		uFlags int
		uCallbackMessage int
		hIcon C.HICON
		szInfoTitle &u8 = unsafe {nil}
		szTip &u8 = unsafe {nil}
	}

@[typedef]
pub struct C.RECT {
	top    int
	left   int
	right  int
	bottom int
}

@[typedef]
pub struct C.HICON {}

@[typedef]
pub struct C.HCURSOR {}

@[typedef]
pub struct C.HWND {}

@[typedef]
pub struct C.HINSTANCE {}

@[typedef]
struct C.PAINTSTRUCT {
pub:
	rcPaint C.RECT
}

pub type PaintStruct = C.PAINTSTRUCT

@[typedef]
pub struct C.HHOOK {}

@[typedef]
pub struct C.HDC {}

@[typedef]
pub struct C.HBRUSH {}

@[typedef]
pub struct C.MSG {
	hwnd    C.HWND
	message u32
	wParam  C.WPARAM
	lParam  C.LPARAM
	time    u32
	pt      C.POINT
}

pub type Msg = C.MSG

@[typedef]
pub struct C.HINSTANCE {}

@[typedef]
pub struct C.COLORREF {}


@[typedef]
pub struct C.HMONITOR {}

@[typedef]
pub struct C.MONITORINFOEX {
	szDevice  &u8 = unsafe { nil }
	cbSize    u32
	rcMonitor C.RECT
	rcWork    C.RECT
	dwFlags   u32
}

@[typedef]
pub struct C.MONITORINFO {
	cbSize    u32
	rcMonitor C.RECT
	rcWork    C.RECT
	dwFlags   u32
}

@[typedef]
pub struct C.WNDCLASS {
	style         u32
	lpfnWndProc   fn (C.HWND, int, C.WPARAM, C.HWND) C.LRESULT
	hInstance     C.HINSTANCE
	lpszClassName &u8 = unsafe { nil }
	hCursor       C.HCURSOR
	hIcon         C.HICON
}

@[typedef]
pub struct C.HWINEVENTHOOK {}

pub type WindowClass = C.WNDCLASS

@[typedef]
pub struct C.POINT {
	x u32
	y u32
}

pub const wm_tray_icon = C.WM_USER + 1

fn C.GetCursorPos(&C.POINT) u8
fn C.MessageBoxA(&u8, &u8, &u8, int) int
fn C.CreateWindowExW(u8, &u8, &u8, u32, int, int, int, int, C.HWND, &u8, C.HINSTANCE, &u8) C.HWND
fn C.CreateWindowEx(u8, &u8, &u8, u32, int, int, int, int, C.HWND, &u8, C.HINSTANCE, &u8) C.HWND
fn C.CreateWindow(&u8, &u8, u32, int, int, int, int, C.HWND, &u8, C.HINSTANCE, &u8) C.HWND
fn C.ShowWindow(C.HWND, int)
fn C.RegisterClass(&C.WNDCLASS)
fn C.DefWindowProcW(C.HWND, int, C.WPARAM, C.HWND) C.LRESULT
fn C.PostQuitMessage(int)
fn C.GetMessage(&u8, &u8, int, int) int
fn C.TranslateMessage(&C.MSG)
fn C.DispatchMessage(&C.MSG)
fn C.BeginPaint(C.HWND, &C.PAINTSTRUCT) C.HDC
fn C.EndPaint(C.HWND, &C.PAINTSTRUCT) C.HDC
fn C.FillRect(C.HDC, &u8, C.HBRUSH)
fn C.LoadCursorW(C.HINSTANCE, int) C.HCURSOR
fn C.LoadIconW(C.HINSTANCE, int) C.HICON
fn C.RegisterShellHookWindow(C.HWND) bool
fn C.RegisterWindowMessageW(&u8) u32
fn C.SetWindowLongPtr(C.HWND, int, &u8)
fn C.SetWindowLong(C.HWND, int, int)
fn C.EnumWindows(fn (C.HWND, &core.State) int, &u8) int
fn C.GetParent(C.HWND) C.HWND
fn C.GetWindowText(C.HWND, &u8, int)
fn C.GetClassName(C.HWND, &u8, int)
fn C.IsWindow(C.HWND) int
fn C.IsWindowVisible(C.HWND) int
fn C.GetWindowLong(C.HWND, int) int
fn C.GetWindow(C.HWND, int) int
fn C.GetWindowRect(C.HWND, &C.RECT)
fn C.DestroyWindow(C.HWND) int
fn C.GetWindowLongPtr(C.HWND, int) &core.State
fn C.MoveWindow(C.HWND, int, int, int, int, int) int
fn C.RegisterHotKey(C.HWND, int, u32, u32) int

fn C.MonitorFromWindow(C.HWND, int) C.HMONITOR
fn C.GetMonitorInfo(C.HMONITOR, &C.MONITORINFOEX)
fn C.EnumDisplayMonitors(&C.HDC, &C.RECT, fn (C.HMONITOR, C.HDC, &C.RECT, &core.State) int, &u8)

fn C.SetWindowsHookEx(int, fn (int, C.WPARAM, C.HWND) C.HHOOK, C.HINSTANCE, &u8) C.HHOOK
fn C.SetWindowsHookExA(int, fn (int, C.WPARAM, C.HWND) C.HHOOK, C.HINSTANCE, &u8) C.HHOOK
fn C.CallNextHookEx(C.HHOOK, int, C.WPARAM, C.HWND) C.HHOOK
fn C.GetCurrentThreadId() &u8
fn C.GetModuleHandleA(&u8) C.HINSTANCE
fn C.LoadLibraryA(&u8) C.HINSTANCE
fn C.UnhookWindowsHookExA(C.HHOOK)
fn C.GetLastError() u32
fn C.SetWinEventHook(int, int, &u8, fn (int, C.WPARAM, C.HWND) C.HHOOK, int, int, int) C.HWINEVENTHOOK
fn C.UnhookWinEvent(C.HWINEVENTHOOK)
// fn C.GetActiveWindow() C.HWND
fn C.GetForegroundWindow() C.HWND
fn C.SetActiveWindow(C.HWND) C.HWND
fn C.Shell_NotifyIconW(int, &u8) int
fn C.Shell_NotifyIconA(int, &u8) int
fn C.SetWindowPos(C.HWND, C.HWND, int, int, int, int, u32)
// fn C.RGB(int, int, int) C.COLORREF
fn C.SetClassLongPtr(C.HWND, u32, &u8)
fn C.SetClassLong(C.HWND, u32, &u8)
fn C.CreateSolidBrush(int) C.HBRUSH
fn C.GetClientRect(C.HWND, &u8)
fn C.UpdateWindow(C.HWND)
fn C.RedrawWindow(C.HWND, &u8, u32, u32) int
fn C.TextOutA(C.HDC, int, int, &u8, int) int
fn C.SetBkColor(C.HDC, int) C.COLORREF
fn C.SetTextColor(C.HDC, int) C.COLORREF
fn C.DrawTextA(C.HDC, &u8, int, &u8, int) int