# Users of this package should not need to run this makefile.
#

# First build a static rocksdb lib.
# The build script already does this but you need to add a couple of options to the static build.
# Make the line look like:
# OPT ?= -O2 -DNDEBUG -fPIC -D_GLIBCXX_USE_CXX11_ABI=0

# The -fPIC enables linking the static lib into the object we will build.
# -D_GLIBCXX_USE_CXX11_ABI turns off the new c++11 abi. This means the build will be back compatible with
# older linux versions.

# Then set the source:

ROCKSDB_SOURCE=rocksdb/
DART_SDK=dart-sdk/

LIBS=$(ROCKSDB_SOURCE)/build/librocksdb.a
# Select prod/debug args
ARGS=-O2 -Wall -D_GLIBCXX_USE_CXX11_ABI=0 -std=c++11
# ARGS=-g -O0 -Wall -D_GLIBCXX_USE_CXX11_ABI=0

UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
	LIB_NAME = librocksdb.dylib
	ARGS_LINK = -dynamic -undefined dynamic_lookup
endif
ifeq ($(UNAME_S),Linux)
	LIB_NAME = librocksdb.so
	ARGS_LINK = -shared -Wl,-soname,$(LIB_NAME)
endif

all: lib/librocksdb.so

lib/rocksdb.o: lib/rocksdb.cc
	g++ $(ARGS) -fPIC -I$(DART_SDK) -I$(ROCKSDB_SOURCE)/include -DDART_SHARED_LIB -c lib/rocksdb.cc -o lib/rocksdb.o

lib/librocksdb.so: lib/rocksdb.o
	gcc $(ARGS) lib/rocksdb.o $(ARGS_LINK) -o lib/$(LIB_NAME) $(LIBS)

clean:
	rm -f lib/*.o lib/*.so lib/*.dylib
