module app

fn clear_bytes(bts []u8) string {
	mut s := []u8{}
	for b in bts {
		if b != 0 {
			s << b
		}
	}
	return s.bytestr()
}
pub fn is_hwnd_same(hwnd C.HWND, hwnd2 C.HWND) bool {
	if hwnd == hwnd2 { return true }
	return false
}