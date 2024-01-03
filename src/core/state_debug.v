module core

pub fn (state &State) debug() {
	// clear_screen()
	dump(state.workareas)
	for k, g in state.render_grid_arr {
		println('\nworkarea: $k')
		for k0, g0 in g {
			win := unsafe { state.windows[k0] }
			title := win.title.substr_with_check(0,14) or {
				win.title.substr(0,win.title.len)
			}
			s := '{L: ${g0[0]}   T: ${g0[1]}   W: ${g0[2]}   H: ${g0[3]}}'
			println('\t${title} ${s}')
		}
	}
}
