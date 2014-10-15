# Bare minimum ARM kernel written in C and Rust.

├── apps<br/>
│   └── hello<br/>
│       ├── hi_c.c<br/>
│       └── hi_rust.rs<br/>
├── boot<br/>
│   ├── linker.ld<br/>
│   └── loader.s<br/>
└── Makefile<br/>

Build different apps using *make app=hello*
