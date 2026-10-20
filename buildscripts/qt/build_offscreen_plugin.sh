#!/usr/bin/env bash
#
# Builds the Qt `offscreen` QPA platform plugin for wasm.
#
# webmscore runs headless (in a worker, or in Node.js), so it cannot use the `wasm`
# platform plugin shipped by Qt, which needs a DOM. Qt does not build the `offscreen`
# plugin for wasm, so we build it here and commit the result (see ./plugins and ./lib),
# the CI copies it into the Qt installation.
#
# Re-run this script when the Qt or emsdk version changes.
#
# Usage:
#   QT6_ROOT=/path/to/Qt/6.10.2 ./buildscripts/qt/build_offscreen_plugin.sh
#
# Requirements:
#   - the emsdk environment is active (source emsdk_env.sh)
#   - the Qt wasm build, the Qt host build and the Qt sources are installed, e.g.
#       aqt install-qt   linux  desktop 6.10.2 linux_gcc_64      --outputdir ${QT6_ROOT}/..
#       aqt install-qt   all_os wasm    6.10.2 wasm_singlethread --outputdir ${QT6_ROOT}/..
#       aqt install-src  linux  desktop 6.10.2 --archives qtbase --outputdir ${QT6_ROOT}/..

set -e

QT6_ROOT="${QT6_ROOT:?set QT6_ROOT to the Qt installation, e.g. /path/to/Qt/6.10.2}"
QT_WASM="${QT6_ROOT}/wasm_singlethread"
QT_HOST="${QT6_ROOT}/gcc_64"
QT_SRC="${QT6_ROOT}/Src/qtbase/src/plugins/platforms/offscreen"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK="$(mktemp -d)"

mkdir -p "${WORK}/src"
cp "${QT_SRC}"/main.cpp "${QT_SRC}"/offscreen.json "${QT_SRC}"/qoffscreen*.cpp "${QT_SRC}"/qoffscreen*.h "${WORK}/src/"
rm -f "${WORK}/src/qoffscreenintegration_x11.cpp" "${WORK}/src/qoffscreenintegration_x11.h"

# The plugin assumes a unix platform: for wasm, the generic unix event dispatcher and font
# database are not available, the wasm ones are used instead.
python3 - "${WORK}/src/qoffscreenintegration.cpp" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
s = s.replace("""#if defined(Q_OS_UNIX)
#include <QtGui/private/qgenericunixeventdispatcher_p.h>""",
"""#if defined(Q_OS_WASM)
#include <QtCore/private/qeventdispatcher_wasm_p.h>
#include <QtCore/private/qwasmsuspendresumecontrol_p.h>
#include <QtGui/private/qgenericunixfontdatabase_p.h>
#elif defined(Q_OS_UNIX)
#include <QtGui/private/qgenericunixeventdispatcher_p.h>""")
s = s.replace("""#if defined(Q_OS_UNIX)
#if defined(Q_OS_MAC)
    m_fontDatabase.reset(new QCoreTextFontDatabaseEngineFactory<QCoreTextFontEngine>);""",
"""#if defined(Q_OS_WASM)
    m_fontDatabase.reset(new QGenericUnixFontDatabase());
#elif defined(Q_OS_UNIX)
#if defined(Q_OS_MAC)
    m_fontDatabase.reset(new QCoreTextFontDatabaseEngineFactory<QCoreTextFontEngine>);""")
s = s.replace("""#if defined(Q_OS_UNIX)
    return createUnixEventDispatcher();""",
"""#if defined(Q_OS_WASM)
    // Same event dispatcher as the one of the `wasm` platform plugin
    return new QEventDispatcherWasm(std::make_shared<QWasmSuspendResumeControl>());""")
open(p, 'w').write(s)
PY

cat > "${WORK}/CMakeLists.txt" <<'EOF'
cmake_minimum_required(VERSION 3.22)
project(qoffscreen LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS Core Gui CorePrivate GuiPrivate)

set(CMAKE_AUTOMOC ON)

qt_add_plugin(QOffscreenIntegrationPlugin
    STATIC
    OUTPUT_NAME qoffscreen
    PLUGIN_TYPE platforms
    CLASS_NAME QOffscreenIntegrationPlugin
)

target_sources(QOffscreenIntegrationPlugin PRIVATE
    src/main.cpp
    src/qoffscreencommon.cpp
    src/qoffscreenintegration.cpp
    src/qoffscreenwindow.cpp
)

target_compile_definitions(QOffscreenIntegrationPlugin PRIVATE QT_NO_FOREACH)
target_include_directories(QOffscreenIntegrationPlugin PRIVATE src)
target_link_libraries(QOffscreenIntegrationPlugin PRIVATE
    Qt::Core Qt::CorePrivate Qt::Gui Qt::GuiPrivate)
EOF

cmake -S "${WORK}" -B "${WORK}/build" -GNinja                                   \
    -DCMAKE_BUILD_TYPE=Release                                                  \
    -DCMAKE_TOOLCHAIN_FILE="${QT_WASM}/lib/cmake/Qt6/qt.toolchain.cmake"        \
    -DQT_HOST_PATH="${QT_HOST}"
cmake --build "${WORK}/build"

mkdir -p "${HERE}/plugins/platforms/objects-Release/QOffscreenIntegrationPlugin_init"
cp "${WORK}/build/libqoffscreen.a" "${HERE}/plugins/platforms/"
cp "${WORK}/build/CMakeFiles/QOffscreenIntegrationPlugin_init.dir/QOffscreenIntegrationPlugin_init.cpp.o" \
   "${HERE}/plugins/platforms/objects-Release/QOffscreenIntegrationPlugin_init/"

echo "Done. Note: the cmake package files in ${HERE}/lib/cmake/Qt6Gui may need their"
echo "version numbers updated when the Qt version changes."
