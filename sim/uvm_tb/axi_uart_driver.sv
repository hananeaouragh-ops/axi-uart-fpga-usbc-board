class axi_uart_driver extends uvm_driver #(axi_uart_item);
  `uvm_component_utils(axi_uart_driver)

  virtual axi_uart_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_uart_if)::get(
          this, "", "vif", vif))
      `uvm_fatal("DRV", "Missing virtual interface")
  endfunction

  task run_phase(uvm_phase phase);
    wait (vif.rst_n === 1'b1);
    repeat (2) @(posedge vif.clk);

    forever begin
      seq_item_port.get_next_item(req);
      write_byte(req.data);

      // 120 us at 100 MHz, before reading RX.
      repeat (12000) @(posedge vif.clk);

      read_byte();
      seq_item_port.item_done();
    end
  endtask

  task write_byte(input logic [31:0] data);
    bit aw_done, w_done, b_done;
    aw_done = 0;
    w_done = 0;
    b_done = 0;

    @(negedge vif.clk);
    vif.s_axi_awaddr  = 4'h0;
    vif.s_axi_awvalid = 1;
    vif.s_axi_wdata   = data;
    vif.s_axi_wvalid  = 1;
    vif.s_axi_bready  = 1;

    for (int n = 0; n < 100; n++) begin
      @(posedge vif.clk);

      if (vif.s_axi_awvalid === 1'b1 &&
          vif.s_axi_awready === 1'b1)
        aw_done = 1;

      if (vif.s_axi_wvalid === 1'b1 &&
          vif.s_axi_wready === 1'b1)
        w_done = 1;

      @(negedge vif.clk);
      if (aw_done) vif.s_axi_awvalid = 0;
      if (w_done)  vif.s_axi_wvalid  = 0;

      if (aw_done && w_done) break;
    end

    if (!(aw_done && w_done))
      `uvm_fatal("AXI_TIMEOUT", "Write handshake timeout")

    for (int n = 0; n < 100; n++) begin
      @(posedge vif.clk);
      if (vif.s_axi_bvalid === 1'b1) begin
        if (vif.s_axi_bresp !== 2'b00)
          `uvm_error("BRESP", "Write response is not OKAY")
        b_done = 1;
        break;
      end
    end

    if (!b_done)
      `uvm_fatal("AXI_TIMEOUT", "Write response timeout")

    @(negedge vif.clk);
    vif.s_axi_bready = 0;
  endtask

  task read_byte();
    bit ar_done, r_done;
    ar_done = 0;
    r_done = 0;

    @(negedge vif.clk);
    vif.s_axi_araddr  = 4'h0;
    vif.s_axi_arvalid = 1;
    vif.s_axi_rready  = 1;

    for (int n = 0; n < 100; n++) begin
      @(posedge vif.clk);

      if (vif.s_axi_arvalid === 1'b1 &&
          vif.s_axi_arready === 1'b1)
        ar_done = 1;

      if (vif.s_axi_rvalid === 1'b1 &&
          vif.s_axi_rready === 1'b1) begin
        if (vif.s_axi_rresp !== 2'b00)
          `uvm_error("RRESP", "Read response is not OKAY")
        r_done = 1;
      end

      @(negedge vif.clk);
      if (ar_done) vif.s_axi_arvalid = 0;
      if (ar_done && r_done) break;
    end

    if (!(ar_done && r_done))
      `uvm_fatal("AXI_TIMEOUT", "Read timeout")

    vif.s_axi_rready = 0;
  endtask
endclass
