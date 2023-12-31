module core

import time
#include <stdio.h>
pub fn clear_screen() {
	unsafe { C.system('cls'.str) } 
}
pub fn debug(s string) {
	now := time.now()
	println('${now}: ${s}\n')
}