module core

@[heap]
pub struct State {
pub mut:
	handler      			C.HWND
	shellhookid  			u32
	windows 					map[string]Window
	monitors          map[string]Monitor
	workareas         []Workarea
	grids 						[]Grid

	grids_ptr 				map[string]int
	workareas_ptr 			map[string]int
	windows_grid 			map[string]string
	grid_workarea 		map[string]string
	window_workarea   map[string]string


	render_grid_arr       map[string]map[string][]int
	current_window    ?C.HWND
	disabled bool
	next_window_position WindowPosition = .horizontal
}

pub fn (state &State) toggle_disabled() {
	mut state0 := unsafe {&state}
	state0.disabled = !state0.disabled
}
