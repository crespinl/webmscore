
CPUS	  := $(shell getconf _NPROCESSORS_ONLN 2>/dev/null || getconf NPROCESSORS_ONLN 2>/dev/null || echo 1)
MU_ROOT	  := $(dir ${CURDIR})

# EMBED_PRELOADS = "OFF"
# BUILD_NUMBER   = $(shell git rev-parse --short=7 HEAD)

# MuseScore 4.7 requires Qt >= 6.8, the wasm build is done with Qt 6.10 (single threaded)
Qt6_VER	 ?= 6.10.2
QT6_ROOT ?= ../../build.qt6/${Qt6_VER}

# change these paths to match your Qt6 installation
export CMAKE_PREFIX_PATH	=	${QT6_ROOT}/wasm_singlethread
export CMAKE_TOOLCHAIN_FILE	=	$(CMAKE_PREFIX_PATH)/lib/cmake/Qt6/qt.toolchain.cmake
export QT_HOST_PATH			=	${QT6_ROOT}/gcc_64

# setup ccache
export CCACHE_CPP2          =   true
export CCACHE_BASEDIR		=	${MU_ROOT}
export CCACHE_DIR			=	${MU_ROOT}/.ccache
export CCACHE_COMPRESS		=	true

export NODE_OPTIONS			=	--max_old_space_size=4096

release:
	cmake -S . -B build.release -GNinja                           \
	  -DCMAKE_BUILD_TYPE=Release                                   \
	  -DEMBED_PRELOADS="${EMBED_PRELOADS}"                          \
	  -DCMAKE_TOOLCHAIN_FILE="${CMAKE_TOOLCHAIN_FILE}"               \
	  -DQT_HOST_PATH="${QT_HOST_PATH}"                                \
	  -DCMAKE_BUILD_NUMBER="${BUILD_NUMBER}";                          \
	  cmake --build build.release -j ${CPUS};                           \
	  mv ./build.release/webmscore.* ../web-public;                      \

debug:
	cmake -S . -B build.debug -GNinja                              \
	  -DCMAKE_BUILD_TYPE=Debug                                      \
	  -DEMBED_PRELOADS="${EMBED_PRELOADS}"                           \
	  -DCMAKE_TOOLCHAIN_FILE="${CMAKE_TOOLCHAIN_FILE}"                \
	  -DQT_HOST_PATH="${QT_HOST_PATH}"                                 \
	  -DCMAKE_BUILD_NUMBER="${BUILD_NUMBER}";                           \
	  cmake --build build.debug -j ${CPUS};                              \
	  mv ./build.debug/webmscore.* ../web-public;                         \

#
# clean out of source build
#
clean:
	-rm -rf build.debug build.release
	-rm -rf ../web-public/.cache
	-rm ../web-public/webmscore.*

clean-ccache:
	-rm -rf ../.ccache
