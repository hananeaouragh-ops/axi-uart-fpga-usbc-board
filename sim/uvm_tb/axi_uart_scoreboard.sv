import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_uart_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi_uart_scoreboard)
  uvm_analysis_imp #(axi_uart_item, axi_uart_scoreboard) item_collected_export;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    item_collected_export = new("item_collected_export", this);
  endfunction

  function void write(axi_uart_item item);
    `uvm_info("SCOREBOARD", $sformatf("Verified Data Transmitted over AXI: 0x%0h", item.data), UVM_LOW)
  endfunction
endclass