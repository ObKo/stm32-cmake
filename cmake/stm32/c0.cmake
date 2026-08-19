set(STM32_C0_TYPES 
    C011xx
    C031xx
    C051xx
    C071xx
    C091xx
    C092xx
)
set(STM32_C0_TYPE_MATCH 
    "C011.[46]"
    "C031.[46]"
    "C051.[68]"
    "C071.[8B]"
    "C091.[BC]"
    "C092.[BC]"
)
set(STM32_C0_RAM_SIZES 
     6K
    12K
    12K
    24K
    36K
    30k
)
set(STM32_C0_CCRAM_SIZES 
     0K
     0K
     0K
     0K
     0K
     0K
)

stm32_util_create_family_targets(C0)

target_compile_options(STM32::C0 INTERFACE 
    -mcpu=cortex-m0plus
)
target_link_options(STM32::C0 INTERFACE 
    -mcpu=cortex-m0plus
)

list(APPEND STM32_ALL_DEVICES
    C011D6
    C011F4
    C011F6
    C011J4
    C011J6
    C031C4
    C031C6
    C031F4
    C031F6
    C031G4
    C031G6
    C031K4
    C031K6
    C051C6
    C051C8
    C051D8
    C051F6
    C051F8
    C051G6
    C051G8
    C051K6
    C051K8
    C071C8
    C071CB
    C071F8
    C071FB
    C071G8
    C071GB
    C071K8
    C071KB
    C071R8
    C071RB
    C091CB
    C091CC
    C091EC
    C091FB
    C091FC
    C091GB
    C091GC
    C091KB
    C091KC
    C091RB
    C091RC
    C092CB
    C092CC
    C092EC
    C092FB
    C092FC
    C092GB
    C092GC
    C092KB
    C092KC
    C092RB
    C092RC
)

list(APPEND STM32_SUPPORTED_FAMILIES_LONG_NAME
    STM32C0
)

list(APPEND STM32_FETCH_FAMILIES C0)

set(CUBE_C0_VERSION  v1.1.0)
set(CMSIS_C0_VERSION v1.1.0)
set(HAL_C0_VERSION   v1.1.0)
