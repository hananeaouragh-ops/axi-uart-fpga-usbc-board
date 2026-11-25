# AXI4-Lite UART: SKY130 physical implementation

Recorded implementation run completed on 25 November 2026 using OpenLane 2.1.11 in Google Colab. The supplied checkpoint was inspected for final metrics and DRC/LVS results; the implementation tools were run in the Colab session, not rerun during publication.

## Results and evidence

| Check | Recorded result |
|---|---:|
| Target | sky130A / sky130_fd_sc_hd |
| Clock period | 10 ns (100 MHz target) |
| Timing corners | 9 (nom/min/max RC combined with TT/SS/FF) |
| Worst setup slack | +2.228416625 ns |
| Worst hold slack | +0.030028481 ns |
| Setup / hold violations | 0 / 0 |
| Max slew / fanout / capacitance violations | 0 / 0 / 0 |
| Detailed routing DRC errors | 0 |
| Antenna violations | 0 |
| Magic DRC errors | 0 |
| Netgen LVS errors | 0; circuits match uniquely |
| Die dimensions | 207.625 x 218.345 micrometres |
| Routed wirelength | 36,944 micrometres |

See [final metrics](reports/final_metrics.json), [Magic log](reports/magic-drc.log), [Netgen report](reports/lvs.netgen.rpt) and [STA reports](reports/sta). Metrics are carried across steps, so instance area/count in the metrics file should not be interpreted as a fresh post-fill cell census. This is a completed implementation run under the saved constraints, not a fabrication/signoff certification or a measured silicon frequency.

## Artifacts

- [GDSII, gzip compressed](results/axi_uart_top.gds.gz)
- [GDS SHA-256](results/SHA256SUMS)
- [Implementation netlist](results/axi_uart_top.nl.v.gz)
- [Implementation DEF](results/axi_uart_top.def.gz)
- [Implementation SDC](results/axi_uart_top.sdc.gz)
- [ASIC RTL snapshot](rtl)
- [Supplied self-checking testbench](sim/tb_axi_uart.v) and [single-byte loopback log](sim/loopback.log)
- [Targeted repair Tcl](scripts/targeted_repair.tcl)
- [Recorded STA configuration](config/sta_config.snapshot.json)

The compressed files contain native implementation formats. To unpack and check the GDS on Linux:

```bash
cd physical_design/results
gzip -dk axi_uart_top.gds.gz
sha256sum -c SHA256SUMS
```

The PDK revision is `bdc9412b3e468c102d01b7cf6337be06ec6e9c9a`. The configuration snapshot contains original Colab paths and requires path adaptation on another machine. This directory is an evidence/artifact package; the complete Colab checkpoint with intermediate ODBs is retained separately. The repair Tcl requires the corresponding pre-repair database and OpenLane environment, and is not a standalone full-flow launcher.

## Implementation work

1. Synthesis of the UART with two 16 x 8 flop-based FIFOs and an RX synchronizer.
2. Floorplanning, tap/endcap insertion, I/O placement and power-grid generation.
3. Global placement, electrical repair and detailed placement.
4. Clock tree synthesis; sink clustering reduced from 25 to 8.
5. Global routing, antenna mitigation and detailed routing.
6. Targeted electrical closure: stronger equivalent NOR cells for `_0959_` and `_0718_`, plus buffered load splitting for overloaded clock/reset-tree branches. Final STA confirmed zero reported electrical violations after rerouting.
7. Fill insertion, parasitic extraction for three RC corners and nine-corner timing analysis.
8. KLayout GDS stream-out, Magic DRC, SPICE extraction and Netgen LVS.

## Validation scope and remaining work

The `rtl/` directory here is the exact ASIC snapshot from the supplied checkpoint; it does not replace the repository's FPGA RTL. It adds a two-flop UART RX synchronizer. The older ModelSim/UVM results in the repository apply to their earlier source revision and were not rerun for this snapshot. The supplied ASIC functional evidence is the `0xA5` loopback test only.

The recorded STA uses OpenLane's base SDC: 10 ns clock, 2 ns input/output delays, 0.25 ns clock uncertainty, 0.15 ns clock transition and 5% derating. An explicit asynchronous RX-to-first-synchronizer timing exception and reset-deassertion integration policy have not been reviewed/validated in this run. ASYNC_REG alone does not establish CDC/MTBF closure. Reports also list constant output endpoints and unannotated drivers; these should be reviewed before claiming complete timing-constraint coverage.

Independent AXI AW/W channel timing, WSTRB behavior, full-FIFO UART integration and broader regression remain open. The project has not been fabricated or tested in silicon. No DFT implementation, formal RTL-to-layout equivalence, IR-drop/EM analysis or foundry-qualified signoff is claimed. Netgen LVS compares extracted layout against the final implementation netlist, not against RTL behavior.
