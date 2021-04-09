BUILD_DIR=../../build/bootloader
BOOTLOADER_SRCS := $(wildcard *.asm)
BOOTLOADER_OBJS := $(patsubst %.asm, $(BUILD_DIR)/%.o, $(BOOTLOADER_SRCS))

all : setup $(BOOTLOADER_OBJS) 

$(BUILD_DIR)/%.o : %.asm
	nasm -f elf64 $< -o $@

.PHONY: setup
setup : 
	mkdir -p $(BUILD_DIR)

.PHONY: clean
clean : 
	rm -f $(BUILD_DIR)/*
