package axi_uart_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "axi_uart_item.sv"
  `include "axi_uart_sequencer.sv"
  `include "axi_uart_sequence.sv"
  `include "axi_uart_driver.sv"
  `include "axi_uart_monitor.sv"
  `include "axi_uart_agent.sv"
  `include "axi_uart_scoreboard.sv"
  `include "axi_uart_env.sv"
  `include "axi_uart_test.sv"
endpackage