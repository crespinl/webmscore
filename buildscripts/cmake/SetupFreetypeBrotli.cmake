##
## Brotli, needed by FreeType to support woff2 fonts
##
## NOTE FreeType itself is added by the draw module (see draw/cmake/SetupFreeType.cmake),
## here we only provide brotli and enable the woff2 support of FreeType.
##

set(SKIP_INSTALL_ALL TRUE)
set(BROTLI_DISABLE_TESTS ON CACHE BOOL "Disable brotli tests" FORCE)

set(BROTLIDEC_FOUND TRUE)
set(BROTLIDEC_LIBRARIES brotlidec-static brotlicommon-static)
set(BROTLIDEC_INCLUDE_DIRS ${MU_ROOT}/thirdparty/brotli/c/include)

add_compile_definitions(FT_CONFIG_OPTION_USE_BROTLI)
include_directories(${BROTLIDEC_INCLUDE_DIRS})

# The bundled brotli still declares compatibility with very old CMake versions
set(CMAKE_POLICY_VERSION_MINIMUM 3.5)
add_subdirectory(${MU_ROOT}/thirdparty/brotli brotli)
unset(CMAKE_POLICY_VERSION_MINIMUM)
