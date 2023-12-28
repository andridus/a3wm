module app

import core

fn callback_set_next_window_to_horizontal(state &core.State) {
	state.set_next_window_to(.horizontal)
	core.debug('callback_set_next_window_to_horizontal')
}

fn callback_set_next_window_to_vertical(state &core.State) {
	state.set_next_window_to(.vertical)
	core.debug('callback_set_next_window_to_vertical')
}
