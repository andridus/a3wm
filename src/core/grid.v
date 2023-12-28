module core

import math
import rand

type GridAddress = string
type WindowAddress = string
struct None {}

pub type GridWindow = GridAddress | WindowAddress | None
@[heap]
pub struct Grid {
pub mut:
	uuid string
	idx int
	direction  WindowPosition
	elem1      GridWindow = None{}
	elem2      GridWindow = None{}
	active1    bool
	active2    bool
	axis       u8 = 50
	// 0-100
	fullscreen bool
	rect       Rect
}

pub fn (gd GridWindow) has_element() bool {
	return match gd {
		GridAddress{ true }
		WindowAddress { true }
		None { false }
	}
}
pub fn (gd GridWindow) get_uuid() !string {
	return match gd {
		GridAddress{ string(gd) }
		WindowAddress { string(gd) }
		None { error('not valid GridWindow') }
	}
}
pub fn (gd GridWindow) get_window_address() !string {
	return match gd {
		WindowAddress { string(gd) }
		else { error('not valid GridWindow') }
	}
}
pub fn (gd GridWindow) get_grid_address() !string {
	return match gd {
		WindowAddress { string(gd) }
		else { error('not valid GridWindow') }
	}
}
pub fn (g &Grid) ptr_str() string {
	return '${g:p}'
}
fn (g &Grid) set_axis(axis u8) {
	mut g0 := unsafe { &g }
	g0.axis = axis
}
fn (g &Grid) get_deep_rects(state &State) !map[string][]int {
	mut rets := map[string][]int{}
	if g.active1 {
		elem1 := g.elem1
		match elem1 {
			WindowAddress {
				hwnd := g.elem1.get_uuid() or { return error('dont find window') }
				rets[hwnd] = g.get_elem_rect_for1().to_list_int()
			}
			GridAddress {
				grid_uuid := g.elem1.get_uuid() or { return error('dont find window') }
				grid := state.get_grid_by_uuid(grid_uuid)
				rects0 := grid.get_deep_rects(state) or { return error('dont find rects') }
				for hwnd, r in rects0 {
					rets[hwnd] = r
				}
			}
			None { return error('dont find elemnt') }
		}
	}
	if g.active2 {
		elem2 := g.elem2
		match elem2 {
			WindowAddress {
				hwnd := g.elem2.get_uuid() or { return error('dont find window') }
				rets[hwnd] = g.get_elem_rect_for2().to_list_int()
			}
			GridAddress {
				grid_uuid := g.elem2.get_uuid() or { return error('dont find window') }
				grid := state.get_grid_by_uuid(grid_uuid)
				rects0 := grid.get_deep_rects(state) or { return error('dont find rects') }
				for hwnd, r in rects0 {
					rets[hwnd] = r
				}
			}
			None { return error('dont find elemnt') }
		}
	}
	return rets
}
pub fn new_grid_for_window(w Window, rect Rect) Grid {
	uuid := rand.uuid_v4()
	return Grid{
		uuid: uuid
		elem1: WindowAddress(w.ptr.str())
		active1: true
		axis: 100
		rect: rect
	}
}
pub fn new_grid_from_before(w1 GridWindow,  w2 GridWindow, axis u8, rect Rect) &Grid {
	uuid := rand.uuid_v4()
	return &Grid{
		uuid: uuid
		elem1: w1
		active1: true
		elem2: w2
		active2: true
		axis: axis
		rect: rect
	}
}
pub fn (g Grid) all_actives() bool {
	return g.active1 && g.active2
}

pub fn (mut g Grid) remove_window(hwnd C.HWND, state &State) (bool, &Grid) {
	println(g)
	println(hwnd)
	pos := g.which_elem_window(hwnd)
	if pos == 1 {
		g.elem1 = None{}
		g.active1 = false
		if g.elem2 is GridAddress {
			uuid := g.elem2.get_uuid() or { return false, unsafe {nil} }
			gd := state.get_grid_by_uuid(uuid)
			gd.restore_parent_size(g)
			return true, gd
		}
		g.axis = 100

		state.replace_grid(g)
	} else if pos == 2 {
		g.elem2 = None{}
		g.active2 = false
		println('here2')

		if g.elem1 is GridAddress {
			uuid := g.elem1.get_uuid() or { return false, unsafe {nil} }
			gd := state.get_grid_by_uuid(uuid)
			gd.restore_parent_size(g)
			return true, gd
		}
		g.axis = 100
		state.replace_grid(g)
	} else {
		println('here3')
		return false, unsafe {nil}
	}

	return false, unsafe {nil}
}

pub fn (mut g Grid) replace_window(pos int, hwnd C.HWND) {

	if pos == 1 {
		g.elem1 = WindowAddress(hwnd.str())
	} else if pos == 2 {
		g.elem2 = WindowAddress(hwnd.str())
	}
}

pub fn (mut g Grid) add_window(window Window, workarea &Workarea, state &State) {
	window_str := window.ptr.str()
	window_active := window.active
	if g.elem1 is None {
		g.elem1 = WindowAddress(window_str)
		g.active1 = window_active
		state.add_windows_reference(window, g, workarea)
	} else if g.elem2 is None {
		g.elem2 = WindowAddress(window_str)
		g.active2 = window_active
		state.add_windows_reference(window, g, workarea)
	} else {
		rect := g.get_splitted_rect(.horizontal)
		grid := new_grid_from_before(g.elem1, g.elem2, g.axis, rect)
		state.add_grid(grid)
		state.update_windows_grid_reference_from_grid(grid)
		state.add_windows_reference(window, g, workarea)
		g.elem1 = GridAddress(grid.uuid)
		g.active1 = true
		g.elem2 = WindowAddress(window_str)
		g.active1 = window_active
		g.axis = 50
		state.replace_grid(g)
		state.replace_workarea(workarea)
		return
	}
	if g.all_actives() {
		g.axis = 50
	}
}

pub fn (g Grid) is_elem_active(el int) bool {
	return match el {
		1 { g.active1 }
		2 { g.active2 }
		else { false }
	}
}

pub fn (g &Grid) restore_parent_size(g_parent &Grid) {
	mut g0 := unsafe { &g}
	match g0.direction {
		.horizontal {
			g0.rect = Rect{...g0.rect, width: g_parent.rect.width}
		}
		.vertical {
			g0.rect = Rect{...g0.rect, height: g_parent.rect.height}
		}
	}
}

pub fn (g Grid) get_total_rect() Rect {
	return g.rect
}
pub fn (g Grid) get_splitted_rect(direction WindowPosition) Rect {
	return match direction {
		.horizontal {
			Rect{
				left: g.rect.left
				top: g.rect.top
				width: g.rect.width/2
				height: g.rect.height
			}
		}
		.vertical {
			Rect{
				left: g.rect.left
				top: g.rect.top
				width: g.rect.width
				height: g.rect.height/2
			}
		}
	}

}
pub fn (g Grid) get_elem_rect_for1() Rect {
	_ := g.elem1.get_uuid() or {return Rect{}}
	left := g.rect.left
	top := g.rect.top
	width := g.rect.width
	height := g.rect.height
	percent := f32(g.axis) / 100.0
	width1 := int(width * percent)
	match g.direction {
		.horizontal {
			return Rect{
				left: left
				top: top
				width: width1
				height: height
			}
		}
		.vertical {
			return Rect{
				left: left
				top: top
				width: width
				height: int(height * percent)
			}
		}
	}
}
pub fn (g Grid) get_elem_rect_for2() Rect {
	_ := g.elem2.get_uuid() or {return Rect{}}
	fix_axis := 100
	cfix_axis := 0
	left := g.rect.left
	top := g.rect.top
	width := g.rect.width
	height := g.rect.height
	percent := f32(math.abs(g.axis - fix_axis)) / 100.0
	cpercent := f32(math.abs(g.axis - cfix_axis)) / 100.0
	width1 := int(width * cpercent)
	width2 := int(width * percent)
	match g.direction {
		.horizontal {
			return Rect{
				left: left + width1
				top: top
				width: width2
				height: height
			}
		}
		.vertical {
			return Rect{
				left: left
				top: top + int(height * percent)
				width: width
				height: int(height * percent)
			}
		}
	}
}

pub fn (g Grid) is_same(pos int, hwnd C.HWND) bool {
	match pos {
		1 {
				addrs := g.elem1.get_window_address() or { return false }
				return addrs == hwnd.str()
			}
		2 {
			addrs := g.elem2.get_window_address() or { return false }
			return addrs == hwnd.str()
		}
		else {}
	}
	return false
}

pub fn (g &Grid) which_elem_window(hwnd C.HWND) int {
	if g.is_same(1, hwnd) {
		return 1
	} else if g.is_same(2, hwnd) {
		return 2
	} else {
		return 0
	}
}

pub fn (g &Grid) parse_axis(rect C.RECT, hwnd C.HWND) Action {
	mut axis := 0
	el := g.which_elem_window(hwnd)
	if el <= 2 {
		total_width := g.rect.width
		match g.direction {
			.horizontal {
				old_top := g.rect.top
				new_top := rect.top
				if math.abs(old_top - new_top) > 3 {
					return .swap_window
				}
				if el == 1 {
					right1 := rect.right - g.rect.left
					axis = int(f32(right1) / total_width * 100.0)
				} else if el == 2 {
					left1 := rect.left - g.rect.left
					axis = int(f32(left1) / total_width * 100.0)
				}
			}
			.vertical {
				// TODO: implement for vertical
			}
		}
	} else {
		debug('not found window')
	}
	if u8(axis) > 100 { return .nothing }
	g.set_axis(u8(axis))
	return .drag_axis
}
