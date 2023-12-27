module main

import core

#include <windows.h>
#flag -lgdi32

fn main() {
	instance := C.GetModuleHandleA(unsafe { nil })
	cmd_show := 1
	core.main(instance, cmd_show)
}
