# =============================================================================
# Constraints : posit_decoder.xdc
# Project     : Posit Encoder/Decoder
# Device      : xc7a100tcsg324-1  (Artix-7)
# IO Standard : LVCMOS18 (Bank 14, 1.8 V)
# Derived from Vivado 2025.1 IO placement report (November 2025)
# =============================================================================

# -----------------------------------------------------------------------------
# Input: 16-bit posit binary number
# -----------------------------------------------------------------------------
set_property PACKAGE_PIN T15  [get_ports {posit_in[0]}]
set_property PACKAGE_PIN T14  [get_ports {posit_in[1]}]
set_property PACKAGE_PIN R15  [get_ports {posit_in[2]}]
set_property PACKAGE_PIN P15  [get_ports {posit_in[3]}]
set_property PACKAGE_PIN R17  [get_ports {posit_in[4]}]
set_property PACKAGE_PIN P17  [get_ports {posit_in[5]}]
set_property PACKAGE_PIN N16  [get_ports {posit_in[6]}]
set_property PACKAGE_PIN N15  [get_ports {posit_in[7]}]
set_property PACKAGE_PIN M17  [get_ports {posit_in[8]}]
set_property PACKAGE_PIN M16  [get_ports {posit_in[9]}]
set_property PACKAGE_PIN P18  [get_ports {posit_in[10]}]
set_property PACKAGE_PIN N17  [get_ports {posit_in[11]}]
set_property PACKAGE_PIN P14  [get_ports {posit_in[12]}]
set_property PACKAGE_PIN N14  [get_ports {posit_in[13]}]
set_property PACKAGE_PIN T18  [get_ports {posit_in[14]}]
set_property PACKAGE_PIN R18  [get_ports {posit_in[15]}]

set_property IOSTANDARD LVCMOS18 [get_ports {posit_in[*]}]

# -----------------------------------------------------------------------------
# Output: sign bit
# -----------------------------------------------------------------------------
set_property PACKAGE_PIN T16  [get_ports sign]
set_property IOSTANDARD LVCMOS18 [get_ports sign]

# -----------------------------------------------------------------------------
# Output: regime [3:0]
# -----------------------------------------------------------------------------
set_property PACKAGE_PIN U11  [get_ports {regime[0]}]
set_property PACKAGE_PIN T11  [get_ports {regime[1]}]
set_property PACKAGE_PIN V17  [get_ports {regime[2]}]
set_property PACKAGE_PIN U16  [get_ports {regime[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {regime[*]}]

# -----------------------------------------------------------------------------
# Output: exponent [1:0]
# -----------------------------------------------------------------------------
set_property PACKAGE_PIN U18  [get_ports {exp[0]}]
set_property PACKAGE_PIN U17  [get_ports {exp[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {exp[*]}]

# -----------------------------------------------------------------------------
# Output: mantissa [10:0]
# -----------------------------------------------------------------------------
set_property PACKAGE_PIN R10  [get_ports {mantissa[0]}]
set_property PACKAGE_PIN T10  [get_ports {mantissa[1]}]
set_property PACKAGE_PIN T9   [get_ports {mantissa[2]}]
set_property PACKAGE_PIN U13  [get_ports {mantissa[3]}]
set_property PACKAGE_PIN T13  [get_ports {mantissa[4]}]
set_property PACKAGE_PIN V14  [get_ports {mantissa[5]}]
set_property PACKAGE_PIN U14  [get_ports {mantissa[6]}]
set_property PACKAGE_PIN V11  [get_ports {mantissa[7]}]
set_property PACKAGE_PIN V10  [get_ports {mantissa[8]}]
set_property PACKAGE_PIN V12  [get_ports {mantissa[9]}]
set_property PACKAGE_PIN U12  [get_ports {mantissa[10]}]
set_property IOSTANDARD LVCMOS18 [get_ports {mantissa[*]}]

# -----------------------------------------------------------------------------
# Output: special-case flags
# -----------------------------------------------------------------------------
set_property PACKAGE_PIN R16  [get_ports ss]
set_property PACKAGE_PIN V16  [get_ports chck]
set_property PACKAGE_PIN V15  [get_ports saddcin]
set_property IOSTANDARD LVCMOS18 [get_ports ss]
set_property IOSTANDARD LVCMOS18 [get_ports chck]
set_property IOSTANDARD LVCMOS18 [get_ports saddcin]

# -----------------------------------------------------------------------------
# Timing: false path (purely combinational, no clock domain)
# -----------------------------------------------------------------------------
set_false_path -from [get_ports {posit_in[*]}] -to [get_ports {mantissa[*] regime[*] exp[*] sign ss chck saddcin}]
