#include <time.h>
#include <sys/time.h>
#include <unistd.h>
#include "lua.h"
#include "lauxlib.h"

static int
lmillisecond(lua_State* L) {
	struct timeval v;
	gettimeofday(&v, NULL);
	uint64_t millisecond = v.tv_sec*1000 + v.tv_usec/1.0e3;
	lua_pushinteger(L, millisecond);
	return 1;
}

static int
lmsleep(lua_State* L) {
    uint32_t millisecond = luaL_checkinteger(L, 1);
	usleep(millisecond * 1000);
    return 0;
}

int luaopen_utils(lua_State* L) {
	luaL_checkversion(L);
	luaL_Reg l1[] = {
		{"millisecond", lmillisecond},
		{"msleep", lmsleep},
		{NULL, NULL},
	};
	luaL_newlib(L, l1);
	return 1;
}