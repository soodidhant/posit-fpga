# Design and FPGA Implementation of Posit Encoder and Decoder

> 16-bit posit number system encoder and decoder, implemented and verified on a Xilinx Artix-7 FPGA (xc7a100tcsg324-1) using Vivado 2025.1. Includes power and resource optimisation analysis, ILA/VIO-based hardware demonstration, and a full round-trip testbench.

**Authors:** Idhant Sood (2210110303) · Abhinav Nagpal (2210110111)Idhant Sood (2210110303)  
**Supervisor:** Dr. Rakesh Palisetty — Department of Electrical Engineering  
**Institution:** Shiv Nadar Institution of Eminence, Delhi-NCR  
**Term:** Monsoon 2025

---

## Table of Contents

- [Overview](#overview)
- [Posit Number Format](#posit-number-format)
- [Repository Structure](#repository-structure)
- [Module Descriptions](#module-descriptions)
- [Results](#results)
- [Getting Started](#getting-started)
- [Simulating](#simulating)
- [FPGA Build and Programming](#fpga-build-and-programming)
- [ILA / VIO Demo](#ila--vio-demo)
- [References](#references)

---

## Overview

Conventional IEEE-754 floating-point numbers suffer from rounding errors, non-uniform precision, and complex hardware for special values (NaN, Infinity, subnormals). Posit arithmetic, introduced by John L. Gustafson, addresses these problems through a variable-length *regime* field that adaptively allocates bits between scale and precision.

This project implements a complete 16-bit posit **decoder** and **encoder** in Verilog, synthesised and place-and-routed on Xilinx Artix-7. An optimised decoder variant reduces LUT usage by 78% compared to the baseline design, with a 32.7% reduction in total on-chip power.

**Key achievements:**

| Metric | Original | Optimised |
|---|---|---|
| LUT utilisation | 150 (0.24%) | 33 (0.05%) |
| Total on-chip power | 7.465 W | 5.021 W |
| Junction temperature | 59.1 °C | 47.9 °C |

---

## Posit Number Format

A 16-bit posit number is encoded as:

```
Bit 15      Bits 14..r+2    Bits r+1..r     Bits r-1..0
  sign  |    regime run  |  exponent(es)  |   fraction
```

The decoded real value is:

```
(-1)^sign  ×  useed^k  ×  2^exp  ×  (1 + fraction)
   where  useed = 2^(2^es),  es = 2  for this design
```

| Field | Bits | Description |
|---|---|---|
| Sign | 1 | Sign of the number |
| Regime | Variable | Run-length encoded; k ones then 0 (k≥0), or k zeros then 1 (k<0) |
| Exponent | up to 2 | Additional binary scale factor |
| Fraction | Remaining | Fractional precision (hidden leading 1) |

Special values: `0x0000` = zero, `0x8000` = NaR (Not a Real).

---

## Repository Structure

```
posit-fpga/
├── src/
│   ├── Decoder.v          # Top-level 16-bit posit decoder
│   ├── Encoder.v          # 16-bit posit encoder
│   ├── posit_top.v        # Round-trip wrapper (Decoder → Encoder)
│   ├── LBC.v              # Leading Bit Counter (regime extraction)
│   ├── MUX14.v            # 14-bit barrel-shift multiplexer
│   └── Subtractor.v       # 4-bit subtractor with borrow
├── tb/
│   ├── Decoder_tb.v       # Decoder unit testbench
│   └── posit_top_tb.v     # Full 65536-value round-trip testbench
├── constraints/
│   └── posit_decoder.xdc  # Pin assignments for xc7a100tcsg324-1
├── synth/
│   └── build.tcl          # Vivado batch build script
├── sim/
│   └── run_sim.sh         # Icarus Verilog simulation script
├── docs/
│   └── reports/
│       ├── utilization_original.rpt  # Vivado utilization report
│       ├── power_original.rpt        # Vivado power report
│       └── timing_summary.rpt        # Vivado timing summary
├── .gitignore
├── LICENSE
└── README.md
```

---

## Module Descriptions

### `Decoder.v`
Extracts the sign, regime value (k), exponent, and mantissa from a 16-bit posit input. Detects zero and NaR special cases. Instantiates `LBC`, `MUX14`, and `Subtractor`.

**Ports:**

| Port | Dir | Width | Description |
|---|---|---|---|
| `posit_in` | in | 16 | Raw posit binary input |
| `sign` | out | 1 | Sign bit |
| `regime` | out | 4 | Decoded regime value k (2s complement) |
| `exp` | out | 2 | Exponent field |
| `mantissa` | out | 11 | Fraction/mantissa bits |
| `ss` | out | 1 | Special-case flag (zero or NaR) |
| `chck` | out | 1 | Valid output flag |
| `saddcin` | out | 1 | Subtractor carry-in for sub-block |

### `Encoder.v`
Reconstructs a 16-bit posit binary number from decomposed fields. Complements the decoder for round-trip validation.

### `LBC.v`
Leading Bit Counter. Counts consecutive identical bits from the MSB of the regime field to determine regime length and polarity (positive/negative k).

### `MUX14.v`
14-bit barrel-shift multiplexer. Shifts the posit body left by the regime length to align exponent and mantissa fields at the MSB end.

### `Subtractor.v`
4-bit subtractor with borrow-in/out. Supports index calculations and field alignment in both encoder and decoder.

### `posit_top.v`
Integrates decoder and encoder in a single top-level module for round-trip testing and ILA/VIO-based hardware demonstration.

---

## Results

### Resource Utilisation (Vivado 2025.1, xc7a100t)

| Resource | Original | Optimised | Available | Saving |
|---|---|---|---|---|
| Slice LUTs | 150 (0.24%) | 33 (0.05%) | 63,400 | **78%** |
| Flip-Flops | 16 (0.01%) | 16 (0.01%) | 126,800 | 0% |
| I/O | 34 (16.19%) | 34 (16.19%) | 210 | — |
| BUFG | 1 (3.13%) | 1 (3.13%) | 32 | — |

### Power Consumption

| Parameter | Original | Optimised | Saving |
|---|---|---|---|
| Total on-chip power | 7.465 W | 5.021 W | **32.7%** |
| Dynamic power | 0.008 W | 0.006 W | 25% |
| Static power | 0.091 W | 0.091 W | — |
| I/O power | 0.006 W | 0.005 W | 17% |
| Junction temperature | 59.1 °C | 47.9 °C | **−11.2 °C** |

Full Vivado reports are in `docs/reports/`.

---

## Getting Started

### Prerequisites

| Tool | Purpose |
|---|---|
| Xilinx Vivado 2023.x / 2025.x | Synthesis, implementation, bitstream |
| Icarus Verilog (`iverilog`) | Simulation (open-source alternative) |
| GTKWave | Waveform viewing |
| `openFPGALoader` (optional) | Open-source board programming |

### Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/posit-fpga.git
cd posit-fpga
```

---

## Simulating

Using the provided shell script (Icarus Verilog):

```bash
chmod +x sim/run_sim.sh
./sim/run_sim.sh
```

This compiles and runs both testbenches, producing `sim/Decoder_tb.vcd` and `sim/posit_top_tb.vcd`.

View waveforms in GTKWave:

```bash
gtkwave sim/Decoder_tb.vcd
```

To run individual testbenches manually:

```bash
# Decoder only
iverilog -o sim/Decoder_tb.out tb/Decoder_tb.v src/Decoder.v src/LBC.v src/MUX14.v src/Subtractor.v
vvp sim/Decoder_tb.out

# Full round-trip
iverilog -o sim/posit_top_tb.out tb/posit_top_tb.v src/posit_top.v src/Decoder.v src/Encoder.v src/LBC.v src/MUX14.v src/Subtractor.v
vvp sim/posit_top_tb.out
```

---

## FPGA Build and Programming

### Using the TCL build script (batch mode)

```bash
vivado -mode batch -source synth/build.tcl
```

This creates the Vivado project in memory, runs synthesis and implementation, writes the bitstream to `synth/Decoder.bit`, and saves reports to `docs/reports/`.

### Using Vivado GUI

1. Open Vivado → Create Project → RTL Project
2. Add all files from `src/` as design sources
3. Add `constraints/posit_decoder.xdc` as a constraint
4. Set top module to `Decoder`
5. Run Synthesis → Implementation → Generate Bitstream

### Program the board

```bash
# Using Vivado Hardware Manager (GUI): connect board → Program Device → select synth/Decoder.bit

# Using openFPGALoader (command line):
openFPGALoader -b arty_a7_100t synth/Decoder.bit
```

---

## ILA / VIO Demo

The design was validated on hardware using Xilinx ILA and VIO debug IP cores in Vivado:

1. **VIO input** — enter any 16-bit binary value via the Vivado hardware dashboard
2. **VIO outputs** — decoded fields (sign, regime, exponent, fraction) appear in real time
3. **Encoder output** — the re-encoded 16-bit posit is shown alongside for round-trip comparison
4. **ILA** — monitors internal signal transitions and verifies field extraction timing

To reproduce: re-run the build with VIO/ILA IP cores inserted in `posit_top.v`, or use Vivado's "Set up Debug" wizard on the intermediate signals.

---

## References

1. Energy-Efficient Decoding and Encoding Hardware for Optimized Posit Arithmetic — IEEE, 2024
2. Efficient Hardware Design of Parameterized Posit Multiplier and Posit Adder — IEEE, 2024
3. Efficient Data Extraction Circuit for Posit Number System: LDD-Based Posit Decoder — IEEE
4. Design of Energy Efficient and Low Delay Posit Multiplier — IEEE, 2023
5. Design of Power Efficient Posit Multiplier — IEEE, 2022
6. Universal Number Posit Arithmetic Generator on FPGA — IEEE, 2018
7. Low Power Design and Formal Verification of POSIT Arithmetic Block — IEEE, 2024
8. Architecture Generator for Type-3 Unum Posit Adder/Subtractor — IEEE, 2018

---

## License

MIT License — see [LICENSE](LICENSE) for details.  
Copyright © 2025 Abhinav Nagpal and Idhant Sood
