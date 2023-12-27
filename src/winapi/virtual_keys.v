module winapi
pub enum Key {
	key_0 = 0x30
	key_1
	key_2
	key_3
	key_4
	key_5
	key_6
	key_7
	key_8
	key_9
	key_a = 0x41
	key_b
	key_c
	key_d
	key_e
	key_f
	key_g
	key_h
	key_i
	key_j
	key_k
	key_l
	key_m
	key_n
	key_o
	key_p
	key_q
	key_r
	key_s
	key_t
	key_u
	key_v
	key_w
	key_x
	key_y
	key_z
	mod_alt = 0x0001
	mod_control = 0x0002
	mod_shift = 0x0003
	mod_win = 0x0008
	mod_norepeat = 0x4000
}

fn (k Key) str() string {
	return match k {
		.key_0 { '0' }
		.key_1 { '1' }
		.key_2 { '2' }
		.key_3 { '3' }
		.key_4 { '4' }
		.key_5 { '5' }
		.key_6 { '6' }
		.key_7 { '7' }
		.key_8 { '8' }
		.key_9 { '9' }
		.key_a { 'a' }
		.key_b { 'b' }
		.key_c { 'c' }
		.key_d { 'd' }
		.key_e { 'e' }
		.key_f { 'f' }
		.key_g { 'g' }
		.key_h { 'h' }
		.key_i { 'i' }
		.key_j { 'j' }
		.key_k { 'k' }
		.key_l { 'l' }
		.key_m { 'm' }
		.key_n { 'n' }
		.key_o { 'o' }
		.key_p { 'p' }
		.key_q { 'q' }
		.key_r { 'r' }
		.key_s { 's' }
		.key_t { 't' }
		.key_u { 'u' }
		.key_v { 'v' }
		.key_w { 'w' }
		.key_x { 'x' }
		.key_y { 'y' }
		.key_z { 'z' }
		.mod_alt { 'ALT' }
		.mod_control { 'CTRL' }
		.mod_shift { 'SHIFT' }
		.mod_win { 'SUPER' }
		.mod_norepeat { 'NOREPEAT' }
	}
}