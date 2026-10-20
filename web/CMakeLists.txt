cmake_minimum_required(VERSION 3.22)

project(webmscore LANGUAGES C CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

get_filename_component(MU_ROOT ${CMAKE_CURRENT_LIST_DIR}/.. ABSOLUTE)
set(PROJECT_ROOT_DIR ${MU_ROOT})

set(THIRDPARTY_DIR ${MU_ROOT}/thirdparty)
set(MUSE_FRAMEWORK_PATH ${MU_ROOT})
set(MUSE_FRAMEWORK_SRC_PATH ${MU_ROOT}/src/framework)

set(CMAKE_MODULE_PATH
    ${MU_ROOT}
    ${MU_ROOT}/buildscripts
    ${MU_ROOT}/buildscripts/cmake
    ${MUSE_FRAMEWORK_SRC_PATH}/cmake
    ${CMAKE_MODULE_PATH}
    )

# Load MuseScore version
include(version)

include(GetPlatformInfo)
include(SetupCompileWarnings)
include(SetupCompilerCache)

###########################################
# Configuration
###########################################

# Declares the MUSE_* options with their default values
include(MuseDeclareOptions)

set(MUSE_APP_REVISION "")
set(MUSE_APP_BUILD_NUMBER "${CMAKE_BUILD_NUMBER}")
set(MUSE_APP_INSTALL_PREFIX "\"${CMAKE_INSTALL_PREFIX}\"")
set(MUSE_APP_INSTALL_NAME "\"\"")

set(MUSE_QT_SUPPORT ON)
set(QT_SUPPORT ON)

# webmscore is a single threaded library: the audio engine runs in-process,
# on the same thread as everything else (see MUSE_AUDIO_INLINE_ENGINE)
set(MUSE_THREADS_SUPPORT OFF)
set(MUSE_CONFIGURATION_IS_WEB ON)
set(MUSE_WEB_LIB ON) # building the wasm library (webmscore), not the upstream web app
set(MUSE_MODULE_AUDIO_WORKMODE 1)

set(MUSE_ENABLE_UNIT_TESTS OFF)
set(MUSE_COMPILE_USE_PCH OFF)
set(MUSE_COMPILE_USE_UNITY OFF)
set(MUSE_COMPILE_USE_COMPILER_CACHE ON)

set(QT_ADD_CONCURRENT OFF)
set(QT_ADD_LINGUISTTOOLS OFF)
set(QT_ADD_WEBSOCKET OFF)
set(QT_QPROCESS_SUPPORTED OFF)
set(QT_CONCURRENT_SUPPORTED OFF)

# framework modules
set(MUSE_MODULE_ACCESSIBILITY OFF)
set(MUSE_MODULE_ACTIONS ON)
set(MUSE_MODULE_AUDIO ON)
set(MUSE_MODULE_AUDIO_EXPORT ON)
set(MUSE_MODULE_AUDIO_JACK OFF)
set(MUSE_MODULE_AUDIOPLUGINS OFF)
set(MUSE_MODULE_AUTOBOT OFF)
set(MUSE_MODULE_CLOUD OFF)
set(MUSE_MODULE_DIAGNOSTICS OFF)
set(MUSE_MODULE_DIAGNOSTICS_CRASHPAD_CLIENT OFF)
set(MUSE_MODULE_DOCKWINDOW OFF)
set(MUSE_MODULE_DRAW ON)
set(MUSE_MODULE_EXTENSIONS OFF)
set(MUSE_MODULE_GLOBAL ON)
set(MUSE_MODULE_LANGUAGES OFF)
set(MUSE_MODULE_LEARN OFF)
set(MUSE_MODULE_MEDIA OFF)
set(MUSE_MODULE_MIDI OFF)
set(MUSE_MODULE_MIDIREMOTE OFF)
set(MUSE_MODULE_MPE ON)
set(MUSE_MODULE_MULTIWINDOWS OFF)
set(MUSE_MODULE_MUSESAMPLER OFF)
set(MUSE_MODULE_NETWORK OFF)
set(MUSE_MODULE_SHORTCUTS OFF)
set(MUSE_MODULE_TOURS OFF)
set(MUSE_MODULE_UI OFF)
set(MUSE_MODULE_UI_QML OFF)
set(MUSE_MODULE_UPDATE OFF)
set(MUSE_MODULE_VST OFF)
set(MUSE_MODULE_WORKSPACE OFF)

# MuseScore modules
set(MUE_BUILD_APPSHELL_MODULE OFF)
set(MUE_BUILD_BRAILLE_MODULE OFF)
set(MUE_BUILD_CONVERTER_MODULE OFF)
set(MUE_BUILD_INSPECTOR_MODULE OFF)
set(MUE_BUILD_INSTRUMENTSSCENE_MODULE OFF)
set(MUE_BUILD_MUSESOUNDS_MODULE OFF)
set(MUE_BUILD_NOTATION_MODULE OFF)
set(MUE_BUILD_NOTATIONSCENE_MODULE OFF)
set(MUE_BUILD_PALETTE_MODULE OFF)
set(MUE_BUILD_PLAYBACK_MODULE OFF)
set(MUE_BUILD_PREFERENCES_MODULE OFF)
set(MUE_BUILD_PRINT_MODULE OFF)
set(MUE_BUILD_PROJECT_MODULE OFF)
set(MUE_BUILD_ENGRAVING_QML OFF)
set(MUE_BUILD_ENGRAVING_TESTS OFF)
set(MUE_BUILD_ENGRAVING_DEVTOOLS OFF)
set(MUE_BUILD_ENGRAVING_PLAYBACK ON)
set(MUE_BUILD_IMPORTEXPORT_TESTS OFF)
set(MUE_DOWNLOAD_SOUNDFONT OFF)
set(MUE_INSTALL_SOUNDFONT OFF)
set(MUE_RUN_LRELEASE OFF)

# Generates muse_framework_config.h and includes MuseCreateModule
include(MuseSetupConfiguration)

add_definitions(
    -DENGRAVING_NO_QTEXTDOCUMENT
    -DENGRAVING_NO_INTERACTIVE
    -DDRAW_NO_QSVGRENDER           # QSvgRenderer (QtSvg) depends on QWidget in Qt5, this changes in Qt6
    -DMUSE_MODULE_AUDIO_EXPORT
    -DMUE_BUILD_ENGRAVING_PLAYBACK
    -DMUSE_AUDIO_INLINE_ENGINE     # the audio engine runs in-process, on the main thread
    -DQT_SUPPORT
    -DNDEBUG
    -DQT_NO_DEBUG
    -DCUSTOM_ALLOCATOR_DISABLED    # the custom memory allocator malfunctions ('memory access out of bounds') when destroying and re-creating a new `WebMscore` instance, so disable it

    -DMUSICXML_NO_VALIDATION
    -DMUSICXML_NO_INTERACTIVE
)

include_directories(
    ${CMAKE_CURRENT_LIST_DIR}
    ${MU_ROOT}/thirdparty/dtl
)

# Opus' x86 intrinsic sources are not needed for wasm
set(OPUS_DISABLE_INTRINSICS ON CACHE BOOL "Disable Opus intrinsics for Emscripten" FORCE)
# Emscripten fails to resolve stack protector runtime symbols
set(OPUS_STACK_PROTECTOR OFF CACHE BOOL "Disable Opus stack protector for Emscripten" FORCE)
set(OPUS_FORTIFY_SOURCE OFF CACHE BOOL "Disable Opus fortify for Emscripten" FORCE)

set(CMAKE_EXECUTABLE_SUFFIX ".lib.js")

set(WASM_LINK_FLAGS         "${WASM_LINK_FLAGS} --bind")
set(WASM_LINK_FLAGS         "${WASM_LINK_FLAGS} --source-map-base ./")
set(WASM_LINK_FLAGS         "${WASM_LINK_FLAGS} --no-entry")
set(WASM_LINK_FLAGS         "${WASM_LINK_FLAGS} --emit-symbol-map")
set(WASM_LINK_FLAGS         "${WASM_LINK_FLAGS} -s WASM=1")
set(WASM_LINK_FLAGS         "${WASM_LINK_FLAGS} -s DYNAMIC_EXECUTION=0")
set(WASM_LINK_FLAGS         "${WASM_LINK_FLAGS} -s EXPORT_ES6=1 -s USE_ES6_IMPORT_META=1 -s MODULARIZE=1")
set(WASM_LINK_FLAGS         "${WASM_LINK_FLAGS} -s NODEJS_CATCH_EXIT=0 -s NODEJS_CATCH_REJECTION=0")
set(WASM_LINK_FLAGS         "${WASM_LINK_FLAGS} -s ALLOW_TABLE_GROWTH=1")
set(WASM_LINK_FLAGS         "${WASM_LINK_FLAGS} -s ALLOW_MEMORY_GROWTH=1")
set(WASM_LINK_FLAGS         "${WASM_LINK_FLAGS} -s INITIAL_MEMORY=25MB")
set(WASM_LINK_FLAGS         "${WASM_LINK_FLAGS} -s EXPORTED_RUNTIME_METHODS='[\"ccall\", \"cwrap\", \"stringToUTF8\", \"UTF8ToString\", \"getValue\", \"setValue\", \"HEAPU8\"]'")
set(WASM_LINK_FLAGS         "${WASM_LINK_FLAGS} -s EXPORTED_FUNCTIONS='[\"_malloc\", \"_free\"]'")

set(CMAKE_CXX_FLAGS         "${CMAKE_CXX_FLAGS} -fsigned-char")
set(CMAKE_CXX_FLAGS         "${CMAKE_CXX_FLAGS} -Wno-inconsistent-missing-override")
set(CMAKE_CXX_FLAGS         "${CMAKE_CXX_FLAGS} -Wno-deprecated")
set(CMAKE_CXX_FLAGS         "${CMAKE_CXX_FLAGS} -Wno-deprecated-declarations")
set(CMAKE_CXX_FLAGS         "${CMAKE_CXX_FLAGS} -s USE_ZLIB=1")      # 1 = use zlib from emscripten-ports
set(CMAKE_CXX_FLAGS         "${CMAKE_CXX_FLAGS} -s USE_VORBIS=1")    # 1 = use vorbis from emscripten-ports
set(CMAKE_CXX_FLAGS         "${CMAKE_CXX_FLAGS} -s USE_OGG=1")       # 1 = use ogg from emscripten-ports

set(CMAKE_CXX_FLAGS_DEBUG   "-g4 -s ASSERTIONS=2 -s STACK_OVERFLOW_CHECK=2 -s SAFE_HEAP=1")
set(CMAKE_CXX_FLAGS_RELEASE "-Oz -DNDEBUG -DQT_NO_DEBUG")
set(CMAKE_CXX_FLAGS_DEBUG   "${CMAKE_CXX_FLAGS_DEBUG} -Wall -Wextra -Woverloaded-virtual")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -DQT_NO_DEBUG_OUTPUT")

set(CMAKE_C_FLAGS           "${CMAKE_C_FLAGS}         ${CMAKE_CXX_FLAGS}")
set(CMAKE_C_FLAGS_DEBUG     "${CMAKE_C_FLAGS_DEBUG}   ${CMAKE_CXX_FLAGS_DEBUG}")
set(CMAKE_C_FLAGS_RELEASE   "${CMAKE_C_FLAGS_RELEASE} ${CMAKE_CXX_FLAGS_RELEASE}")

include(EmbedFiles)

###########################################
# Setup external dependencies
###########################################

include(SetupQt6)

include(SetupFreetypeBrotli)

###########################################
# Add source tree
###########################################

add_subdirectory(${MU_ROOT}/src/framework/global global)

add_subdirectory(${MU_ROOT}/src/framework/draw draw)

set(ENGRAVING_NO_ACCESSIBILITY ON)
set(ENGRAVING_NO_API ON) # the QML plugin api needs QProcess, which wasm does not have
add_subdirectory(${MU_ROOT}/src/engraving engraving)

add_subdirectory(${MU_ROOT}/src/framework/mpe mpe)

add_subdirectory(importexport)
add_subdirectory(audio)

add_executable(webmscore
    main.cpp
    score.cpp
    score.h
    wasmres.cpp
    wasmres.h

    ${MU_ROOT}/src/converter/internal/compat/notationmeta.cpp
    ${MU_ROOT}/src/converter/internal/compat/notationmeta.h

    ${MU_ROOT}/src/context/internal/globalcontext.cpp
    ${MU_ROOT}/src/context/internal/globalcontext.h
    ${MU_ROOT}/src/context/internal/playbackstate.cpp
    ${MU_ROOT}/src/context/internal/playbackstate.h
    ${MU_ROOT}/src/project/internal/notationproject.cpp
    ${MU_ROOT}/src/project/internal/notationproject.h
    ${MU_ROOT}/src/notation/internal/notationconfiguration.cpp
    ${MU_ROOT}/src/notation/internal/notationconfiguration.h
    ${MU_ROOT}/src/project/internal/projectaudiosettings.cpp
    ${MU_ROOT}/src/project/internal/projectaudiosettings.h
    ${MU_ROOT}/src/project/internal/projectfileinfoprovider.cpp
    ${MU_ROOT}/src/project/internal/projectfileinfoprovider.h
)

set_target_properties(webmscore PROPERTIES
    LINK_FLAGS ${WASM_LINK_FLAGS}
    AUTOMOC ON
)

target_include_directories(webmscore PUBLIC
    ${PROJECT_BINARY_DIR} # for muse_framework_config.h
    ${MU_ROOT} # for thirdparty/
    ${MU_ROOT}/src/framework/global
    ${MU_ROOT}/src/engraving
    ${MU_ROOT}/src/framework # for global/
    ${MU_ROOT}/src
    ${MU_ROOT}/src/notation
    ${MU_ROOT}/src/project
)

target_link_libraries(webmscore
    ${QT_LIBRARIES}
    muse_global
    engraving
    muse_mpe
    importexport
    MainAudio
    freetype # important for supporting woff2 files
    brotlidec-static
)
