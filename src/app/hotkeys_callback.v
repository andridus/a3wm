module app

import core

fn callback_set_next_window_to_horizontal(state &core.State) {
	state.set_next_window_to(.horizontal)
	core.debug('ALT+h: set next direction to horizontal')
}

fn callback_set_next_window_to_vertical(state &core.State) {
	state.set_next_window_to(.vertical)
	core.debug('ALT+v: set next direction to vertical')
}
fn callback_toggle_grid_direction(state &core.State) {
	state.toggle_grid_direction()
	render_grid(state)
	core.debug('ALT+t: toggle direction')
}
fn callback_fullscreen_window(state &core.State) {
	state.set_window_to_fullscreen()
	render_grid(state)
	core.debug('ALT+f: fullscreen window')
}
fn callback_move_to_left_window(state &core.State) {
	// state.set_active_left_window() // TODO
	core.debug('ALT+LEFT: move to left window')
}
fn callback_move_to_top_window(state &core.State) {
	// state.set_active_top_window() // TODO
	core.debug('ALT+UP: move to window on top')
}
fn callback_move_to_bottom_window(state &core.State) {
	// state.set_active_left_window() // TODO
	core.debug('ALT+DOWN: move to window on right')
}
fn callback_move_to_right_window(state &core.State) {
	// state.set_active_right_window() // TODO
	core.debug('ALT+RIGHT: move to window bellow ')
}