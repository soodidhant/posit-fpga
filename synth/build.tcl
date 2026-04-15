# =============================================================================
# build.tcl  —  Vivado 2025.1 batch build script
# Project    : Design and FPGA Implementation of Posit Encoder and Decoder
# Authors    : Abhinav Nagpal (2210110111), Idhant Sood (2210110303)
# Device     : xc7a100tcsg324-1  (Artix-7 100T, CSG324 package, -1 speed)
#
# Usage (from repo root):
#   vivado -mode batch -source synth/build.tcl
#
# Outputs:
#   synth/posit_top.bit   — bitstream ready to program
# =============================================================================

set PROJ_NAME "posit"
set PART      "xc7a100tcsg324-1"
set TOP       "Decoder"
set REPO_ROOT [file normalize [file dirname [file dirname [info script]]]]
set OUT_DIR   "$REPO_ROOT/synth"

# -----------------------------------------------------------------------------
# Create project in memory (no .xpr written)
# -----------------------------------------------------------------------------
create_project $PROJ_NAME $OUT_DIR -part $PART -force

set_property target_language Verilog [current_project]

# -----------------------------------------------------------------------------
# Add source files
# -----------------------------------------------------------------------------
add_files -norecurse [glob $REPO_ROOT/src/*.v]
set_property top $TOP [current_fileset]

# -----------------------------------------------------------------------------
# Add constraints
# -----------------------------------------------------------------------------
add_files -fileset constrs_1 -norecurse $REPO_ROOT/constraints/posit_decoder.xdc

# -----------------------------------------------------------------------------
# Synthesis
# -----------------------------------------------------------------------------
puts "INFO: Starting synthesis..."
launch_runs synth_1 -jobs 4
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    error "ERROR: Synthesis failed."
}
puts "INFO: Synthesis complete."

# -----------------------------------------------------------------------------
# Implementation
# -----------------------------------------------------------------------------
puts "INFO: Starting implementation..."
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    error "ERROR: Implementation failed."
}
puts "INFO: Implementation complete."

# -----------------------------------------------------------------------------
# Copy bitstream to synth/
# -----------------------------------------------------------------------------
set bit_src [get_property DIRECTORY [get_runs impl_1]]/${TOP}.bit
file copy -force $bit_src $OUT_DIR/${TOP}.bit
puts "INFO: Bitstream written to $OUT_DIR/${TOP}.bit"

# -----------------------------------------------------------------------------
# Generate reports
# -----------------------------------------------------------------------------
open_run impl_1
report_utilization    -file $REPO_ROOT/docs/reports/utilization_impl.rpt
report_power          -file $REPO_ROOT/docs/reports/power_impl.rpt
report_timing_summary -max_paths 10 -file $REPO_ROOT/docs/reports/timing_impl.rpt
puts "INFO: Reports written to docs/reports/"

close_project
puts "INFO: Build complete."
