import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_uart_driver extends uvm_driver #(axi_uart_item);
  `uvm_component_utils(axi_uart_driver)
  virtual axi_uart_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual axi_uart_if)::get(this, "", "vif", vif))
      `uvm_fatal("DRV", "Could not get vif")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      drive_axi_write(req.addr, req.data);
      seq_item_port.item_done();
    end
  endtask

  task drive_axi_write(input logic [3:0] addr, input logic [31:0] data);
    @(posedge vif.clk);
    vif.s_axi_awaddr  <= addr;
    vif.s_axi_awvalid <= 1'b1;
    vif.s_axi_wdata   <= data;
    vif.s_axi_wvalid  <= 1'b1;
    vif.s_axi_bready  <= 1'b1;

    wait(vif.s_axi_awready && vif.s_axi_wready);
    @(posedge vif.clk);
    vif.s_axi_awvalid <= 1'b0;
    vif.s_axi_wvalid  <= 1'b0;
  endtask
endclass