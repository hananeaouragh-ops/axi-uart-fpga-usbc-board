# AXI4-Lite UART IP Core & Custom USB-C Hardware PCB

An end-to-end embedded design: a Verilog AXI4-Lite UART IP core verified in simulation, synthesized for an Intel Cyclone II FPGA, and paired with a custom USB-C to UART breakout board designed in KiCad 10.

## Key Project Highlights
- **RTL Architecture:** AXI4-Lite slave interface with independent hardware TX/RX FIFOs and a configurable baud rate generator (115200 baud at 100 MHz).
- **Verification:** Self-checking Verilog testbench (ModelSim): AXI write, UART TX, loopback, RX FIFO, AXI read-back; byte `0xA5` matched. A UVM environment (agent, scoreboard) is in progress.
- **FPGA Synthesis:** Compiled on Intel Cyclone II (EP2C5F256C6) reaching 189.72 MHz with a minimal footprint (196 LEs).
- **Hardware:** Custom 2-layer USB-C to UART (FT232RL) breakout board designed in KiCad 10, with Python-automated netlist/placement and Freerouting auto-routing.

## Synthesis Results (Intel Quartus II)
| Parameter | Value |
| --- | --- |
| Target Device | Cyclone II EP2C5F256C6 |
| Logic Elements | 196 / 4,608 (4%) |
| Registers | 124 |
| Max Frequency (fmax) | 189.72 MHz |

## Visual Showcase

### 1. FPGA Synthesis & Resource Utilization (Quartus II)
![FPGA Synthesis Report](docs/fpga_summary.png)

### 2. RTL Architecture (Quartus RTL Viewer)
![RTL Architecture](docs/rtl_viewer.png)

### 3. Custom USB-C to UART PCB (KiCad 10, 3D render)
![USB-C UART PCB 3D Render](docs/AXI_UART_PCB.png)

### 4. Simulation Waveform (ModelSim SE-64)
![Simulation Waveform](docs/waveform.png)

## Hardware (PCB)
| Ref | Component | Function |
| --- | --- | --- |
| J1 | USB-C receptacle | Power and USB data |
| U2 | FT232RL | USB to UART bridge |
| U1 | AMS1117-3.3 | 5 V to 3.3 V regulator |
| C1, C2 | SMD capacitors | Decoupling |
| J2 | 1x6 pin header | Link to the FPGA |

Design flow: Python-generated netlist, scripted placement and design rules, Freerouting, GND planes on both layers, 3D model verification.

**Status:** designed and routed; DRC being finalized; **not yet fabricated or tested**.

## Repository Structure
```
rtl/     axi_uart_top.v, uart_tx.v, uart_rx.v, baud_gen.v, fifo.v, tb_axi_uart.v
sim/     UVM testbench (work in progress)
pcb/     KiCad project and Python scripts
docs/    screenshots
```

## How to Run the Simulation (ModelSim)
```
vlog rtl/*.v
vsim -voptargs="+acc" tb_axi_uart
add wave -r /*
run -all
```
Expected output: `[TB SUCCESS] Loopback Data Matched: 0xa5`

## Roadmap
- [ ] Complete the UVM environment (scoreboard with matched transactions)
- [ ] Finalize DRC and fabricate the PCB
- [ ] Hardware test with the FPGA board
