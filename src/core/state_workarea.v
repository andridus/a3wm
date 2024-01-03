module core

pub fn (state &State) replace_workarea(workarea Workarea) &Workarea {
	mut state0 := unsafe {&state}
	state0.workareas[workarea.idx] = workarea
	return &state0.workareas[workarea.idx]
}
