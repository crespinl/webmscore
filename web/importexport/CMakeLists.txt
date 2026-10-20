
muse_create_module(importexport)

target_include_directories(importexport PRIVATE
    ${MU_ROOT}/src/notation
    ${MU_ROOT}/src/project
    ${MU_ROOT}/src/engraving
)

target_sources(importexport PRIVATE
    ${MU_ROOT}/src/project/internal/notationreadersregister.cpp
    ${MU_ROOT}/src/project/internal/notationreadersregister.h
    ${MU_ROOT}/src/project/internal/notationwritersregister.cpp
    ${MU_ROOT}/src/project/internal/notationwritersregister.h

    ${MU_ROOT}/src/notation/internal/notation.cpp
    ${MU_ROOT}/src/notation/internal/notation.h
    ${MU_ROOT}/src/notation/internal/notationelements.cpp
    ${MU_ROOT}/src/notation/internal/notationelements.h
    ${MU_ROOT}/src/notation/internal/notationpainting.cpp
    ${MU_ROOT}/src/notation/internal/notationpainting.h
    ${MU_ROOT}/src/notation/internal/notationviewstate.cpp
    ${MU_ROOT}/src/notation/internal/notationviewstate.h
    ${MU_ROOT}/src/notation/internal/notationsolomutestate.cpp
    ${MU_ROOT}/src/notation/internal/notationsolomutestate.h
    ${MU_ROOT}/src/notation/internal/notationundostack.cpp
    ${MU_ROOT}/src/notation/internal/notationundostack.h
    ${MU_ROOT}/src/notation/internal/searchcommandsparser.cpp
    ${MU_ROOT}/src/notation/internal/searchcommandsparser.h

    ${MU_ROOT}/src/notation/internal/mscnotationwriter.cpp
    ${MU_ROOT}/src/notation/internal/mscnotationwriter.h

    ${MU_ROOT}/src/notation/internal/masternotation.cpp
    ${MU_ROOT}/src/notation/internal/masternotation.h
    ${MU_ROOT}/src/notation/internal/excerptnotation.cpp
    ${MU_ROOT}/src/notation/internal/excerptnotation.h
    ${MU_ROOT}/src/notation/internal/notationplayback.cpp
    ${MU_ROOT}/src/notation/internal/notationplayback.h
    ${MU_ROOT}/src/notation/internal/masternotationparts.cpp
    ${MU_ROOT}/src/notation/internal/masternotationparts.h
    ${MU_ROOT}/src/notation/internal/notationparts.cpp
    ${MU_ROOT}/src/notation/internal/notationparts.h
    ${MU_ROOT}/src/notationscene/utilities/percussionutilities.cpp
    ${MU_ROOT}/src/notationscene/utilities/percussionutilities.h

    positionjsonwriter.cpp
    positionjsonwriter.h
)

add_subdirectory(${MU_ROOT}/src/importexport/musicxml musicxml)
add_subdirectory(${MU_ROOT}/src/importexport/guitarpro guitarpro)
add_subdirectory(${MU_ROOT}/src/importexport/midi midi)
add_subdirectory(${MU_ROOT}/src/importexport/imagesexport imagesexport)

target_link_libraries(importexport PUBLIC
    iex_musicxml
    iex_guitarpro
    iex_midi
    beatroot
    iex_imagesexport
    engraving
)
