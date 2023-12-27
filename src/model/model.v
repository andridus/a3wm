module model
import math
pub const (
    monitor_display_1 = '\\\\.\\DISPLAY1'
    monitor_display_2 = '\\\\.\\DISPLAY2'
    classes = ['Windows.UI.Core.CoreWindow',  'ApplicationFrameWindow']
)

pub struct Rect {
    pub:
    top int
    left int
    width int
    height int
}
@[heap]
pub struct Monitor {
    pub: 
    id string
    name string
    size Rect
    workarea Rect
}
@[heap]
pub struct Workarea {
    pub: 
    name string
    monitor string
    idx int
    reference string
    active bool
    pub mut:
    windows []Window
}
@[heap]
pub struct Window {
    pub: 
    ptr C.HWND
    title string
    monitor string
    classname string
    pub mut:
    position int
    active bool
    rect Rect
}
pub struct State {
    pub mut:
    handler C.HWND
    shellhookid u32
    grid map[string][][]int// [id_workarea][window_id][left, top, width, height]
    windows []Window
    window_workarea map[string]string
    workareas map[string]Workarea
    monitors map[string]Monitor
    current_window ?C.HWND
    window_resizing bool
    window_resizing_grid_workarea string
    window_resizing_grid_position int
}

pub fn (state &State) get_monitor_by_id(id string) Monitor {
    return state.monitors[id]
}
pub fn (windows []Window) count_active() int {
    mut i := 0
    for w in windows {
        if w.active { i++ }
    }
    return i
}
pub fn (windows []Window) get_actives() []Window {
    mut wins := []Window
    for w in windows {
        if w.active { 
            wins << w
        }
    }
    return wins
}
pub fn (mut state State) start_window_resizing(hwnd C.HWND, monitor Monitor) {
    rect := C.RECT{}
    C.GetWindowRect(hwnd, &rect);
    rect0 := model.Rect{left: rect.left, top: rect.top, width: rect.right, height: rect.bottom}
    workarea_reference := state.window_workarea[hwnd.str()]
    mut position := 0
    ws := state.workareas[workarea_reference]
    for i, w in ws.windows.get_actives() {
        if w.ptr == hwnd {
            position = i
            break
        }
    }
    
    state.window_resizing = true
    state.window_resizing_grid_position = position
    state.window_resizing_grid_workarea = workarea_reference
    println("Window ${hwnd} start from (${rect.left}, ${rect.top})-(${rect.right}, ${rect.bottom})\n")


}
pub fn (mut state State) end_window_resizing(rect C.RECT) {
    if state.window_resizing {
        state.grid[state.window_resizing_grid_workarea] = update_grid_for_workarea(state, rect)
        state.window_resizing = false
        state.window_resizing_grid_position = 0
    }
}

fn update_grid_for_workarea(state &State, rect C.RECT) [][]int {
    old_grid := state.grid[state.window_resizing_grid_workarea]
    workarea := state.workareas[state.window_resizing_grid_workarea]
    monitor := state.monitors[workarea.monitor]
    position := state.window_resizing_grid_position
    total_in_workarea := workarea.windows.count_active() - 1

    mut ng := [][]int{}
    old_left := old_grid[position][0]
    old_width := old_grid[position][2]
    old_right := old_left + old_width
    new_width := rect.right - rect.left
    delta_width := old_width - new_width
    mut direction := 'LEFT'
    delta_right := math.abs(old_right - rect.right)
    delta_left := math.abs(old_left - rect.left)
    if delta_right > 2 && delta_left > 2  {
        direction = 'NOOP'
    } else  if delta_right > 2 {
        direction = 'RIGHT'
    }
    match direction {
        'LEFT' {
            if position == 0 { return old_grid}
            if position > 0 {
                change_index := position - 1
                for i, og in old_grid {
                    if i == change_index {
                      ng << [og[0], og[1], og[2] + delta_width, og[3]]
                    } else if i == position {
                     ng << [rect.left, og[1], new_width, og[3]]
                    } else {
                      ng << og
                    }
                }
            }
        }
        'RIGHT' {
            if position == total_in_workarea { return old_grid}
            if position < total_in_workarea {
                change_index := position + 1
                for i, og in old_grid {
                    if i == change_index {
                      ng << [og[0] - delta_width, og[1], og[2] + delta_width, og[3]]
                    } else if i == position {
                     ng << [rect.left, og[1], new_width, og[3]]
                    } else {
                      ng << og
                    }
                }
            }
        }
        else {
            return old_grid
        }
    }
    // for i, og in old_grid {
    //     if i == position && position != 0 {
    //         mut left := 0
    //         if rect.left > 0 {left = rect.left}
    //         ng << [left, og[1], new_width, og[3]]
    //     } else if i > position {
    //         ng << [og[0] - delta_width , og[1], og[2]+delta_width, og[3]]
    //     } else {
    //         ng << [og[0], og[1], og[2]+delta_width, og[3]]
    //     }

    // }
    return ng
}
pub fn (mut state State) activate_window(hwnd C.HWND) {
    for _, mut wa in state.workareas {
        for mut w in wa.windows {
            if w.ptr == hwnd {
                w.active = true
            }
        }
    }
}
pub fn (mut state State) inactivate_window(hwnd C.HWND) {
    for _, mut wa in state.workareas {
        for mut w in wa.windows {
            if w.ptr == hwnd {
                w.active = false
            }
        }
    }
}
// pub fn (state &State) windows_by_monitor(name string) []Window {
//     mut windows := []Window{}
//     for w in state.windows { if w.monitor.compare(name) == 0 { windows << w } }
//     return windows
// }
// pub fn (state &State) debug_windows() {
//     mut strs := []string{}
//     for i, s in state.windows {
//         strs << '${i+1}. [${s.monitor}] ${s.title} '
//     }
//     println('------- RESUME -----------')
//     println('Total: ${strs.len}')
//     println('------- WINDOWS -----------')
//     for w in strs {
//         println(w)
//     }
//     println('----------------------')
// }