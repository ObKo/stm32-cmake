IF(STM32_CHIP_TYPE OR STM32_CHIP)
    IF(NOT STM32_CHIP_TYPE)
        STM32_GET_CHIP_TYPE(${STM32_CHIP} STM32_CHIP_TYPE)
        IF(NOT STM32_CHIP_TYPE)
            MESSAGE(FATAL_ERROR "Unknown chip: ${STM32_CHIP}. Try to use STM32_CHIP_TYPE directly.")
        ENDIF()
        MESSAGE(STATUS "${STM32_CHIP} is ${STM32_CHIP_TYPE} device")
    ENDIF()
    STRING(TOLOWER ${STM32_CHIP_TYPE} STM32_CHIP_TYPE_LOWER)
ENDIF()

SET(CMSIS_COMMON_HEADERS
    arm_common_tables.h
    arm_const_structs.h
    arm_math.h
    core_cmFunc.h
    core_cmInstr.h
    core_cmSimd.h
)

IF(STM32_FAMILY STREQUAL "F1")
    IF(NOT STM32Cube_DIR)
        SET(STM32Cube_DIR "/opt/STM32Cube_FW_F1_V1.2.0")
        MESSAGE(STATUS "No STM32Cube_DIR specified, using default: " ${STM32Cube_DIR})
    ENDIF()

    LIST(APPEND CMSIS_COMMON_HEADERS core_cm3.h)
    SET(CMSIS_DEVICE_HEADERS stm32f1xx.h system_stm32f1xx.h)
    SET(CMSIS_DEVICE_SOURCES system_stm32f1xx.c)
ELSEIF(STM32_FAMILY STREQUAL "F2")
    IF(NOT STM32Cube_DIR)
        SET(STM32Cube_DIR "/opt/STM32Cube_FW_F2_V1.1.1")
        MESSAGE(STATUS "No STM32Cube_DIR specified, using default: " ${STM32Cube_DIR})
    ENDIF()

    STRING(REGEX REPLACE "^(2[01]7).[BCDEFG]" "\\1" STM32_DEVICE_NUM ${STM32_CHIP_TYPE})
    SET(CMSIS_STARTUP_SOURCE startup_stm32f${STM32_DEVICE_NUM}xx.s)

    LIST(APPEND CMSIS_COMMON_HEADERS core_cm4.h)
    SET(CMSIS_DEVICE_HEADERS stm32f2xx.h system_stm32f2xx.h)
    SET(CMSIS_DEVICE_SOURCES system_stm32f2xx.c)
ELSEIF(STM32_FAMILY STREQUAL "F3")
    IF(NOT STM32Cube_DIR)
        SET(STM32Cube_DIR "/opt/STM32Cube_FW_F3_V1.6.0")
        MESSAGE(STATUS "No STM32Cube_DIR specified, using default: " ${STM32Cube_DIR})
    ENDIF()

    STRING(REGEX REPLACE "^(3..).(.)" "\\1x\\2" STM32_STARTUP_NAME ${STM32_CODE})
    STRING(TOLOWER ${STM32_STARTUP_NAME} STM32_STARTUP_NAME_LOWER)
    SET(CMSIS_STARTUP_SOURCE startup_stm32f${STM32_STARTUP_NAME_LOWER}.s)

    LIST(APPEND CMSIS_COMMON_HEADERS core_cm4.h)
    SET(CMSIS_DEVICE_HEADERS stm32f3xx.h system_stm32f3xx.h)
    SET(CMSIS_DEVICE_SOURCES system_stm32f3xx.c)
ELSEIF(STM32_FAMILY STREQUAL "F4")
    IF(NOT STM32Cube_DIR)
        SET(STM32Cube_DIR "/opt/STM32Cube_FW_F4_V1.8.0")
        MESSAGE(STATUS "No STM32Cube_DIR specified, using default: " ${STM32Cube_DIR})
    ENDIF()

    LIST(APPEND CMSIS_COMMON_HEADERS core_cm4.h)
    SET(CMSIS_DEVICE_HEADERS stm32f4xx.h system_stm32f4xx.h)
#    SET(CMSIS_DEVICE_SOURCES system_stm32f4xx.c)
ELSEIF(STM32_FAMILY STREQUAL "F7")
    IF(NOT STM32Cube_DIR)
        SET(STM32Cube_DIR "/opt/STM32Cube_FW_F7_V1.3.0")
        MESSAGE(STATUS "No STM32Cube_DIR specified, using default: " ${STM32Cube_DIR})
    ENDIF()

    LIST(APPEND CMSIS_COMMON_HEADERS core_cm7.h)
    SET(CMSIS_DEVICE_HEADERS stm32f7xx.h system_stm32f7xx.h)
    SET(CMSIS_DEVICE_SOURCES system_stm32f7xx.c)
ELSEIF(STM32_FAMILY STREQUAL "F0")
    IF(NOT STM32Cube_DIR)
        SET(STM32Cube_DIR "/opt/STM32Cube_FW_F0_V1.4.0")
        MESSAGE(STATUS "No STM32Cube_DIR specified, using default: " ${STM32Cube_DIR})
    ENDIF()

    LIST(APPEND CMSIS_COMMON_HEADERS core_cm3.h)
    SET(CMSIS_DEVICE_HEADERS stm32f0xx.h system_stm32f0xx.h)
    SET(CMSIS_DEVICE_SOURCES system_stm32f0xx.c)
ELSEIF(STM32_FAMILY STREQUAL "L0")
    IF(NOT STM32Cube_DIR)
        SET(STM32Cube_DIR "/opt/STM32Cube_FW_L0_V1.7.0")
        MESSAGE(STATUS "No STM32Cube_DIR specified, using default: " ${STM32Cube_DIR})
    ENDIF()

    LIST(APPEND CMSIS_COMMON_HEADERS core_cm0.h)
    SET(CMSIS_DEVICE_HEADERS stm32l0xx.h system_stm32l0xx.h)
    SET(CMSIS_DEVICE_SOURCES system_stm32l0xx.c)
    IF(NOT CMSIS_STARTUP_SOURCE)
        SET(CMSIS_STARTUP_SOURCE startup_stm32l${STM32_CHIP_TYPE_LOWER}.s)
    ENDIF()
ELSEIF(STM32_FAMILY STREQUAL "L1")
    IF(NOT STM32Cube_DIR)

        SET(STM32Cube_DIR "/opt/STM32Cube_FW_L1_V1.5.0")
        MESSAGE(WARNING "No STM32Cube_DIR specified, using default: " ${STM32Cube_DIR})
    ENDIF()

    LIST(APPEND CMSIS_COMMON_HEADERS core_cm3.h)
    SET(CMSIS_DEVICE_HEADERS stm32l1xx.h system_stm32l1xx.h)
    SET(CMSIS_DEVICE_SOURCES system_stm32l1xx.c)
    IF(NOT CMSIS_STARTUP_SOURCE)
        SET(CMSIS_STARTUP_SOURCE startup_stm32l${STM32_CHIP_TYPE_LOWER}.s)
    ENDIF()
ENDIF()

IF(NOT CMSIS_STARTUP_SOURCE)
    SET(CMSIS_STARTUP_SOURCE startup_stm32f${STM32_CHIP_TYPE_LOWER}.s)
ENDIF()

FIND_PATH(CMSIS_COMMON_INCLUDE_DIR ${CMSIS_COMMON_HEADERS}
    PATH_SUFFIXES include stm32${STM32_FAMILY_LOWER} cmsis
    HINTS ${STM32Cube_DIR}/Drivers/CMSIS/Include/
    CMAKE_FIND_ROOT_PATH_BOTH
)

FIND_PATH(CMSIS_DEVICE_INCLUDE_DIR ${CMSIS_DEVICE_HEADERS}
    PATH_SUFFIXES include stm32${STM32_FAMILY_LOWER} cmsis
    HINTS ${STM32Cube_DIR}/Drivers/CMSIS/Device/ST/STM32${STM32_FAMILY}xx/Include
    CMAKE_FIND_ROOT_PATH_BOTH
)

SET(CMSIS_INCLUDE_DIRS
    ${CMSIS_DEVICE_INCLUDE_DIR}
    ${CMSIS_COMMON_INCLUDE_DIR}
)

FOREACH(SRC ${CMSIS_DEVICE_SOURCES})
    SET(SRC_FILE SRC_FILE-NOTFOUND)
    FIND_FILE(SRC_FILE ${SRC}
        PATH_SUFFIXES src stm32${STM32_FAMILY_LOWER} cmsis
        HINTS ${STM32Cube_DIR}/Drivers/CMSIS/Device/ST/STM32${STM32_FAMILY}xx/Source/Templates/
        CMAKE_FIND_ROOT_PATH_BOTH
    )
    LIST(APPEND CMSIS_SOURCES ${SRC_FILE})
ENDFOREACH()

IF(STM32_CHIP_TYPE)
    SET(SRC_FILE SRC_FILE-NOTFOUND)
    FIND_FILE(SRC_FILE ${CMSIS_STARTUP_SOURCE}
        PATH_SUFFIXES src stm32${STM32_FAMILY_LOWER} cmsis
        HINTS ${STM32Cube_DIR}/Drivers/CMSIS/Device/ST/STM32${STM32_FAMILY}xx/Source/Templates/gcc/
        HINTS ${STM32Cube_DIR}/startup
        CMAKE_FIND_ROOT_PATH_BOTH
    )
    LIST(APPEND CMSIS_SOURCES ${SRC_FILE})

ENDIF()

INCLUDE(FindPackageHandleStandardArgs)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(CMSIS DEFAULT_MSG CMSIS_INCLUDE_DIRS CMSIS_SOURCES)
