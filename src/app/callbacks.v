module app

import builtin.wchar
import core
import rand

fn get_monitor_callback(wmonitor C.HMONITOR, hdc C.HDC, rect &C.RECT, state &core.State) int {
	mut state0 := unsafe { &state }
	monitor_info := C.MONITORINFOEX{
		cbSize: sizeof(C.MONITORINFOEX)
	}
	C.GetMonitorInfo(wmonitor, &monitor_info)
	monitor_name := unsafe {
		wchar.to_string(monitor_info.szDevice)
	}
	monitor := core.Monitor{
		name: monitor_name
		id: rand.uuid_v4()
		size: core.Rect{
			top: monitor_info.rcMonitor.top
			left: monitor_info.rcMonitor.left
			width: monitor_info.rcMonitor.right - monitor_info.rcMonitor.left
			height: monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top
		}
		workarea: core.Rect{
			top: monitor_info.rcWork.top
			left: monitor_info.rcWork.left
			width: monitor_info.rcWork.right - monitor_info.rcWork.left
			height: monitor_info.rcWork.bottom - monitor_info.rcWork.top
		}
	}
	state0.monitors[monitor.id] = monitor
	return 1
}

fn window_watcher_callback(handler C.HWND, state &core.State) int {
	add_win(handler, state) or { core.debug('error: ${err.str()}') }
	return 1
}
