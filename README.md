# AXI4-Lite UART IP Core & Custom USB-C to UART PCB

An end-to-end embedded hardware design project combining **Verilog RTL development, FPGA synthesis, simulation-based verification, and custom PCB design**.

The project implements an AXI4-Lite UART IP core with transmit and receive FIFOs, a configurable baud rate generator, and a self-checking Verilog testbench. It also includes a custom two-layer USB-C to UART breakout PCB designed in KiCad 10 using the FT232RL USB-to-UART bridge.

> **Project Status:** RTL simulation and FPGA synthesis completed. PCB layout and routing completed; final DRC review, fabrication, and hardware validation are still pending.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Key Features](#key-features)
- [System Architecture](#system-architecture)
- [RTL Design](#rtl-design)
- [Verification and Simulation](#verification-and-simulation)
- [FPGA Synthesis Results](#fpga-synthesis-results)
- [Custom USB-C to UART PCB](#custom-usb-c-to-uart-pcb)
- [Repository Structure](#repository-structure)
- [Getting Started](#getting-started)
- [Expected Simulation Result](#expected-simulation-result)
- [Current Limitations](#current-limitations)
- [Roadmap](#roadmap)
- [Technologies Used](#technologies-used)

---

## Project Overview

This project explores the design of a reusable UART peripheral with an **AXI4-Lite slave interface**, targeting an Intel Cyclone II FPGA.

The UART IP core provides a memory-mapped interface for configuring and accessing UART registers. Independent transmit and receive FIFOs buffer data, while a baud rate generator produces the timing required for serial communication.

A self-checking Verilog testbench validates the main communication path, including AXI transactions, UART transmission, loopback reception, FIFO operations, and read-back verification.

To complement the FPGA design, a custom USB-C to UART interface PCB was developed in KiCad 10. The board uses an FT232RL USB-to-UART bridge to provide a USB connection to an external UART interface.

### Project Goals

- Design a modular UART peripheral using synthesizable Verilog.
- Implement an AXI4-Lite slave interface.
- Support buffered UART transmission and reception.
- Verify communication behavior using ModelSim.
- Evaluate FPGA resource utilization and timing.
- Design a compact, two-layer USB-C to UART PCB.
- Establish a workflow connecting RTL development, simulation, synthesis, and PCB design.

---

## Key Features

### FPGA and RTL

- AXI4-Lite slave interface.
- UART transmitter and receiver.
- Independent TX and RX FIFOs.
- Configurable baud rate generation.
- Target baud rate: 115200 baud.
- Reference clock: 100 MHz.
- Modular RTL architecture.
- Designed for Intel Cyclone II FPGA devices.

### Verification

- Self-checking Verilog testbench.
- AXI write and read-back transactions.
- UART TX verification.
- UART loopback test.
- RX FIFO verification.
- Test data: `8'hA5`.
- UVM verification environment under development.

### PCB Design

- Custom USB-C to UART breakout board.
- FT232RL USB-to-UART bridge.
- AMS1117-3.3 voltage regulator.
- Two-layer PCB layout.
- Ground planes on both PCB layers.
- Python-assisted netlist generation and placement.
- Freerouting-assisted autorouting.
- 3D PCB visualization in KiCad.

---

## System Architecture

The design consists of two main subsystems:

1. **FPGA subsystem:** AXI4-Lite interface, UART registers, TX/RX FIFOs, baud rate generator, transmitter, and receiver.
2. **USB interface subsystem:** USB-C connector, FT232RL bridge, power regulation, and UART header for connection to an external FPGA board.

### FPGA RTL Data Path

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

*Conceptual block diagram. The exact register map, signal connections, and implementation details should be confirmed against the RTL source files.*

### Communication Flow

**Transmit path**

AXI4-Lite write transaction → TX register/FIFO → UART transmitter → TX serial output.

**Receive path**

RX serial input → UART receiver → RX FIFO/register → AXI4-Lite read transaction.

**Loopback verification**

The UART TX output is connected to the RX input in the simulation testbench to verify that transmitted data can be received correctly.

---

## RTL Design

The RTL is organized into separate modules to improve readability, maintainability, and reuse.

| Module | Responsibility |
|---|---|
| `axi_uart_top.v` | Top-level integration and AXI4-Lite interface |
| `uart_tx.v` | UART serial transmission |
| `uart_rx.v` | UART serial reception |
| `baud_gen.v` | Baud timing generation |
| `fifo.v` | Data buffering |
| `tb_axi_uart.v` | Self-checking simulation testbench |

### UART Configuration

| Parameter | Value |
|---|---|
| Reference clock | 100 MHz |
| Target baud rate | 115200 baud |
| Serial interface | UART |
| FPGA family | Intel Cyclone II |
| AXI interface | AXI4-Lite |

The implementation should be checked against the actual RTL for the supported data width, parity configuration, stop-bit configuration, FIFO depth, and baud-rate adjustment options.

---

## Verification and Simulation

The design includes a self-checking Verilog testbench intended to validate the main AXI and UART communication functions.

### Verification Scenarios

| Test | Objective |
|---|---|
| AXI write | Verify register write transactions |
| UART TX | Verify serial transmission |
| Loopback | Verify transmitted and received data match |
| RX FIFO | Verify received data buffering |
| AXI read-back | Verify data can be read through the bus |
| Data comparison | Compare the received byte against the expected value |

### Test Data

The main loopback test uses:

```verilog
8'hA5
```

The testbench compares the received data against the expected byte and reports success when the comparison passes.

The reported simulation result is:

```text
[TB SUCCESS] Loopback Data Matched: 0xa5
```

This result demonstrates the tested loopback scenario; additional corner cases and broader protocol-compliance tests are still required.

### Running the Simulation in ModelSim

From the project root directory, compile the RTL sources and testbench:

```tcl
vlog rtl/*.v
vsim -voptargs="+acc" tb_axi_uart
add wave -r /*
run -all
```

**Prerequisites**

- ModelSim installed and configured.
- All required RTL files present in the `rtl/` directory.
- The testbench module named `tb_axi_uart`.
- No missing source files or compilation errors.

If the testbench depends on additional packages, include those files in the compilation commands.

---

## FPGA Synthesis Results

The design was synthesized for an Intel Cyclone II FPGA using Quartus II.

### Target Device

`EP2C5F256C6`

### Reported Resource Utilization

| Parameter | Reported Result |
|---|---:|
| Logic Elements | 196 / 4,608 |
| Logic Element Utilization | Approximately 4% |
| Registers | 124 |
| Maximum Frequency (Fmax) | 189.72 MHz |

### Resource Utilization

The reported logic utilization is approximately 4% of the target device's 4,608 logic elements.

<details>
<summary>Interpreting the timing result</summary>

The reported Fmax of 189.72 MHz is a synthesis/timing result for the configured design and constraints. It does not, by itself, demonstrate that the complete system has been validated at that clock frequency.

Before using this figure as a verified operating limit, review the Quartus timing report, clock constraints, timing paths, and setup/hold analysis.

</details>

### Synthesis Artifacts

- FPGA synthesis report.
- RTL Viewer architecture.
- Resource utilization summary.
- Timing analysis results.

The screenshots below should be added to the repository's `docs/` directory.

---

## Custom USB-C to UART PCB

A custom two-layer USB-C to UART breakout PCB was designed in KiCad 10 to provide a USB connection to an external UART interface.

The board uses the FT232RL USB-to-UART bridge and an AMS1117-3.3 regulator.

### Main Components

| Reference | Component | Function |
|---|---|---|
| J1 | USB-C receptacle | USB connection and power input |
| U2 | FT232RL | USB-to-UART conversion |
| U1 | AMS1117-3.3 | 3.3 V voltage regulation |
| C1, C2 | SMD capacitors | Power-supply decoupling |
| J2 | 1×6 pin header | External UART/FPGA connection |

*The final pinout, power connections, and component values must be verified against the actual schematic.*

### PCB Design Workflow

1. Create the schematic and define component connectivity.
2. Generate the netlist using Python-assisted scripts.
3. Arrange components and prepare the PCB layout.
4. Route traces using KiCad and Freerouting.
5. Add ground planes to both copper layers.
6. Inspect clearances, footprints, and board geometry.
7. Generate a 3D board visualization.
8. Complete the final Design Rules Check (DRC).
9. Fabricate the PCB and perform hardware validation.

### Important Hardware Considerations

Before fabrication, verify:

- USB-C connector configuration and CC pull-down resistors.
- USB differential-pair routing and connector pin assignments.
- FT232RL supply, decoupling, and configuration requirements.
- Regulator input/output limits and capacitor requirements.
- UART header pinout, voltage levels, and common ground.
- PCB clearances, track widths, and copper-to-edge distances.
- Power distribution and potential conflicts between USB and external power.
- All applicable KiCad DRC and electrical-rule checks.

The final hardware design must be validated against the component datasheets and the actual schematic.

---

## Visual Showcase

Place the project screenshots in the `docs/` folder using the filenames below.

### 1. FPGA Synthesis Report

![FPGA Synthesis Report](docs/fpga_summary.png)

*Quartus II resource utilization and timing results.*

### 2. RTL Architecture

![RTL Architecture](docs/rtl_viewer.png)

*RTL Viewer representation of the synthesized design.*

### 3. Custom USB-C to UART PCB

![USB-C to UART PCB](docs/AXI_UART_PCB.png)

*KiCad 10 3D visualization of the custom PCB.*

### 4. ModelSim Simulation Waveform

![Simulation Waveform](docs/waveform.png)

*Simulation waveform showing the UART communication and loopback test.*

---

## Repository Structure

```text
.
├── rtl/
│   ├── axi_uart_top.v
│   ├── uart_tx.v
│   ├── uart_rx.v
│   ├── baud_gen.v
│   ├── fifo.v
│   └── tb_axi_uart.v
│
├── sim/
│   └── README.md
│
├── pcb/
│   ├── README.md
│   ├── KiCad project files
│   └── Python automation scripts
│
├── docs/
│   ├── fpga_summary.png
│   ├── rtl_viewer.png
│   ├── AXI_UART_PCB.png
│   └── waveform.png
│
└── README.md
```

The directory tree is illustrative. Keep only files and folders that actually exist in the repository.

---

## Getting Started

### Requirements

- Intel Quartus II compatible with the Cyclone II target.
- ModelSim or a compatible Verilog simulator.
- KiCad 10 for PCB inspection and editing.
- Freerouting for the PCB routing workflow, if required.
- Python and any dependencies used by the automation scripts.

### Clone the Repository

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd <YOUR_REPOSITORY_NAME>
```

Replace the placeholders with the actual repository URL and directory name.

### Run the RTL Simulation

Launch ModelSim from the project root and execute:

```tcl
vlog rtl/*.v
vsim -voptargs="+acc" tb_axi_uart
add wave -r /*
run -all
```

Review the simulator output and waveform to confirm the expected testbench behavior.

### Open the PCB Project

1. Navigate to `pcb/`.
2. Open the actual KiCad project file (`.kicad_pro`).
3. Inspect the schematic and PCB layout.
4. Run the electrical-rule and design-rule checks.
5. Review the 3D view and fabrication outputs before manufacturing.

---

## Current Limitations

- The UVM verification environment is still under development.
- Full AXI4-Lite protocol compliance has not yet been established through comprehensive verification.
- The final PCB DRC review is pending.
- The PCB has not yet been fabricated.
- Physical UART communication with the FPGA has not yet been tested.
- Hardware performance and electrical behavior have not yet been validated on a physical board.

These limitations distinguish simulation and synthesis results from completed hardware validation.

---

## Roadmap

- [ ] Complete the UVM verification environment.
- [ ] Add a transaction-based scoreboard.
- [ ] Expand verification with FIFO overflow/underflow and reset scenarios.
- [ ] Verify AXI4-Lite handshake behavior and protocol corner cases.
- [ ] Review timing constraints and critical paths.
- [ ] Finalize PCB electrical and design-rule checks.
- [ ] Generate manufacturing files (Gerber, drill, and BOM).
- [ ] Fabricate and assemble the PCB.
- [ ] Perform physical UART loopback testing.
- [ ] Validate FPGA-to-PC communication through the USB-UART interface.
- [ ] Document measured hardware results and known limitations.

---

## Technologies Used

| Category | Technologies |
|---|---|
| RTL Design | Verilog HDL |
| Bus Interface | AXI4-Lite |
| Serial Communication | UART |
| Simulation | ModelSim |
| FPGA Synthesis | Intel Quartus II |
| FPGA Target | Intel Cyclone II |
| PCB Design | KiCad 10 |
| PCB Routing | Freerouting |
| Automation | Python |
| Verification | Self-checking testbench; UVM in progress |

---

## License

No license has been specified yet. Add a `LICENSE` file before distributing the source code for reuse.

---

## Author

**Hanane Aouragh**

Embedded Systems | FPGA Design | Digital Hardware | PCB Design

Interested in digital design, RTL verification, FPGA-based systems, and hardware-software integration.

---

*This project is a work in progress. Reported simulation and synthesis results are distinguished from hardware results that have not yet been measured.*
