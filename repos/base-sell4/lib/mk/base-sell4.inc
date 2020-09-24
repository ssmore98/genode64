include $(BASE_DIR)/lib/mk/base.inc

SRC_CC += capability_space.cc
SRC_CC += thread_start.cc thread_init.cc
SRC_CC += cache.cc
SRC_CC += signal_transmitter.cc signal.cc

LIBS += syscall-sell4 base-sell4-common cxx
