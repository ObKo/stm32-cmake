set(STM32_MP1_TYPES
    MP151AX MP151CX MP151DX MP151FX
    MP153AX MP153CX MP153DX MP153FX
    MP157AX MP157CX MP157DX MP157FX
)
set(STM32_MP1_TYPE_MATCH
   "MP151AA" "MP151CA" "MP151DA" "MP151FA"
   "MP153AA" "MP153CA" "MP153DA" "MP153FA"
   "MP157AA" "MP157CA" "MP157DA" "MP157FA"
)
#"MP15[137][ACDF]A"
set(STM32_MP1_RAM_SIZES
    384K 384K 384K 384K
    384K 384K 384K 384K
    384K 384K 384K 384K
)
set(STM32_MP1_CCRAM_SIZES
     0K 0K 0K 0K
     0K 0K 0K 0K
     0K 0K 0K 0K
)

stm32_util_create_family_targets(MP1)

target_compile_options(STM32::MP1 INTERFACE
    -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard
)
target_link_options(STM32::MP1 INTERFACE
    -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard
)
