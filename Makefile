BUILD_DIR=./build
SRC_DIR=./src

BOOTLOADER_SRCS := $(wildcard $(SRC_DIR)/bootloader/*.asm)
BOOTLOADER_OBJS := $(patsubst $(SRC_DIR)/bootloader/%.asm, $(BUILD_DIR)/bootloader/%.o, $(BOOTLOADER_SRCS))
KERNEL_ASM_SRCS := $(wildcard $(SRC_DIR)/kernel/*.asm)
KERNEL_C_SRCS   := $(wildcard $(SRC_DIR)/kernel/*.c)
KERNEL_OBJS     := $(patsubst $(SRC_DIR)/kernel/%.asm, $(BUILD_DIR)/kernel/%.o, $(KERNEL_ASM_SRCS)) \
	$(patsubst $(SRC_DIR)/kernel/%.c, $(BUILD_DIR)/kernel/%.o, $(KERNEL_C_SRCS))

LINKER_FILE = $(SRC_DIR)/linker.ld
LD_OPTIONS = -nostdlib -Map $(BUILD_DIR)/img/os.map -print-gc-sections

OS = $(BUILD_DIR)/img/os.o
DISK_IMG = $(BUILD_DIR)/img/disk.img

all : bootloader kernel $(OS) diskimage 

.PHONY: bootloader 
bootloader : 
	make -C $(SRC_DIR)/bootloader 

.PHONY: kernel 
kernel : 
	make -C $(SRC_DIR)/kernel 

$(OS) : $(BOOTLOADER_OBJS) $(KERNEL_OBJS)
	mkdir -p $(BUILD_DIR)/img
	ld -T $(LINKER_FILE) $(BOOTLOADER_OBJS) $(KERNEL_OBJS) $(LD_OPTIONS) -o $@.elf64
	objcopy -O binary $@.elf64 $@

diskimage: 
	dd if=/dev/zero of=$(DISK_IMG) bs=512 count=2880
	
	# This is bootloader - Sector 1: boot, Sector 2+: boot2 , kernel
	dd conv=notrunc if=$(OS) of=$(DISK_IMG) bs=512 seek=0
	
.PHONY: clean
clean:
	rm -f $(BUILD_DIR)/img/*
	make -C $(SRC_DIR)/bootloader clean
	make -C $(SRC_DIR)/kernel clean