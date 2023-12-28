module app
import builtin.wchar
fn string_from_char(cstr []char, len int) string {
	str := unsafe { cstr[0].vstring_with_len(len)}
	str0 := clear_bytes(str.bytes())
	return str0
}

fn wchar_to_string(str0 &u8) string{
	str := unsafe { wchar.to_string(str0)}
	return str
}

pub fn is_nil(hwnd C.HWND) bool {
	if hwnd == unsafe { nil } { return true }
	return false
}
