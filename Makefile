# Settings
LLVM_ROOT   :=/usr/lib/llvm-3.4
LLVM_TARGET := arm-linux-noeabi
GCC_PREFIX  := arm-none-eabi-
RUST_ROOT   := /usr/local

# Rust toolchain commands
RUSTC       := $(RUST_ROOT)/bin/rustc
RUSTCFLAGS  := -O --target $(LLVM_TARGET) -C soft-float -Z no-landing-pads --crate-type rlib -g
LLC         := $(LLVM_ROOT)/bin/llc

# GCC toolchain commands
AS          := $(GCC_PREFIX)as
CC          := $(GCC_PREFIX)gcc
LD          := $(GCC_PREFIX)ld
GDB         := $(GCC_PREFIX)gdb
OBJCOPY     := $(GCC_PREFIX)objcopy

# QEMU Tools
QEMU        := QEMU_AUDIO_DRV=none qemu-system-arm
QEMUFLAGS   := -nographic -M versatilepb -m 64M -serial stdio

BOOT_DIR    := boot
OBJ_DIR     := build
app         ?= hello
APP_DIR     := apps/$(app)
SOURCES     := $(wildcard $(APP_DIR)/*.rs) $(wildcard $(APP_DIR)/*.c)
OBJS        := $(OBJ_DIR)/loader.o $(foreach file, $(notdir $(SOURCES)), $(OBJ_DIR)/$(basename $(file)).o)
BINARY      := $(OBJ_DIR)/$(app).bin

.PHONY: all clean


all: $(OBJ_DIR) $(BINARY)

$(OBJ_DIR):
	@mkdir -p $(OBJ_DIR)

clean:
	rm -rf $(OBJ_DIR)

run: all
	$(QEMU) $(QEMUFLAGS) -kernel $(BINARY)


# Keep intermediate files
.SECONDARY:

# Rust code is transformed .rs -> .bc -> .s -> .o
$(OBJ_DIR)/%.o: $(OBJ_DIR)/%.s
	$(AS) -g $^ -o $@

$(OBJ_DIR)/%.s: $(OBJ_DIR)/%.bc
	$(LLC) $(LLCFLAGS) $^ -o $@

$(OBJ_DIR)/%.bc: $(APP_DIR)/%.rs
	$(RUSTC) $(RUSTCFLAGS) $^ --emit bc --out-dir $(OBJ_DIR)
	
# C code can be compiled directly
$(OBJ_DIR)/%.o: $(APP_DIR)/%.c
	$(CC) -c -mcpu=arm926ej-s -g $^ -o $@

# We need the boot code
$(OBJ_DIR)/%.o: $(BOOT_DIR)/%.s
	$(AS) -mcpu=arm926ej-s -g $^ -o $@

# Create the kernel elf file and binary
$(OBJ_DIR)/$(app).elf: $(OBJS)
	 $(LD) -T $(BOOT_DIR)/linker.ld $(OBJS) -o $@

$(OBJ_DIR)/%.bin: $(OBJ_DIR)/%.elf
	$(OBJCOPY) -O binary $^ $@
