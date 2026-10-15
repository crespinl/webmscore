# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-CLA-applies
#
# MuseScore
# Music Composition & Notation
#
# Copyright (C) 2024 MuseScore Limited
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

if (MUE_COMPILE_USE_SYSTEM_HARFBUZZ)
    find_package(HarfBuzz)

    if (HarfBuzz_FOUND)
        message(STATUS "Found HarfBuzz")

        # See HarfBuzz's harfbuzz-config.cmake, which is quite minimalistic
        set(HARFBUZZ_LIBRARIES harfbuzz::harfbuzz)
        set(HARFBUZZ_INCLUDE_DIRS ${HARFBUZZ_INCLUDE_DIR})

        return()
    else()
        message(WARNING "Set MUE_COMPILE_USE_SYSTEM_HARFBUZZ=ON, but system harfbuzz not found, built-in will be used")
    endif()
endif()

# If not MUE_COMPILE_USE_SYSTEM_HARFBUZZ, or if it was not found,
# download and build harfbuzz
#
# The harfbuzz/7.1.0 recipe that used to be downloaded from musescore/muse_deps
# does not exist anymore, so the official release is fetched instead.
# harfbuzz uses the `freetype` target by itself when it exists.

include(FetchContent)
if (POLICY CMP0135)
    cmake_policy(SET CMP0135 NEW)
endif()

FetchContent_Declare(harfbuzz
    URL https://github.com/harfbuzz/harfbuzz/releases/download/7.1.0/harfbuzz-7.1.0.tar.xz
    URL_HASH SHA256=f135a61cd464c9ed6bc9823764c188f276c3850a8dc904628de2a87966b7077b
)

set(HB_HAVE_FREETYPE ON)

# harfbuzz is only used as a static library of this build: no install rules
# (they would also require the `freetype` target to be in an export set)
set(SKIP_INSTALL_ALL ON)

FetchContent_MakeAvailable(harfbuzz)

unset(SKIP_INSTALL_ALL)

# Qt already bundles harfbuzz (libQt6BundledHarfbuzz.a), which is linked too.
# harfbuzz builds a single object (the amalgamated harfbuzz.cc) defining every
# symbol: it clashes with Qt's one ("duplicate symbol"). Build one object per
# file instead, so the linker only takes the missing ones (e.g. hb-ft.cc).
file(STRINGS ${harfbuzz_SOURCE_DIR}/src/harfbuzz.cc harfbuzz_includes REGEX "^#include \"hb-.*\\.cc\"")
set(harfbuzz_sources)
foreach(harfbuzz_include IN LISTS harfbuzz_includes)
    string(REGEX REPLACE "^#include \"(.*)\"" "\\1" harfbuzz_source "${harfbuzz_include}")
    list(APPEND harfbuzz_sources ${harfbuzz_SOURCE_DIR}/src/${harfbuzz_source})
endforeach()
set_property(TARGET harfbuzz PROPERTY SOURCES ${harfbuzz_sources})

# In incremental/cache-reuse builds, harfbuzz can be rebuilt independently
# from draw targets, so it must carry freetype includes explicitly.
if (FREETYPE_INCLUDE_DIRS)
    target_include_directories(harfbuzz PRIVATE ${FREETYPE_INCLUDE_DIRS})
endif()

target_no_warning(harfbuzz -Wno-conversion)
target_no_warning(harfbuzz -Wno-unused-parameter)
target_no_warning(harfbuzz -Wno-unused-variable)
target_no_warning(harfbuzz -WMSVC-no-hides-previous)
target_no_warning(harfbuzz -WMSVC-no-unreachable)

#add_subdirectory(thirdparty/msdfgen)

set(HARFBUZZ_LIBRARIES harfbuzz)
set(HARFBUZZ_INCLUDE_DIRS ${harfbuzz_SOURCE_DIR}/src)
