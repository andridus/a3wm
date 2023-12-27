module core
import winapi
import model
fn register_hotkeys() {
	// Register Hot Key
	// Follow the https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes
	// ALT + v : next window on vertical disposition
	// ALT + h : next window on horizontal disposition
	register_one_hotkey(1, winapi.Key.mod_alt, winapi.Key.key_h)
	register_one_hotkey(2, winapi.Key.mod_alt, winapi.Key.key_v)
}

fn map_hotkeys(msg &C.MSG, state &model.State) {
	if msg.message == C.WM_HOTKEY {
		match int(msg.wParam) {
			1 { callback_set_next_window_to_horizontal(state) }
			2 { callback_set_next_window_to_vertical(state) }
			else {}
		}
	}
}

fn register_one_hotkey(code int, modifier winapi.Key, key winapi.Key){
	if C.RegisterHotKey(unsafe {nil}, code, u32(modifier), u32(key)) == 1 {
		println('Hotkey \'${modifier}+${key}\' registered' )
	} else {
		println('ERROR: Hotkey \'${modifier}+${key}\' was not possible' )
	}
}
