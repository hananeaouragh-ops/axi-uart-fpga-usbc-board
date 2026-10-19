import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_uart_agent extends uvm_agent;
  `uvm_component_utils(axi_uart_agent)

  axi_uart_driver    driver;
  axi_uart_sequencer sequencer;
  axi_uart_monitor   monitor;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = axi_uart_monitor::type_id::create("monitor", this);
    if (get_is_active() == UVM_ACTIVE) begin
      driver    = axi_uart_driver::type_id::create("driver", this);
      sequencer = axi_uart_sequencer::type_id::create("sequencer", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction
endclass