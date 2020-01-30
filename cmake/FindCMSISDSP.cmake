SET(CMSIS_COMPONENTS NN DSP)

SET(CMSIS_NN_HEADERS
    arm_nnfunctions.h
    arm_nnsupportfunctions.h
    arm_nn_tables.h
    )

SET(CMSIS_DSP_HEADERS
    arm_common_tables.h
    arm_const_structs.h
    arm_math.h
    )

IF(CMSIS_FIND_COMPONENTS)
    FOREACH(CMP ${CMSIS_FIND_COMPONENTS})
        FILE(GLOB CMSIS_${CMP}_SOURCES ${STM32Cube_DIR}/Drivers/CMSIS/${CMP}/Source/*/*.c)    
        LIST(APPEND CMSIS_SOURCES ${CMSIS_${CMP}_SOURCES})
        LIST(REMOVE_DUPLICATES CMSIS_SOURCES)

        FIND_PATH(CMSIS_${CMP}_INCLUDE_DIR ${CMSIS_${CMP}_HEADERS}
            HINTS ${STM32Cube_DIR}/Drivers/CMSIS/${CMP}/Include
            CMAKE_FIND_ROOT_PATH_BOTH
            )
        LIST(APPEND CMSIS_INCLUDE_DIRS ${CMSIS_${CMP}_INCLUDE_DIR})
    ENDFOREACH()
ENDIF()


