set(STM32_MP1_TYPES
    MP151AX MP151CX
    MP153AX MP153CX
    MP157AX MP157CX
)
set(STM32_MP1_TYPE_MATCH
   "MP151AA" "MP151CA"
   "MP153AA" "MP153CA"
   "MP157AA" "MP157CA"
)
#"MP15[137][ACDF]A"
set(STM32_MP1_RAM_SIZES
    384K 384K
    384K 384K
    384K 384K
)
set(STM32_MP1_CCRAM_SIZES
     0K 0K
     0K 0K
     0K 0K
)

stm32_util_create_family_targets(MP1)

target_compile_options(STM32::MP1 INTERFACE
    -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard
)
target_link_options(STM32::MP1 INTERFACE
    -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard
)
