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
	state.render_grid()
	core.debug('ALT+t: toggle direction')
}
fn callback_fullscreen_window(state &core.State) {
	state.set_window_to_fullscreen()
	state.render_grid()
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
fn callback_reset_a3wm(state &core.State) {
	// state.set_active_right_window() // TODO
	state.setup_state(state.handler, get_monitor_callback, window_watcher_callback)
	state.render_grid()
	core.debug('CTRL+SHIFT+r: reset a3wm')
}
fn callback_disable_a3wm(state &core.State) {
	// state.set_active_right_window() // TODO
	toggle_disabled(state)
}