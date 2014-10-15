#![no_std]
#![feature(lang_items)]
#![allow(dead_code)]

extern "C" {
	fn c_entry() -> int;
}

#[no_mangle]
pub fn rust_entry() -> int {
    8
}
