module model

import math

pub const monitor_display_1 = '\\\\.\\DISPLAY1'
pub const monitor_display_2 = '\\\\.\\DISPLAY2'
pub const classes = ['Windows.UI.Core.CoreWindow', 'ApplicationFrameWindow']

pub struct Rect {
pub:
	top    int
	left   int
	width  int
	height int
}

@[heap]
pub struct Monitor {
pub:
	id       string
	name     string
	size     Rect
	workarea Rect
}

@[heap]
pub struct Workarea {
pub:
	name      string
	monitor   string
	idx       int
	reference string
	active    bool
pub mut:
	windows []Window
}

@[heap]
pub struct Window {
pub:
	ptr       C.HWND
	title     string
	monitor   string
	classname string
pub mut:
	position int
	active   bool
	rect     Rect
}

pub struct State {
pub mut:
	handler         C.HWND
	shellhookid     u32
	grid            map[string][][]int
	// [id_workarea][window_id][left, top, width, height]
	windows         []Window
	window_workarea map[string]string
	workareas       map[string]Workarea
	monitors        map[string]Monitor
	current_window  ?C.HWND
}

pub fn (state &State) get_monitor_by_id(id string) Monitor {
	return state.monitors[id]
}

pub fn (windows []Window) count_active() int {
	mut i := 0
	for w in windows {
		if w.active {
			i++
		}
	}
	return i
}

pub fn (windows []Window) get_actives() []Window {
	mut wins := []Window{}
	for w in windows {
		if w.active {
			wins << w
		}
	}
	return wins
}

pub fn (mut state State) end_window_resizing(hwnd C.HWND, rect C.RECT) {
	workarea_reference := state.window_workarea[hwnd.str()]
	mut position := 0
	ws := unsafe { state.workareas[workarea_reference] }
	for i, w in ws.windows.get_actives() {
		if w.ptr == hwnd {
			position = i
			break
		}
	}
	state.grid[workarea_reference] = update_grid_for_workarea(state, position, workarea_reference,
		rect)
}

fn update_grid_for_workarea(state &State, position int, workarea_reference string, rect C.RECT) [][]int {
	old_grid := unsafe { state.grid[workarea_reference] }
	workarea := unsafe { state.workareas[workarea_reference] }
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
	if delta_right > 2 && delta_left > 2 {
		direction = 'NOOP'
	} else if delta_right > 2 {
		direction = 'RIGHT'
	}
	match direction {
		'LEFT' {
			if position == 0 {
				return old_grid
			}
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
			if position == total_in_workarea {
				return old_grid
			}
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
