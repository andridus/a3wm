module core
import time
fn debug(s string) {
	now := time.now()
	println('${now}: ${s}')
}