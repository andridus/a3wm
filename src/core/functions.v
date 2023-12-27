module core
import model
import builtin.wchar
import rand

fn get_monitor_by_win(hwnd C.HWND, state &model.State) !model.Monitor {
 monitor := C.MonitorFromWindow(hwnd, C.MONITOR_DEFAULTTONEAREST)
 monitor_info := C.MONITORINFOEX{cbSize: sizeof(C.MONITORINFOEX  )}
 C.GetMonitorInfo(monitor, &monitor_info)
 monitor_name := unsafe {
         wchar.to_string(monitor_info.szDevice)
     }

 for _, m in state.monitors {
    if monitor_name == m.name {
        return m
    }
 }
 return error('don\'t find monitor')
}
fn add_win(hwnd C.HWND, state &model.State) !{
 // check if exists window
 for win in state.windows { if win.ptr == hwnd { return } }
 // mut state0 := unsafe { &state }


 // check if has window
 len := 1024
 title_ptr := []char{cap: len, len: len}
 classname_ptr := []char{cap: len, len: len}
 // mut iter_title := []u8{cap:1024}
 if hwnd != unsafe { nil } && hwnd != state.handler {
     // parent := C.GetParent(handler)
     // _ := window_watcher_handler(state, parent)
     C.GetWindowText(hwnd, title_ptr.data, len)
     C.GetClassName(hwnd, classname_ptr.data, len)
     stitle := unsafe {
         title_ptr[0].vstring_with_len(len)
     }
     sclassname := unsafe {
         classname_ptr[0].vstring_with_len(len)
     }
     title := clear_bytes(stitle.bytes())
     classname := clear_bytes(sclassname.bytes())
     
     if C.IsWindow(hwnd) == 1 && C.IsWindowVisible(hwnd) == 1 && stitle[0] != 0  {
         exstyle := C.GetWindowLong(hwnd, C.GWL_EXSTYLE)
         style := C.GetWindowLong(hwnd, C.GWL_STYLE)
         window_owner := C.GetWindow(hwnd, C.GW_OWNER);
         mut active := false
         if (style & C.WS_MINIMIZE) == 0 { active = true }
         if ((exstyle & C.WS_EX_TOOLWINDOW) == 0 && (window_owner == 0)) || ((exstyle & C.WS_EX_APPWINDOW) != 0 && (window_owner != 0)) {
             rect := C.RECT{}
             if classname !in  model.classes {
                 C.GetWindowRect(hwnd, &rect);
                 monitor := get_monitor_by_win(hwnd, state)!
                 rect0 := model.Rect{left: rect.left, top: rect.top, width: rect.right, height: rect.bottom}
                 window := model.Window{title: title, ptr: hwnd, classname: classname, rect: rect0, active: active}
                 add_window_in_active_workarea(window, state, monitor)
             }
         }
     }
 }
}
fn remove_win(hwnd C.HWND, state &model.State) {
     mut state0 := unsafe { &state }
     for _, mut w in state0.workareas {
        for i, win in w.windows {
             if win.ptr == hwnd {
                 w.windows.delete(i)
             }
        }
    }
 }
fn add_window_in_active_workarea(window model.Window, state &model.State, monitor &model.Monitor) bool {
    mut state0 := unsafe {&state}
    mut active := state0.workareas.len <= state0.monitors.len
    for _, mut w in state0.workareas {
        if w.active && w.monitor == monitor.id{ 
            w.windows << model.Window{...window, position: w.windows.len}
            state0.window_workarea[window.ptr.str()] = w.reference
            return true
        }
    }
    uuid := rand.uuid_v4()
    state0.workareas[uuid] = model.Workarea {
        monitor: monitor.id
        idx: state0.workareas.len + 1
        reference:  uuid
        windows: [window]
        active: active
    }
    state0.window_workarea[window.ptr.str()] = uuid
    return true
}