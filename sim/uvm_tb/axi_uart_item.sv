import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_uart_item extends uvm_sequence_item;
  rand logic [3:0]  addr;
  rand logic [31:0] data;
  logic             rx_data;

  `uvm_object_utils_begin(axi_uart_item)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "axi_uart_item");
    super.new(name);
  endfunction
endclass