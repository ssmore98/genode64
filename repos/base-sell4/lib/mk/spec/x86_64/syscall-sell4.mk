PLAT := pc99
ARCH := x86

SELL4_ARCH := x86_64
PLAT_BOARD := /$(SELL4_ARCH)
SELL4_WORDBITS := 64
ARCH_INCLUDES := exIPC.h vmenter.h
SELL4_ARCH_INCLUDES := syscalls_syscall.h
include $(REP_DIR)/lib/mk/syscall-sell4.inc

