BUILD_DIR=../../build/kernel
KERNEL_ASM_SRCS := $(wildcard *.asm)
KERNEL_C_SRCS := $(wildcard *.c)

KERNEL_OBJS := $(patsubst %.asm, $(BUILD_DIR)/%.o, $(KERNEL_ASM_SRCS)) \
	$(patsubst %.c, $(BUILD_DIR)/%.o, $(KERNEL_C_SRCS))

CC = gcc
CFLAGS = -c -ffreestanding -m64 -mno-red-zone -fno-rtti -O2

all : setup $(KERNEL_OBJS)

$(BUILD_DIR)/%.o : %.asm
	nasm -f elf64 $< -o $@

$(BUILD_DIR)/%.o : %.c 
	$(CC) $(CFLAGS) $< -o $@

.PHONY: setup
setup : 
	mkdir -p $(BUILD_DIR)

.PHONY: clean
clean : 
	rm -f $(BUILD_DIR)/*