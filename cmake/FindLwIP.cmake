# If NO_SYS is set to 0 and the Netconn or Socket API is used, the user should link against
# the CMSIS RTOS or RTOS_V2 support because the sys_arch.c LwIP OS port layer makes use of
# CMSIS calls.
find_path(LwIP_ROOT
    NAMES CMakeLists.txt
    PATHS "${STM32_CUBE_${FAMILY}_PATH}/Middlewares/Third_Party/LwIP"
    NO_DEFAULT_PATH
)

if(LwIP_ROOT MATCHES "LwIP_ROOT-NOTFOUND")
    message(WARNING "LwIP root foolder not found. LwIP might not be supported")
endif()

set(LWIP_DIR ${LwIP_ROOT})

find_path(LwIP_SOURCE_PATH
    NAMES Filelists.cmake
    PATHS "${STM32_CUBE_${FAMILY}_PATH}/Middlewares/Third_Party/LwIP/src"
    NO_DEFAULT_PATH
)

if(LwIP_SOURCE_PATH MATCHES "LwIP_SOURCE_PATH-NOTFOUND")
    message(WARNING "LwIP filelist CMake file not found. Build might fail")
endif()

if(IS_DIRECTORY "${LwIP_SOURCE_PATH}/include")
    set(LwIP_INCLUDE_DIR "${LwIP_SOURCE_PATH}/include")
else()
    message(WARNING "LwIP include directory not found. Build might fail")
endif()

if(IS_DIRECTORY "${LwIP_ROOT}/system")
    set(LwIP_SYS_INCLUDE_DIR "${LwIP_ROOT}/system")
    set(LwIP_SYS_SOURCES "${LwIP_ROOT}/system/OS/sys_arch.c")
else()
    message(WARNING "LwIP system include directory not found. Build might fail")
endif()

# Use Filelists.cmake to get list of sources to compile
include("${LwIP_SOURCE_PATH}/Filelists.cmake")

if(NOT (TARGET LwIP))
    add_library(LwIP INTERFACE IMPORTED)
    target_sources(LwIP INTERFACE ${lwipcore_SRCS})
    target_include_directories(LwIP INTERFACE
        ${LwIP_INCLUDE_DIR} ${LwIP_SYS_INCLUDE_DIR}
    )
endif()

# Compile the system components which use CMSIS RTOS. This is necessary for the NETIF and Socket API
# This target also requires that the application was linked against the CMSIS RTOS support
if(NOT (TARGET LwIP::SYS))
    add_library(LwIP::SYS INTERFACE IMPORTED)
    target_sources(LwIP::SYS INTERFACE ${LwIP_SYS_SOURCES})
    target_link_libraries(LwIP::SYS INTERFACE LwIP)
endif()

if(NOT (TARGET LwIP::IPv4))
    add_library(LwIP::IPv4 INTERFACE IMPORTED)
    target_sources(LwIP::IPv4 INTERFACE ${lwipcore4_SRCS})
    target_link_libraries(LwIP::IPv4 INTERFACE LwIP)
endif()

if(NOT (TARGET LwIP::IPv6))
    add_library(LwIP::IPv6 INTERFACE IMPORTED)
    target_sources(LwIP::IPv6 INTERFACE ${lwipcore6_SRCS})
    target_link_libraries(LwIP::IPv6 INTERFACE LwIP)
endif()

if(NOT (TARGET LwIP::API))
    add_library(LwIP::API INTERFACE IMPORTED)
    target_sources(LwIP::API INTERFACE ${lwipapi_SRCS})
    target_link_libraries(LwIP::API INTERFACE LwIP::SYS)
endif()

if(NOT (TARGET LwIP::NETIF))
    add_library(LwIP::NETIF INTERFACE IMPORTED)
    target_sources(LwIP::NETIF INTERFACE ${lwipnetif_SRCS})
    target_link_libraries(LwIP::NETIF INTERFACE LwIP)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LwIP
    REQUIRED_VARS LwIP_ROOT LwIP_INCLUDE_DIR LwIP_SYS_INCLUDE_DIR
    FOUND_VAR LwIP_FOUND
    HANDLE_COMPONENTS
)
