SELL4_DIR := $(call select_from_ports,sell4)/src/kernel/sel4

#
# Execute the kernel build only at the second build stage when we know
# about the complete build settings (e.g., the 'CROSS_DEV_PREFIX') and the
# current working directory is the library location.
#
ifeq ($(called_from_lib_mk),yes)
all: build_kernel
else
all:
endif

build_kernel:
	$(VERBOSE)cmake \
	          -DCROSS_COMPILER_PREFIX=$(CROSS_DEV_PREFIX) \
			  -DCMAKE_TOOLCHAIN_FILE=$(SELL4_DIR)/gcc.cmake \
			  -G Ninja \
			  -C $(SELL4_DIR)/configs/X64_verified.cmake \
	          $(SELL4_DIR)
	$(VERBOSE)ninja kernel.elf

