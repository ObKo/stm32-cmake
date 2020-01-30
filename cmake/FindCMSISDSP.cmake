SET(CMSIS_COMPONENTS NN DSP)

INCLUDE(FetchContent)

FetchContent_Declare(
    arm_cmsis
    GIT_REPOSITORY https://github.com/ARM-software/CMSIS_5.git
    )

FetchContent_GetProperties(arm_cmsis)
IF(NOT arm_cmsis_POPULATED)
    MESSAGE(STATUS "Getting most recent ARM CMSIS sources")
    FetchContent_Populate(arm_cmsis)
ENDIF()

SET(ARM_CMSIS_DIR ${arm_cmsis_SOURCE_DIR}/CMSIS)

SET(CMSIS_NN_HEADERS
    arm_nnfunctions.h
    arm_nnsupportfunctions.h
    arm_nn_tables.h
    )

SET(CMSIS_DSP_HEADERS
    arm_common_tables.h
    arm_const_structs.h
    arm_helium_utils.h
    arm_math.h
    arm_mve_tables.h
    arm_vec_math.h
    )

IF(CMSIS_FIND_COMPONENTS)
    FOREACH(CMP ${CMSIS_FIND_COMPONENTS})
        FILE(GLOB CMSIS_${CMP}_SOURCES ${ARM_CMSIS_DIR}/${CMP}/Source/*/*.c)    
        LIST(APPEND CMSIS_SOURCES ${CMSIS_${CMP}_SOURCES})
        LIST(REMOVE_DUPLICATES CMSIS_SOURCES)

        LIST(APPEND CMSIS_INCLUDE_DIRS ${ARM_CMSIS_DIR}/${CMP}/Include)
    ENDFOREACH()
ENDIF()

IF(STM32_FAMILY STREQUAL "F0")
    ADD_DEFINITIONS(-DARM_MATH_CM0)
ELSEIF(STM32_FAMILY STREQUAL "F3")
    ADD_DEFINITIONS(-DARM_MATH_CM3)
ELSEIF(STM32_FAMILY STREQUAL "F4")
    #TODO find better solution to this
    ADD_DEFINITIONS(-D__FPU_PRESENT=1)
    ADD_DEFINITIONS(-DARM_MATH_CM4)
ELSEIF(STM32_FAMILY STREQUAL "F7")
    ADD_DEFINITIONS(-DARM_MATH_CM7)
ELSEIF(STM32_FAMILY STREQUAL "L0")
    ADD_DEFINITIONS(-DARM_MATH_CM0PLUS)
ELSE()
    MESSAGE(STATUS "ARM_MATH define not found, see arm_math.h")
ENDIF()
