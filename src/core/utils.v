module core
fn clear_bytes(bts []u8) string {
	mut s := []u8{}
	for b in bts  {
		if b != 0 { s << b}
	}
	return s.bytestr()
}