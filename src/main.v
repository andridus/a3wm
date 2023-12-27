module main

import core

#include <windows.h>

fn main() {
	instance := C.GetModuleHandleA(unsafe { nil })
	cmd_show := 1
	core.main(instance, cmd_show)
}
