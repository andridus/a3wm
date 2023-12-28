module main

import app

#include <windows.h>
#flag -lgdi32

fn main() {
	instance := C.GetModuleHandleA(unsafe { nil })
	cmd_show := 1
	app.entrypoint(instance, cmd_show)
}
