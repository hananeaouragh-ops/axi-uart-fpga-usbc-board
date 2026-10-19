import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_uart_sequencer extends uvm_sequencer #(axi_uart_item);
  `uvm_component_utils(axi_uart_sequencer)

  function new(string name = "axi_uart_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass