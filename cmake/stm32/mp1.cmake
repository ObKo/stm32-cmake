set(STM32_MP1_TYPES 
    MP151Axx MP151Cxx
    MP153Axx MP153Cxx 
    MP157Axx MP157Cxx)

set(STM32_MP1_TYPE_MATCH
    "MP151[AD](A.?)?" "MP151[CF](A.?)?"  
    "MP153[AD](A.?)?" "MP153[CF](A.?)?"
    "MP157[AD](A.?)?" "MP157[CF](A.?)?")

set(STM32_MP1_RAM_SIZES
    384K 384K
    384K 384K
    384K 384K)

set(STM32_MP1_CCRAM_SIZES
    0K 0K
    0K 0K
    0K 0K)

# The MDIOS module is broken in STM32CubeMP1 up to and including v. 1.6.0
# Exclude it by default
set(EXCLUDED_HAL_DRIVERS_MP1
    MDIOS
)

stm32_util_create_family_targets(MP1 M4)

target_compile_options(STM32::MP1::M4 INTERFACE -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard)
target_link_options(STM32::MP1::M4 INTERFACE -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard)
target_compile_definitions(STM32::MP1::M4 INTERFACE CORE_CM4)

function(stm32mp1_get_memory_info DEVICE TYPE FLASH_SIZE)
    if(FLASH_SIZE)
        set(${FLASH_SIZE} "0KB" PARENT_SCOPE)
    endif()
endfunction()
