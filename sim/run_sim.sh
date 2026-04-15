#!/usr/bin/env bash
# =============================================================================
# sim/run_sim.sh  —  Simulate posit decoder and round-trip testbenches
#                    using Icarus Verilog (iverilog / vvp)
#
# Usage:
#   chmod +x sim/run_sim.sh
#   ./sim/run_sim.sh
#
# Requires: iverilog, vvp  (sudo apt install iverilog  OR  brew install icarus-verilog)
# =============================================================================

set -e
REPO=$(cd "$(dirname "$0")/.." && pwd)
SIM="$REPO/sim"

echo "============================================"
echo " Posit Encoder/Decoder Simulation"
echo "============================================"

# --- Decoder testbench ---
echo ""
echo "[1/2] Compiling Decoder_tb..."
iverilog -o "$SIM/Decoder_tb.out" \
    "$REPO/tb/Decoder_tb.v" \
    "$REPO/src/Decoder.v"   \
    "$REPO/src/LBC.v"       \
    "$REPO/src/MUX14.v"     \
    "$REPO/src/Subtractor.v"

echo "[1/2] Running Decoder_tb..."
vvp "$SIM/Decoder_tb.out"
echo "[1/2] VCD written to sim/Decoder_tb.vcd"

# --- Round-trip testbench ---
echo ""
echo "[2/2] Compiling posit_top_tb (round-trip)..."
iverilog -o "$SIM/posit_top_tb.out" \
    "$REPO/tb/posit_top_tb.v"  \
    "$REPO/src/posit_top.v"    \
    "$REPO/src/Decoder.v"      \
    "$REPO/src/Encoder.v"      \
    "$REPO/src/LBC.v"          \
    "$REPO/src/MUX14.v"        \
    "$REPO/src/Subtractor.v"

echo "[2/2] Running posit_top_tb..."
vvp "$SIM/posit_top_tb.out"
echo "[2/2] VCD written to sim/posit_top_tb.vcd"

echo ""
echo "============================================"
echo " Simulation complete. Open .vcd files in"
echo " GTKWave:  gtkwave sim/Decoder_tb.vcd"
echo "============================================"
