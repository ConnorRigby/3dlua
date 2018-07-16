LUA_VERSION := 5.3.4
LUA_NAME := lua-$(LUA_VERSION)
LUA_DL := $(LUA_NAME).tar.gz
LUA_DL_URL := "https://www.lua.org/ftp/$(LUA_DL)"
LUA_SRC_DIR := $(BUILD)/$(LUA_NAME)/src
LUA_INSTALL_DIR := $(BUILD)/$(LUA_NAME)

LUA_INCLUDE_DIR := $(LUA_INSTALL_DIR)/include
LUA_LIBDIR := $(LUA_INSTALL_DIR)/lib

# for external thins to use.
LUA_CFLAGS := -I$(LUA_INCLUDE_DIR)
LUA_LDFLAGS := -L$(LUA_LIBDIR)

LUA_LIB := $(LUA_LIBDIR)/liblua.a
LUA_BIN := $(PRIV_DIR)/lua
LUA_C   := $(PRIV_DIR)/luac

LUA_BUILD_CFLAGS ?= -g -Wall -O2 -fPIC $(ARCH)

LUA_BUILD_LDFLAGS ?= -g $(ARCH) -Wl,-Map,$(notdir $*.map) -lm

LUA_TARGET := generic

# Add build targets to global manifest.
# Don't add a clean task here, since it doesn't really need to ever be rebuilt.
# BUILD += $(LUA_LIB) $(LUA_BIN) $(LUA_C)
# PHONY += lua_clean lua_fullclean

$(LUA_SRC_DIR):
	$(MKDIR_P)  $(LUA_INSTALL_DIR)
	$(WGET)   $(LUA_DL_URL)
	$(TAR_XF) $(LUA_DL)
	$(RM)     $(LUA_DL)
	$(MV)     $(LUA_NAME) $(BUILD)
	cd $(BUILD)/$(LUA_NAME) && patch -p1 -i ../../lua/lua.patch

$(LUA_INSTALL_DIR):
	mkdir -p $(LUA_INSTALL_DIR)

$(LUA_LIB): | $(LUA_INSTALL_DIR) $(LUA_SRC_DIR)
	cd $(BUILD)/$(LUA_NAME) && $(MAKE) CC=$(CC) MYCFLAGS="$(LUA_BUILD_CFLAGS) -fPIC -DLUA_COMPAT_5_2 -DLUA_COMPAT_5_1" MYLDFLAGS="$(LUA_BUILD_LDFLAGS)" $(LUA_TARGET)
	cd $(BUILD)/$(LUA_NAME) && $(MAKE) CC=$(CC) -e TO_LIB="liblua.a liblua.so liblua.so.$(LUA_VERSION)" INSTALL_DATA='cp -d' INSTALL_TOP=$(LUA_INSTALL_DIR) INSTALL_MAN= INSTALL_LMOD= INSTALL_CMOD= install

lua_clean:
	cd $(LUA_SRC_DIR) && make clean

lua_fullclean: lua_clean
	$(RM) -r $(BUILD)/$(LUA_NAME)
	$(RM) -r $(LUA_INSTALL_DIR)
