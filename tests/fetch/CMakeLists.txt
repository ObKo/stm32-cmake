cmake_minimum_required(VERSION 3.16)
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/../../cmake/stm32_gcc.cmake)

if(NOT TEST_FAMILIES)
    set(TEST_FAMILIES C0 F0 F1 F2 F3 F4 F7 G0 G4 H7 L0 L1 L4 L5 MP1 U0 U5 WB WL)
endif()

# Generate the family long names list by prepending STM32 to elements in TEST_FAMILIES
list(TRANSFORM TEST_FAMILIES PREPEND STM32 OUTPUT_VARIABLE TEST_FAMILIES_LONG_NAMES)

project(fetch-test C ASM)
set(CMAKE_INCLUDE_CURRENT_DIR TRUE)

stm32_fetch_cmsis(${TEST_FAMILIES})
stm32_fetch_hal(${TEST_FAMILIES})

find_package(CMSIS REQUIRED ${TEST_FAMILIES_LONG_NAMES})
find_package(HAL REQUIRED ${TEST_FAMILIES_LONG_NAMES})

set(SOURCES main.c)

foreach(FAMILY ${TEST_FAMILIES})
    stm32_get_devices_by_family(STM_DEVICES FAMILY ${FAMILY})
    list(GET STM_DEVICES 0 DEVICE)
    stm32_get_cores(CORES FAMILY ${FAMILY} DEVICE ${DEVICE})
    
    if(CORES)
        list(GET CORES 0 CORE)
        set(CORE "::${CORE}")
    else()
        unset(CORE)
    endif()
    
    add_executable(fetch-test-${FAMILY} ${SOURCES})
    target_link_libraries(fetch-test-${FAMILY} STM32::NoSys HAL::STM32::${FAMILY}${CORE}::CORTEX CMSIS::STM32::${DEVICE}${CORE})
endforeach()

enable_testing()

#For testing
set(TEST_ARGS -N -DTEST_FAMILIES=F4)

# The default version
add_test(NAME UT_Version_Default COMMAND ${CMAKE_COMMAND} ${TEST_ARGS} "${CMAKE_CURRENT_SOURCE_DIR}"
)
set_tests_properties(UT_Version_Default PROPERTIES PASS_REGULAR_EXPRESSION "Fetching CMSIS version: 5.6.0"
)

# Custom version but hardcoded for testing
add_test(NAME UT_Version_Custom COMMAND ${CMAKE_COMMAND} ${TEST_ARGS} -DCMSIS_CUSTOM_VERSION=5.9.0 "${CMAKE_CURRENT_SOURCE_DIR}"
)
set_tests_properties(UT_Version_Custom PROPERTIES PASS_REGULAR_EXPRESSION "Fetching CMSIS version: 5.9.0"
)

# Should fail cuz version doesnt exist
add_test(NAME UT_Version_Invalid COMMAND ${CMAKE_COMMAND} ${TEST_ARGS} -DCMSIS_CUSTOM_VERSION=9.1.1 "${CMAKE_CURRENT_SOURCE_DIR}"
)
set_tests_properties(UT_Version_Invalid PROPERTIES WILL_FAIL TRUE PASS_REGULAR_EXPRESSION "CMSIS version '9.1.1' was not found"
)
