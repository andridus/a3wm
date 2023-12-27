module core
import model
fn callback_set_next_window_to_horizontal(state &model.State) {
	state.set_next_window_to(.horizontal)
	debug('callback_set_next_window_to_horizontal')
}
fn callback_set_next_window_to_vertical(state &model.State) {
	state.set_next_window_to(.vertical)
	debug('callback_set_next_window_to_vertical')
}
