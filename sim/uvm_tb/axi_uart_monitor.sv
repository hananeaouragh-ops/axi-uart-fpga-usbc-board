import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_uart_monitor extends uvm_monitor;
  `uvm_component_utils(axi_uart_monitor)

  virtual axi_uart_if vif;
  uvm_analysis_port #(axi_uart_item) item_collected_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_uart_if)::get(this, "", "vif", vif))
      `uvm_fatal("MON", "Impossible d'obtenir l'interface vif")
  endfunction

  task run_phase(uvm_phase phase);
    axi_uart_item item;
    forever begin
      @(posedge vif.clk);
      // Capture d'une transaction d'écriture AXI valide
      if (vif.s_axi_awvalid && vif.s_axi_awready) begin
        item = axi_uart_item::type_id::create("item");
        item.addr = vif.s_axi_awaddr;
        item.data = vif.s_axi_wdata;
        item_collected_port.write(item);
      end
    end
  endtask
endclass