module app

import core
import rand
import winapi
import builtin.wchar

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

fn toggle_disabled(state &core.State) {
	state.toggle_disabled()
	if state.disabled {
		core.debug('DISABLE A3wm')
	} else {
		state.update_render_grid()
		state.render_grid()
		core.debug('ENABLE A3wm')
	}
}


pub fn fill_color(hwnd C.HWND, state &core.State) {
	ps := winapi.PaintStruct{}
	brush := C.CreateSolidBrush(state.topbar_bgcolor)
	C.GetClientRect(hwnd, &ps);
	hdc := C.BeginPaint(hwnd, &ps)
	C.FillRect(hdc, &ps.rcPaint, brush)
	C.SetBkColor(hdc, state.topbar_bgcolor)
	print_text(hdc, 'A3 Window Manager', 10, 2)
	monitor := get_monitor(state) or { return }
	w := button(state, 'Reset', monitor.width - 250, 5)
	button(state, 'Disable', monitor.width - 250 - w, 5)
	C.SetTextColor(hdc, state.topbar_txtcolor)
	mut left := print_text(hdc, '${state.windows.len} windows', 10, 25)
	left = print_text(hdc, '${state.grids.len} grids', left + 10, 25)
	print_text(hdc, '${state.monitors.len} monitors',  left + 10, 25)

	print_clock(hdc, monitor)
	C.EndPaint(hwnd, &ps)
}

fn button(state &core.State, message string, x int , y int) int {
	class :=wchar.from_string('BUTTON')
	message0 :=wchar.from_string(message)
	w := (message.len*10 + 20)
	C.CreateWindow(class, message0, C.WS_TABSTOP | C.WS_VISIBLE | C.WS_CHILD | C.BS_DEFPUSHBUTTON, x-w,y,w,40, state.handler, unsafe {nil}, state.instance, unsafe {nil})
	return w + 10
}
fn get_monitor(state &core.State) ?core.Rect {
	for _, monitor in state.monitors {
		if monitor.size.left == 0 {
			return monitor.size
		}
	}
	return none
}
fn print_clock(hdc C.HDC, monitor core.Rect) {
	text := '18:19 03/01/2024'
	C.SetTextColor(hdc, 0x00000000)
	C.TextOutA(hdc, monitor.width - (text.len*10), 10, text.str, text.len);
}
fn print_text(hdc C.HDC, text string, x int, y int) int {
	C.TextOutA(hdc, x, y, text.str, text.len);
	return x + (text.len*10)
}