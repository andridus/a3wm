module core

import time
pub fn debug(s string) {
	now := time.now()
	println('${now}: ${s}\n')
}