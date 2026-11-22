
class axi_uart_backpressure_test extends axi_uart_test;
  `uvm_component_utils(axi_uart_backpressure_test)

  virtual axi_uart_if vif;

  function new(string name="axi_uart_backpressure_test",
               uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_uart_if)::get(
          this, "", "vif", vif))
      `uvm_fatal("VIF", "Missing interface")
  endfunction

  task delayed_read();
    bit received;
    logic [31:0] held_data;
    logic [1:0] held_resp;

    received = 0;
    @(negedge vif.clk);
    vif.s_axi_araddr = 0;
    vif.s_axi_arvalid = 1;
    vif.s_axi_rready = 0;

    for (int n=0; n<100; n++) begin
      @(posedge vif.clk);
      if (vif.s_axi_arready === 1'b1) begin
        received = 1;
        break;
      end
    end

    if (!received)
      `uvm_fatal("TIMEOUT", "AR handshake timeout")

    // Capture the response before accepting it.
    if (vif.s_axi_rvalid !== 1'b1)
      `uvm_fatal("RESPONSE", "Expected RVALID for this DUT")

    held_data = vif.s_axi_rdata;
    held_resp = vif.s_axi_rresp;

    @(negedge vif.clk);
    vif.s_axi_arvalid = 0;

    repeat (5) begin
      @(posedge vif.clk);
      if (vif.s_axi_rvalid !== 1'b1)
        `uvm_error("RVALID_STABILITY",
                   "RVALID dropped while RREADY=0")
      if (vif.s_axi_rdata !== held_data)
        `uvm_error("RDATA_STABILITY",
          $sformatf("Data changed: before=%08h now=%08h",
                    held_data, vif.s_axi_rdata))
      if (vif.s_axi_rresp !== held_resp)
        `uvm_error("RRESP_STABILITY",
                   "RRESP changed while RREADY=0")
    end

    @(negedge vif.clk);
    vif.s_axi_rready = 1;
    @(posedge vif.clk);
    if (vif.s_axi_rvalid !== 1'b1 ||
        vif.s_axi_rresp !== 2'b00)
      `uvm_error("READ_RESPONSE", "Invalid accepted response")
    @(negedge vif.clk);
    vif.s_axi_rready = 0;
  endtask

  task run_phase(uvm_phase phase);
    logic [7:0] data_byte;
    phase.raise_objection(this);

    wait (vif.rst_n === 1'b1);
    repeat (5) @(posedge vif.clk);

    for (int k=0; k<10; k++) begin
      data_byte = 8'hA5 ^ k;
      env.agent.driver.write_byte({24'b0, data_byte});
      repeat (12000) @(posedge vif.clk);
      delayed_read();
    end

    `uvm_info("BACKPRESSURE",
              "Completed 10 reads with RREADY delayed 5 cycles",
              UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass

