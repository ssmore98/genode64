BOARD ?= unknown
TARGET = sell4-$(BOARD)
LIBS   = kernel-sell4-$(BOARD)

$(INSTALL_DIR)/$(TARGET):
	$(VERBOSE)ln -sf $(LIB_CACHE_DIR)/kernel-sell4-$(BOARD)/kernel.elf $@
