module core

pub const monitor_display_1 = '\\\\.\\DISPLAY1'
pub const monitor_display_2 = '\\\\.\\DISPLAY2'
pub const classes = ['Windows.UI.Core.CoreWindow', 'ApplicationFrameWindow']

pub enum Action {
	swap_window
	drag_axis
	nothing
}

pub enum WindowPosition {
	horizontal
	vertical
}

pub struct Rect {
pub:
	top    int
	left   int
	width  int
	height int
}


pub fn (r Rect) str() string {
	return '(${r.left}, ${r.top}, ${r.width}, ${r.height})'
}

pub fn (r Rect) to_list_int() []int {
	return [r.left, r.top, r.width, r.height]
}

pub fn (r Rect) has_point(p C.POINT) bool {
	if p.x >= r.left &&  p.x <= r.left + r.width && p.y >= r.top &&  p.y <= r.top + r.height { return  true } else { return false }
}

pub struct Monitor {
pub:
	id       string
	name     string
	size     Rect
	workarea Rect
}

pub struct Workarea {
pub:
	uuid 			string
	idx       int
	name      string
	monitor   string
	active    bool
pub mut:
	windows []&Window
	grid_idx   string
}

pub fn (w &Workarea) set_grid(grid_id string) {
	mut w0 := unsafe { &w}
	w0.grid_idx = grid_id
}

pub struct Window {
pub:
	ptr   C.HWND
	title string
	classname string
pub mut:
	position int
	active   bool
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
	wins.sort(a.position < b.position)
	return wins
}
