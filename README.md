# AXI4-Lite UART IP Core & Custom USB-C to UART PCB

An end-to-end embedded hardware design project combining **Verilog RTL development, FPGA synthesis, simulation-based verification, and custom PCB design**.

The project implements an AXI4-Lite UART IP core with transmit and receive FIFOs, a configurable baud rate generator, a self-checking Verilog testbench and a UVM environment. It also includes a custom two-layer USB-C to UART breakout PCB designed in KiCad 10 around the FT232RL USB-to-UART bridge.

> **Project Status:** RTL simulation (Verilog testbench and UVM environment) and FPGA synthesis completed. PCB layout, routing and KiCad DRC completed with 0 errors. Fabrication and hardware validation are still pending.

---

## Table of Contents

- [Key Features](#key-features)
- [System Architecture](#system-architecture)
- [RTL Design](#rtl-design)
- [Verification and Simulation](#verification-and-simulation)
- [FPGA Synthesis Results](#fpga-synthesis-results)
- [Custom USB-C to UART PCB](#custom-usb-c-to-uart-pcb)
- [Visual Showcase](#visual-showcase)
- [Repository Structure](#repository-structure)
- [Getting Started](#getting-started)
- [Current Limitations](#current-limitations)
- [Roadmap](#roadmap)
- [Technologies Used](#technologies-used)
- [License](#license)
- [Author](#author)

---

## Key Features

### FPGA and RTL
- AXI4-Lite slave interface
- UART transmitter and receiver
- Independent TX and RX FIFOs
- Configurable baud rate generator (115200 baud at 100 MHz)
- Modular RTL architecture, targeting Intel Cyclone II

### Verification
- Self-checking Verilog testbench: AXI write, UART TX, loopback, RX FIFO, AXI read-back (test byte `8'hA5`)
- UVM environment (driver, monitor, scoreboard) running in ModelSim: 0 `UVM_ERROR`, 0 `UVM_FATAL`

### PCB Design
- Custom 2-layer USB-C to UART breakout board (65 x 35 mm)
- FT232RL USB-to-UART bridge and AMS1117-3.3 regulator
- GND planes on both copper layers
- Python-assisted netlist generation, placement and design rules
- Freerouting auto-routing, KiCad DRC with 0 errors, 3D visualization

---

## System Architecture

```text
             AXI4-Lite Master
                    |
                    v
          +--------------------+
          |  AXI4-Lite Slave   |
          |  Register Interface|
          +--------------------+
                    |
          +---------+---------+
          |                   |
          v                   v
   +-------------+     +-------------+
   |   TX FIFO   |     |   RX FIFO   |
   +-------------+     +-------------+
          |                   ^
          v                   |
   +-------------+     +-------------+
   |  UART TX    |     |  UART RX    |
   +-------------+     +-------------+
          |                   ^
          v                   |
        TX Pin              RX Pin

          +------------------+
          |  Baud Generator  |
          +------------------+
```

**Transmit path:** AXI4-Lite write, TX FIFO, UART transmitter, TX serial output.

**Receive path:** RX serial input, UART receiver, RX FIFO, AXI4-Lite read.

**Loopback:** in simulation, the TX output is connected to the RX input to verify that transmitted data is received correctly.

---

## RTL Design

| Module | Responsibility |
|---|---|
| `axi_uart_top.v` | Top-level integration and AXI4-Lite interface |
| `uart_tx.v` | UART serial transmission |
| `uart_rx.v` | UART serial reception |
| `baud_gen.v` | Baud timing generation |
| `fifo.v` | Data buffering (8-bit, 16 entries) |
| `tb_axi_uart.v` | Self-checking simulation testbench |

| Parameter | Value |
|---|---|
| Reference clock | 100 MHz |
| Baud rate | 115200 |
| AXI data width | 32 bit (UART data on bits [7:0]) |
| FIFO | 8-bit data, 16 entries |
| FPGA family | Intel Cyclone II |

---

## Verification and Simulation

### Verilog testbench

| Test | Objective |
|---|---|
| AXI write | Write a byte through the AXI4-Lite bus |
| UART TX | Verify serial transmission |
| Loopback | Verify transmitted and received data match |
| RX FIFO | Verify received data buffering |
| AXI read-back | Read the byte back through the bus |

Expected output:

```text
[TB SUCCESS] Loopback Data Matched: 0xa5
```

### UVM environment

The UVM environment (agent with sequencer, driver and monitor, scoreboard, environment and test) runs in ModelSim with these results:

```text
UVM_INFO    : 14
UVM_WARNING : 0
UVM_ERROR   : 0
UVM_FATAL   : 0
[SCOREBOARD] : 10 reports
```

### Running the simulation (ModelSim)

From the project root:

```tcl
vlog rtl/baud_gen.v rtl/fifo.v rtl/uart_rx.v rtl/uart_tx.v rtl/axi_uart_top.v
vlog rtl/tb_axi_uart.v
vsim -voptargs="+acc" tb_axi_uart
add wave -r /*
run -all
```

UVM test:

```tcl
vlog -sv +incdir+sim/uvm_tb sim/uvm_tb/axi_uart_if.sv
vlog -sv +incdir+sim/uvm_tb sim/uvm_tb/tb_top.sv
vsim -voptargs="+acc" tb_top +UVM_TESTNAME=axi_uart_test
run -all
```

---

## FPGA Synthesis Results

Synthesized for the Intel Cyclone II `EP2C5F256C6` with Quartus II.

| Parameter | Result |
|---|---:|
| Logic Elements | 196 / 4,608 (about 4%) |
| Registers | 124 |
| Maximum Frequency (Fmax) | 189.72 MHz |

The Fmax value is a synthesis timing-analysis result for the configured design and constraints; it has not been validated on hardware.

---

## Custom USB-C to UART PCB

| Ref | Component | Function |
|---|---|---|
| J1 | USB-C receptacle | USB connection and power input |
| U2 | FT232RL | USB-to-UART conversion |
| U1 | AMS1117-3.3 | 3.3 V regulation |
| C1, C2 | SMD capacitors | Decoupling |
| J2 | 1x6 pin header | UART connection to the FPGA board |

### Design workflow

1. Netlist generation with Python (`make_netlist.py`)
2. Board outline, placement, design rules and GND planes scripted with KiCad's Python API
3. Auto-routing with Freerouting (Specctra DSN/SES exchange)
4. KiCad DRC: 0 errors
5. 3D visualization with component models

---

## Visual Showcase

### 1. FPGA Synthesis Report (Quartus II)
![FPGA Synthesis Report](docs/fpga_summary.png)

### 2. RTL Architecture (Quartus RTL Viewer)
![RTL Architecture](docs/rtl_viewer.png)

### 3. Custom USB-C to UART PCB (KiCad 10, 3D render)
![USB-C to UART PCB](docs/AXI_UART_PCB.png)

### 4. Simulation Waveform (ModelSim SE-64)
![Simulation Waveform](docs/waveform.png)

### 5. UVM Report Summary (ModelSim SE-64)
![UVM Report Summary](docs/uvm_summary.png)

---

## Repository Structure

```text
.
├── rtl/       Verilog sources and testbench
├── sim/       UVM environment (sim/uvm_tb)
├── pcb/       KiCad project and Python scripts
├── docs/      Screenshots
├── LICENSE
└── README.md
```

---

## Getting Started

### Requirements

- Intel Quartus II (Cyclone II support)
- ModelSim (Verilog and SystemVerilog/UVM)
- KiCad 10
- Freerouting
- Python (KiCad scripting console)

### Clone

```bash
git clone https://github.com/hananeaouragh-ops/axi-uart-fpga-usbc-board.git
cd axi-uart-fpga-usbc-board
```

### Open the PCB project

1. Open the `.kicad_pro` file in `pcb/` with KiCad 10.
2. Inspect the layout, run DRC and open the 3D viewer.

---

## Current Limitations

- The UVM environment is a first version: limited stimulus, no functional coverage yet.
- AXI4-Lite protocol compliance has not been checked exhaustively.
- The PCB has not been fabricated, and no physical UART communication has been tested.
- Fmax comes from synthesis timing analysis, not from hardware measurements.

---

## Roadmap

- [x] Verilog RTL and self-checking testbench
- [x] FPGA synthesis (Cyclone II)
- [x] UVM environment (driver, monitor, scoreboard)
- [x] PCB layout, routing and DRC
- [ ] Add functional coverage and more UVM sequences
- [ ] Verify FIFO overflow/underflow and reset scenarios
- [ ] Generate manufacturing files (Gerber, drill, BOM) and fabricate the PCB
- [ ] Hardware test: UART loopback and FPGA-to-PC communication

---

## Technologies Used

| Category | Technologies |
|---|---|
| RTL Design | Verilog HDL |
| Bus Interface | AXI4-Lite |
| Simulation / Verification | ModelSim, Verilog testbench, SystemVerilog UVM |
| FPGA | Intel Quartus II, Cyclone II |
| PCB Design | KiCad 10, Freerouting |
| Automation | Python |

---

## License

Released under the MIT License (see [LICENSE](LICENSE)).

---

## Author

**Hanane Aouragh**

Embedded Systems | FPGA Design | Digital Hardware | PCB Design
