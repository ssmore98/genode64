include $(BASE_DIR)/lib/mk/base-common.inc

LIBS += startup-sell4 syscall-sell4

SRC_CC += rpc_dispatch_loop.cc
SRC_CC += thread.cc thread_myself.cc thread_bootstrap.cc
SRC_CC += capability.cc capability_raw.cc
SRC_CC += stack_area_addr.cc
SRC_CC += platform.cc

