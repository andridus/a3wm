module core
import builtin.wchar
import model
import rand
fn get_monitor_callback(wmonitor C.HMONITOR, hdc C.HDC, rect &C.RECT, state &model.State) int {
 mut state0 := unsafe { &state}
 monitor_info := C.MONITORINFOEX{cbSize: sizeof(C.MONITORINFOEX)}
 C.GetMonitorInfo(wmonitor, &monitor_info)
 monitor_name := unsafe {
         wchar.to_string(monitor_info.szDevice)
     }
 monitor := model.Monitor{
     name: monitor_name
     id: rand.uuid_v4()
     size: model.Rect{
         top: monitor_info.rcMonitor.top
         left: monitor_info.rcMonitor.left
         width: monitor_info.rcMonitor.right - monitor_info.rcMonitor.left
         height: monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top
     }
     workarea: model.Rect{
         top: monitor_info.rcWork.top
         left: monitor_info.rcWork.left
         width: monitor_info.rcWork.right - monitor_info.rcWork.left
         height: monitor_info.rcWork.bottom - monitor_info.rcWork.top
     }
    }
    state0.monitors[monitor.id] = monitor
 return 1
}

fn window_watcher_callback(handler C.HWND, state &model.State) int {
    add_win(handler, state) or {
                        println('error: ${err.str()}')
                    }
    return 1
}