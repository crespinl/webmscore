
muse_create_module(MainAudio)

target_include_directories(MainAudio PRIVATE
    ${MU_ROOT}/src/framework/audio
    ${MU_ROOT}/src/notation
    ${MU_ROOT}/src/project
)

target_sources(MainAudio PRIVATE
    audio.cpp
    audio.h
    audioparams.cpp
    audioparams.h
    audiosynth.cpp
    audiosynth.h

    ${MU_ROOT}/src/playback/internal/playbackcontroller.cpp
    ${MU_ROOT}/src/playback/internal/playbackcontroller.h
    ${MU_ROOT}/src/playback/internal/soundprofilesrepository.cpp
    ${MU_ROOT}/src/playback/internal/soundprofilesrepository.h
    ${MU_ROOT}/src/playback/internal/drumsetloader.cpp
    ${MU_ROOT}/src/playback/internal/drumsetloader.h
)

add_subdirectory(${MU_ROOT}/src/framework/audio          audio)
add_subdirectory(${MU_ROOT}/src/importexport/audioexport audioexport)

target_link_libraries(MainAudio PUBLIC
    muse_audio
    iex_audioexport
    engraving
)
