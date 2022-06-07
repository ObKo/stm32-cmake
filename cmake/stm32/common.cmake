set(STM32_SUPPORTED_FAMILIES_LONG_NAME
    STM32F0 STM32F1 STM32F2 STM32F3 STM32F4 STM32F7
    STM32G0 STM32G4
    STM32H7_M4 STM32H7_M7
    STM32L0 STM32L1 STM32L4 STM32L5
    STM32U5
    STM32WB_M4 STM32WL_M4 STM32WL_M0PLUS
    STM32MP1_M4 )

foreach(FAMILY ${STM32_SUPPORTED_FAMILIES_LONG_NAME})
    # append short names (F0, F1, H7_M4, ...) to STM32_SUPPORTED_FAMILIES_SHORT_NAME
    string(REGEX MATCH "^STM32([FGHLMUW]P?[0-9BL])_?(M0PLUS|M4|M7)?" FAMILY ${FAMILY})
    list(APPEND STM32_SUPPORTED_FAMILIES_SHORT_NAME ${CMAKE_MATCH_1})
endforeach()
list(REMOVE_DUPLICATES STM32_SUPPORTED_FAMILIES_SHORT_NAME)

if(NOT STM32_TOOLCHAIN_PATH)
    if(DEFINED ENV{STM32_TOOLCHAIN_PATH})
        message(STATUS "Detected toolchain path STM32_TOOLCHAIN_PATH in environmental variables: ")
        message(STATUS "$ENV{STM32_TOOLCHAIN_PATH}")
        set(STM32_TOOLCHAIN_PATH $ENV{STM32_TOOLCHAIN_PATH})
    else()
        if(NOT CMAKE_C_COMPILER)
            set(STM32_TOOLCHAIN_PATH "/usr")
            message(STATUS "No STM32_TOOLCHAIN_PATH specified, using default: " ${STM32_TOOLCHAIN_PATH})
        else()
            # keep only directory of compiler
            get_filename_component(STM32_TOOLCHAIN_PATH ${CMAKE_C_COMPILER} DIRECTORY)
            # remove the last /bin directory
            get_filename_component(STM32_TOOLCHAIN_PATH ${STM32_TOOLCHAIN_PATH} DIRECTORY)
        endif()
    endif()
    file(TO_CMAKE_PATH "${STM32_TOOLCHAIN_PATH}" STM32_TOOLCHAIN_PATH)
endif()

if(NOT STM32_TARGET_TRIPLET)
    set(STM32_TARGET_TRIPLET "arm-none-eabi")
    message(STATUS "No STM32_TARGET_TRIPLET specified, using default: " ${STM32_TARGET_TRIPLET})
endif()

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(TOOLCHAIN_SYSROOT  "${STM32_TOOLCHAIN_PATH}/${STM32_TARGET_TRIPLET}")
set(TOOLCHAIN_BIN_PATH "${STM32_TOOLCHAIN_PATH}/bin")
set(TOOLCHAIN_INC_PATH "${STM32_TOOLCHAIN_PATH}/${STM32_TARGET_TRIPLET}/include")
set(TOOLCHAIN_LIB_PATH "${STM32_TOOLCHAIN_PATH}/${STM32_TARGET_TRIPLET}/lib")

find_program(CMAKE_OBJCOPY NAMES ${STM32_TARGET_TRIPLET}-objcopy HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_OBJDUMP NAMES ${STM32_TARGET_TRIPLET}-objdump HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_SIZE NAMES ${STM32_TARGET_TRIPLET}-size HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_DEBUGGER NAMES ${STM32_TARGET_TRIPLET}-gdb HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_CPPFILT NAMES ${STM32_TARGET_TRIPLET}-c++filt HINTS ${TOOLCHAIN_BIN_PATH})

function(stm32_print_size_of_target TARGET)
    add_custom_target(${TARGET}_always_display_size
        ALL COMMAND ${CMAKE_SIZE} ${TARGET}${CMAKE_EXECUTABLE_SUFFIX_C}
        COMMENT "Target Sizes: "
        DEPENDS ${TARGET}
    )
endfunction()

function(stm32_generate_binary_file TARGET)
    add_custom_command(
        TARGET ${TARGET}
        POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O binary ${TARGET}${CMAKE_EXECUTABLE_SUFFIX_C} ${TARGET}.bin
        BYPRODUCTS ${TARGET}.bin
        COMMENT "Generating binary file ${CMAKE_PROJECT_NAME}.bin"
    )
endfunction()

function(stm32_generate_srec_file TARGET)
    add_custom_command(
        TARGET ${TARGET}
        POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O srec ${TARGET}${CMAKE_EXECUTABLE_SUFFIX_C} ${TARGET}.srec
        BYPRODUCTS ${TARGET}.srec

        COMMENT "Generating srec file ${CMAKE_PROJECT_NAME}.srec"
    )
endfunction()

function(stm32_generate_hex_file TARGET)
    add_custom_command(
        TARGET ${TARGET}
        POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O ihex ${TARGET}${CMAKE_EXECUTABLE_SUFFIX_C} ${TARGET}.hex
        BYPRODUCTS ${TARGET}.hex
        COMMENT "Generating hex file ${CMAKE_PROJECT_NAME}.hex"
    )
endfunction()

# This function takes FAMILY (e.g. L4) and DEVICE (e.g. L496VG) to output TYPE (e.g. L496xx)
function(stm32_get_chip_type FAMILY DEVICE TYPE)
    set(INDEX 0)
    foreach(C_TYPE ${STM32_${FAMILY}_TYPES})
        list(GET STM32_${FAMILY}_TYPE_MATCH ${INDEX} REGEXP)
        if(${DEVICE} MATCHES ${REGEXP})
            set(RESULT_TYPE ${C_TYPE})
        endif()
        math(EXPR INDEX "${INDEX}+1")
    endforeach()
    if(NOT RESULT_TYPE)
        message(FATAL_ERROR "Invalid/unsupported device: ${DEVICE}")
    endif()
    set(${TYPE} ${RESULT_TYPE} PARENT_SCOPE)
endfunction()

function(stm32_get_chip_info CHIP)
    set(ARG_OPTIONS "")
    set(ARG_SINGLE FAMILY DEVICE TYPE)
    set(ARG_MULTIPLE "")
    cmake_parse_arguments(PARSE_ARGV 1 ARG "${ARG_OPTIONS}" "${ARG_SINGLE}" "${ARG_MULTIPLE}")

    string(TOUPPER ${CHIP} CHIP)

    string(REGEX MATCH "^STM32([FGHLMUW]P?[0-9BL])([0-9A-Z][0-9M][A-Z][0-9A-Z]).*$" CHIP ${CHIP})

    if((NOT CMAKE_MATCH_1) OR (NOT CMAKE_MATCH_2))
        message(FATAL_ERROR "Unknown chip ${CHIP}")
    endif()

    set(STM32_FAMILY ${CMAKE_MATCH_1})
    set(STM32_DEVICE "${CMAKE_MATCH_1}${CMAKE_MATCH_2}")


    if(NOT (${STM32_FAMILY} IN_LIST STM32_SUPPORTED_FAMILIES_SHORT_NAME))
        message(FATAL_ERROR "Unsupported family ${STM32_FAMILY} for device ${CHIP}")
    endif()

    stm32_get_chip_type(${STM32_FAMILY} ${STM32_DEVICE} STM32_TYPE)

    if(ARG_FAMILY)
        set(${ARG_FAMILY} ${STM32_FAMILY} PARENT_SCOPE)
    endif()
    if(ARG_DEVICE)
        set(${ARG_DEVICE} ${STM32_DEVICE} PARENT_SCOPE)
    endif()
    if(ARG_TYPE)
        set(${ARG_TYPE} ${STM32_TYPE} PARENT_SCOPE)
    endif()
endfunction()

function(stm32_get_cores CORES)
    set(ARG_OPTIONS "")
    set(ARG_SINGLE CHIP FAMILY DEVICE)
    set(ARG_MULTIPLE "")
    cmake_parse_arguments(PARSE_ARGV 1 ARG "${ARG_OPTIONS}" "${ARG_SINGLE}" "${ARG_MULTIPLE}")

    if(ARG_CHIP)
        # TODO: I don't get why stm32_get_chip_info is called in stm32_get_cores
        stm32_get_chip_info(${ARG_CHIP} FAMILY ARG_FAMILY TYPE ARG_TYPE DEVICE ARG_DEVICE)
    elseif(ARG_FAMILY AND ARG_DEVICE)
        # TODO: I don't get why stm32_get_chip_type is called in stm32_get_cores
        stm32_get_chip_type(${ARG_FAMILY} ${ARG_DEVICE} ARG_TYPE)
    elseif(ARG_FAMILY)
        if(${ARG_FAMILY} STREQUAL "H7")
            set(${CORES} M7 M4 PARENT_SCOPE)
        elseif(${ARG_FAMILY} STREQUAL "WB")
            set(${CORES} M4 PARENT_SCOPE)
        elseif(${ARG_FAMILY} STREQUAL "WL")
            set(${CORES} M4 M0PLUS PARENT_SCOPE)
        elseif(${ARG_FAMILY} STREQUAL "MP1")
            set(${CORES} M4 PARENT_SCOPE)
        else()
            set(${CORES} "" PARENT_SCOPE)
        endif()
        return()
    else()
        message(FATAL_ERROR "Either CHIP or FAMILY or FAMILY/DEVICE should be specified for stm32_get_cores()")
    endif()

    # TODO following is the only part really used by FindCMSIS. Maybe a cleanup is needed
    if(${ARG_FAMILY} STREQUAL "H7")
        stm32h7_get_device_cores(${ARG_DEVICE} ${ARG_TYPE} CORE_LIST)
    elseif(${ARG_FAMILY} STREQUAL "WB")
        # note STM32WB have an M0 core but in current state of the art it runs ST stacks and is not needed/allowed to build for customer
        set(CORE_LIST M4)
    elseif(${ARG_FAMILY} STREQUAL "MP1")
        set(CORE_LIST M4)
    elseif(${ARG_FAMILY} STREQUAL "WL")
        stm32wl_get_device_cores(${ARG_DEVICE} ${ARG_TYPE} CORE_LIST)
    endif()
    set(${CORES} "${CORE_LIST}" PARENT_SCOPE)
endfunction()

function(stm32_get_memory_info)
    set(ARG_OPTIONS FLASH RAM CCRAM STACK HEAP RAM_SHARE)
    set(ARG_SINGLE CHIP FAMILY DEVICE CORE SIZE ORIGIN)
    set(ARG_MULTIPLE "")
    cmake_parse_arguments(INFO "${ARG_OPTIONS}" "${ARG_SINGLE}" "${ARG_MULTIPLE}" ${ARGN})

    if((NOT INFO_CHIP) AND ((NOT INFO_FAMILY) OR (NOT INFO_DEVICE)))
        message(FATAL_ERROR "Either CHIP or FAMILY/DEVICE is required for stm32_get_memory_info()")
    endif()

    if(INFO_CHIP)
        stm32_get_chip_info(${INFO_CHIP} FAMILY INFO_FAMILY TYPE INFO_TYPE DEVICE INFO_DEVICE)
    else()
        stm32_get_chip_type(${INFO_FAMILY} ${INFO_DEVICE} INFO_TYPE)
    endif()

    string(REGEX REPLACE "^[FGHLMUW]P?[0-9BL][0-9A-Z][0-9M].([3468ABCDEFGHIYZ])$" "\\1" SIZE_CODE ${INFO_DEVICE})

    if(SIZE_CODE STREQUAL "3")
        set(FLASH "8K")
    elseif(SIZE_CODE STREQUAL "4")
        set(FLASH "16K")
    elseif(SIZE_CODE STREQUAL "6")
        set(FLASH "32K")
    elseif(SIZE_CODE STREQUAL "8")
        set(FLASH "64K")
    elseif(SIZE_CODE STREQUAL "B")
        set(FLASH "128K")
    elseif(SIZE_CODE STREQUAL "C")
        set(FLASH "256K")
    elseif(SIZE_CODE STREQUAL "D")
        set(FLASH "384K")
    elseif(SIZE_CODE STREQUAL "E")
        set(FLASH "512K")
    elseif(SIZE_CODE STREQUAL "F")
        set(FLASH "768K")
    elseif(SIZE_CODE STREQUAL "G")
        set(FLASH "1024K")
    elseif(SIZE_CODE STREQUAL "H")
        set(FLASH "1536K")
    elseif(SIZE_CODE STREQUAL "I")
        set(FLASH "2048K")
    elseif(SIZE_CODE STREQUAL "Y")
        set(FLASH "640K")
    elseif(SIZE_CODE STREQUAL "Z")
        set(FLASH "192K")
    else()
        set(FLASH "16K")
        message(WARNING "Unknow flash size for device ${DEVICE}. Set to ${FLASH}")
    endif()

    list(FIND STM32_${INFO_FAMILY}_TYPES ${INFO_TYPE} TYPE_INDEX)
    list(GET STM32_${INFO_FAMILY}_RAM_SIZES ${TYPE_INDEX} RAM)
    list(GET STM32_${INFO_FAMILY}_CCRAM_SIZES ${TYPE_INDEX} CCRAM)
    list(GET STM32_${INFO_FAMILY}_RAM_SHARE_SIZES ${TYPE_INDEX} RAM_SHARE)
    set(FLASH_ORIGIN 0x8000000)
    set(RAM_ORIGIN 0x20000000)
    set(CCRAM_ORIGIN 0x10000000)
    set(RAM_SHARE_ORIGIN 0x20030000)

    unset(TWO_FLASH_BANKS)
    if(FAMILY STREQUAL "F1")
        stm32f1_get_memory_info(${INFO_DEVICE} ${INFO_TYPE} FLASH RAM)
    elseif(FAMILY STREQUAL "L1")
        stm32l1_get_memory_info(${INFO_DEVICE} ${INFO_TYPE} FLASH RAM)
    elseif(FAMILY STREQUAL "F2")
        stm32f2_get_memory_info(${INFO_DEVICE} ${INFO_TYPE} FLASH RAM)
    elseif(FAMILY STREQUAL "F3")
        stm32f3_get_memory_info(${INFO_DEVICE} ${INFO_TYPE} FLASH RAM)
    elseif(FAMILY STREQUAL "H7")
        stm32h7_get_memory_info(${INFO_DEVICE} ${INFO_TYPE} "${INFO_CORE}" RAM FLASH_ORIGIN RAM_ORIGIN TWO_FLASH_BANKS)
    elseif(FAMILY STREQUAL "WL")
        stm32wl_get_memory_info(${INFO_DEVICE} ${INFO_TYPE} "${INFO_CORE}" RAM FLASH_ORIGIN RAM_ORIGIN TWO_FLASH_BANKS)
    elseif(FAMILY STREQUAL "WB")
        stm32wb_get_memory_info(${INFO_DEVICE} ${INFO_TYPE} "${INFO_CORE}" RAM RAM_ORIGIN TWO_FLASH_BANKS)
    elseif(FAMILY STREQUAL "MP1")
        stm32mp1_get_memory_info(${INFO_DEVICE} ${INFO_TYPE} FLASH)
    endif()
    # when a device is dual core, each core uses half of total flash
    if(TWO_FLASH_BANKS)
        string(REGEX MATCH "([0-9]+)K" FLASH_KB ${FLASH})
        math(EXPR FLASH_KB "${CMAKE_MATCH_1} / 2")
        set(FLASH "${FLASH_KB}K")
    endif()

    if(INFO_FLASH)
        set(SIZE ${FLASH})
        set(ORIGIN ${FLASH_ORIGIN})
    elseif(INFO_RAM)
        set(SIZE ${RAM})
        set(ORIGIN ${RAM_ORIGIN})
    elseif(INFO_CCRAM)
        set(SIZE ${CCRAM})
        set(ORIGIN ${CCRAM_ORIGIN})
    elseif(INFO_RAM_SHARE)
        set(SIZE ${RAM_SHARE})
        set(ORIGIN ${RAM_SHARE_ORIGIN})
    elseif(INFO_STACK)
        if (RAM STREQUAL "2K")
            set(SIZE 0x200)
        else()
            set(SIZE 0x400)
        endif()
        set(ORIGIN ${RAM_ORIGIN}) #TODO: Real stack pointer?
    elseif(INFO_HEAP)
        if (RAM STREQUAL "2K")
            set(SIZE 0x100)
        else()
            set(SIZE 0x200)
        endif()
        set(ORIGIN ${RAM_ORIGIN}) #TODO: Real heap pointer?
    endif()

    if(INFO_SIZE)
        set(${INFO_SIZE} ${SIZE} PARENT_SCOPE)
    endif()
    if(INFO_ORIGIN)
        set(${INFO_ORIGIN} ${ORIGIN} PARENT_SCOPE)
    endif()
endfunction()

function(stm32_add_linker_script TARGET VISIBILITY SCRIPT)
    get_filename_component(SCRIPT "${SCRIPT}" ABSOLUTE)
    target_link_options(${TARGET} ${VISIBILITY} -T "${SCRIPT}")

    get_target_property(TARGET_TYPE ${TARGET} TYPE)
    if(TARGET_TYPE STREQUAL "INTERFACE_LIBRARY")
        set(INTERFACE_PREFIX "INTERFACE_")
    endif()

    get_target_property(LINK_DEPENDS ${TARGET} ${INTERFACE_PREFIX}LINK_DEPENDS)
    if(LINK_DEPENDS)
        list(APPEND LINK_DEPENDS "${SCRIPT}")
    else()
        set(LINK_DEPENDS "${SCRIPT}")
    endif()


    set_target_properties(${TARGET} PROPERTIES ${INTERFACE_PREFIX}LINK_DEPENDS "${LINK_DEPENDS}")
endfunction()

if(NOT (TARGET STM32::NoSys))
    add_library(STM32::NoSys INTERFACE IMPORTED)
    target_compile_options(STM32::NoSys INTERFACE $<$<C_COMPILER_ID:GNU>:--specs=nosys.specs>)
    target_link_options(STM32::NoSys INTERFACE $<$<C_COMPILER_ID:GNU>:--specs=nosys.specs>)
endif()

if(NOT (TARGET STM32::Nano))
    add_library(STM32::Nano INTERFACE IMPORTED)
    target_compile_options(STM32::Nano INTERFACE $<$<C_COMPILER_ID:GNU>:--specs=nano.specs>)
    target_link_options(STM32::Nano INTERFACE $<$<C_COMPILER_ID:GNU>:--specs=nano.specs>)
endif()

if(NOT (TARGET STM32::Nano::FloatPrint))
    add_library(STM32::Nano::FloatPrint INTERFACE IMPORTED)
    target_link_options(STM32::Nano::FloatPrint INTERFACE
        $<$<C_COMPILER_ID:GNU>:-Wl,--undefined,_printf_float>
    )
endif()

if(NOT (TARGET STM32::Nano::FloatScan))
    add_library(STM32::Nano::FloatScan INTERFACE IMPORTED)
    target_link_options(STM32::Nano::FloatPrint INTERFACE
        $<$<C_COMPILER_ID:GNU>:-Wl,--undefined,_scanf_float>
    )
endif()

include(stm32/utilities)
include(stm32/f0)
include(stm32/f1)
include(stm32/f2)
include(stm32/f3)
include(stm32/f4)
include(stm32/f7)
include(stm32/g0)
include(stm32/g4)
include(stm32/h7)
include(stm32/l0)
include(stm32/l1)
include(stm32/l4)
include(stm32/l5)
include(stm32/u5)
include(stm32/wb)
include(stm32/wl)
include(stm32/mp1)
