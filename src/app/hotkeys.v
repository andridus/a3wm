module app

import winapi
import core

fn register_hotkeys() {
	// Register Hot Key
	// Follow the https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes
	// ALT + v : next window on vertical disposition
	// ALT + h : next window on horizontal disposition
	register_one_hotkey(1, winapi.Key.mod_alt , winapi.Key.key_h, 'set direction to HORIZONTAL')
	register_one_hotkey(2, winapi.Key.mod_alt , winapi.Key.key_v, 'set direction to VERTICAL')
	register_one_hotkey(3, winapi.Key.mod_alt , winapi.Key.key_t, 'toggle direction for selected grid')
	register_one_hotkey(4, winapi.Key.mod_alt , winapi.Key.key_f, 'set fullscreen for active window')
	register_one_hotkey(5, winapi.Key.mod_alt , winapi.Key.key_left, 'move to left window')
	register_one_hotkey(6, winapi.Key.mod_alt , winapi.Key.key_up, 'move to top window')
	register_one_hotkey(7, winapi.Key.mod_alt , winapi.Key.key_right, 'move to right window')
	register_one_hotkey(8, winapi.Key.mod_alt , winapi.Key.key_down, 'move to bottom window')
}

fn map_hotkeys(msg &C.MSG, state &core.State) {
	if msg.message == C.WM_HOTKEY {
		match int(msg.wParam) {
			1 { callback_set_next_window_to_horizontal(state) }
			2 { callback_set_next_window_to_vertical(state) }
			3 { callback_toggle_grid_direction(state) }
			4 { callback_fullscreen_window(state) }
			5 { callback_move_to_left_window(state) }
			6 { callback_move_to_top_window(state) }
			7 { callback_move_to_right_window(state) }
			8 { callback_move_to_bottom_window(state) }
			else {}
		}
	}
}

fn register_one_hotkey(code int, modifier winapi.Key, key winapi.Key, description string) {
	if C.RegisterHotKey(unsafe { nil }, code, u32(modifier), u32(key)) == 1 {
		core.debug('Hotkey \'${modifier}+${key}\' registered for `${description}`')
	} else {
		core.debug('ERROR: Hotkey \'${modifier}+${key}\' was not possible')
	}
}
