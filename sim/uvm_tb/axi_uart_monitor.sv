
class axi_uart_monitor extends uvm_monitor;
  `uvm_component_utils(axi_uart_monitor)

  virtual axi_uart_if vif;
  uvm_analysis_port #(axi_uart_item) item_collected_port;
  logic [3:0] addresses[$];
  logic [31:0] values[$];

  function new(string name, uvm_component parent);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_uart_if)::get(
          this, "", "vif", vif))
      `uvm_fatal("MON", "Missing virtual interface")
  endfunction

  task run_phase(uvm_phase phase);
    axi_uart_item item;
    forever begin
      @(posedge vif.clk);
      if (vif.rst_n !== 1'b1) begin
        addresses.delete();
        values.delete();
      end else begin
        if (vif.s_axi_awvalid === 1'b1 &&
            vif.s_axi_awready === 1'b1)
          addresses.push_back(vif.s_axi_awaddr);

        if (vif.s_axi_wvalid === 1'b1 &&
            vif.s_axi_wready === 1'b1)
          values.push_back(vif.s_axi_wdata);

        while (addresses.size() > 0 && values.size() > 0) begin
          item = axi_uart_item::type_id::create("write_item");
          item.addr = addresses.pop_front();
          item.data = values.pop_front();
          item.is_read = 0;
          item_collected_port.write(item);
        end

        if (vif.s_axi_rvalid === 1'b1 &&
            vif.s_axi_rready === 1'b1) begin
          item = axi_uart_item::type_id::create("read_item");
          item.addr = 4'h0;
          item.data = vif.s_axi_rdata;
          item.is_read = 1;
          item_collected_port.write(item);
        end
      end
    end
  endtask
endclass

