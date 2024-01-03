module core

@[heap]
pub struct State {
	topbar_enable			bool
	topbar_size				int = 50
pub mut:
	instance 					C.HINSTANCE
	handler      			C.HWND
	shellhookid  			u32
	topbar_bgcolor int = 0x00D5D5D7
	topbar_txtcolor int = 0x00848484
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
pub fn (state &State) get_show_window(cmd_show int) int {
	if state.topbar_enable {
		return cmd_show
	} else {
		return C.SW_HIDE
	}

}
pub fn (state &State) get_window_attrs() int {
	if state.topbar_enable {
		return C.WS_EX_TOPMOST
	} else {
		return 0
	}

}
pub fn (state &State) get_topbar_size() int {
	if state.topbar_enable {
		return state.topbar_size
	} else {
		return 0
	}
}
pub fn (state &State) toggle_disabled() {
	mut state0 := unsafe {&state}
	state0.disabled = !state0.disabled
}
