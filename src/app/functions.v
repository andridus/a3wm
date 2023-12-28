module app

import core
import rand

fn get_monitor_by_win(hwnd C.HWND, state &core.State) !core.Monitor {
	monitor := C.MonitorFromWindow(hwnd, C.MONITOR_DEFAULTTONEAREST)
	monitor_info := C.MONITORINFOEX{
		cbSize: sizeof(C.MONITORINFOEX)
	}
	C.GetMonitorInfo(monitor, &monitor_info)
	monitor_name := wchar_to_string(monitor_info.szDevice)
	for _, m in state.monitors {
		if monitor_name == m.name {
			return m
		}
	}
	return error("don't find monitor")
}

fn add_win(hwnd C.HWND, state &core.State) !bool {
	// check if exists window
	win0 := state.windows[hwnd.str()] or {core.Window{}}
	if win0 != core.Window{}  { return false }

	len := 1024
	title_ptr :=  []char{len: len, cap: len}
	classname_ptr := []char{len: len, cap: len}

	if !is_nil(hwnd) && !is_hwnd_same(hwnd, state.handler)  {
		C.GetWindowText(hwnd, title_ptr.data, len)
		C.GetClassName(hwnd, classname_ptr.data, len)
		title := string_from_char(title_ptr, len)
		classname :=  string_from_char(classname_ptr, len)
		if C.IsWindow(hwnd) == 1 && C.IsWindowVisible(hwnd) == 1 && title != '' {
			exstyle := C.GetWindowLong(hwnd, C.GWL_EXSTYLE)
			style := C.GetWindowLong(hwnd, C.GWL_STYLE)
			window_owner := C.GetWindow(hwnd, C.GW_OWNER)
			mut active := false
			if (style & C.WS_MINIMIZE) == 0 { active = true }
			if ((exstyle & C.WS_EX_TOOLWINDOW) == 0 && window_owner == 0)
				|| ((exstyle & C.WS_EX_APPWINDOW) != 0 && window_owner != 0) {
				if classname !in core.classes {
					monitor := get_monitor_by_win(hwnd, state)!
					window := core.Window{
						title: title
						ptr: hwnd
						classname: classname
						active: active
					}
					state.add_window(window)
					add_window_in_active_workarea(window, state, monitor)
					return true
				}
			}
		}
	}
	return false
}

fn remove_win(hwnd C.HWND, state &core.State) bool {
	if state.grids.len == 0 { return false}
	mut grid := state.get_grid_by_hwnd(hwnd.str()) or { return false}
	workarea := state.get_workarea_by_grid(grid.uuid) or { return false}
	has_grid, new_grid := grid.remove_window(hwnd, state)
	state.remove_window(hwnd.str())

	if has_grid {
		workarea.set_grid(new_grid.uuid)
		state.replace_workarea(workarea)
	} else {
		state.replace_grid(grid)
	}
	return true
}

fn add_window_in_active_workarea(window core.Window, state &core.State, monitor &core.Monitor) bool {
	mut state0 := unsafe {&state}
	mut active := state0.workareas.len <= state.monitors.len

	for _, mut workarea in state0.workareas {
		if workarea.active && workarea.monitor == monitor.id {
			mut grid := state.get_grid_by_uuid(workarea.grid_idx)
			grid.add_window(window, workarea, state)
			return true
		}
	}
	uuid := rand.uuid_v4()
	grid0 := core.new_grid_for_window(window, monitor.workarea)
	state.add_grid(grid0)
	grid := state0.grids.last()
	state0.workareas << core.Workarea{
		uuid: uuid
		monitor: monitor.id
		idx: state.workareas.len
		grid_idx: grid.uuid
		active: active
	}
	wk := state.workareas.last()
	state0.add_windows_reference(window, grid,  wk)
	return true
}
