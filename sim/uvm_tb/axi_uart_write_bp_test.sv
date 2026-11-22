
class axi_uart_write_bp_test extends axi_uart_test;
  `uvm_component_utils(axi_uart_write_bp_test)

  virtual axi_uart_if vif;

  function new(string name="axi_uart_write_bp_test",
               uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_uart_if)::get(
          this, "", "vif", vif))
      `uvm_fatal("VIF", "Missing interface")
  endfunction

  task delayed_write(input logic [7:0] value);
    bit aw_done, w_done, response_seen;
    logic [1:0] held_resp;
    aw_done = 0;
    w_done = 0;
    response_seen = 0;

    @(negedge vif.clk);
    vif.s_axi_awaddr = 0;
    vif.s_axi_awvalid = 1;
    vif.s_axi_wdata = {24'b0, value};
    vif.s_axi_wvalid = 1;
    vif.s_axi_bready = 0;

    for (int n=0; n<100; n++) begin
      @(posedge vif.clk);
      if (vif.s_axi_awvalid === 1'b1 &&
          vif.s_axi_awready === 1'b1)
        aw_done = 1;
      if (vif.s_axi_wvalid === 1'b1 &&
          vif.s_axi_wready === 1'b1)
        w_done = 1;

      @(negedge vif.clk);
      if (aw_done) vif.s_axi_awvalid = 0;
      if (w_done)  vif.s_axi_wvalid = 0;
      if (aw_done && w_done) break;
    end

    if (!(aw_done && w_done))
      `uvm_fatal("TIMEOUT", "Write handshake timeout")

    // WDATA may change after its handshake.
    vif.s_axi_wdata = 32'hDEADBEEF;

    for (int n=0; n<100; n++) begin
      @(posedge vif.clk);
      if (vif.s_axi_bvalid === 1'b1) begin
        held_resp = vif.s_axi_bresp;
        response_seen = 1;
        break;
      end
    end

    if (!response_seen)
      `uvm_fatal("TIMEOUT", "Write response timeout")

    repeat (5) begin
      @(posedge vif.clk);
      if (vif.s_axi_bvalid !== 1'b1)
        `uvm_error("BVALID_STABILITY",
                   "BVALID dropped while BREADY=0")
      if (vif.s_axi_bresp !== held_resp)
        `uvm_error("BRESP_STABILITY",
                   "BRESP changed while BREADY=0")
    end

    @(negedge vif.clk);
    vif.s_axi_bready = 1;
    @(posedge vif.clk);
    if (vif.s_axi_bvalid !== 1'b1 ||
        vif.s_axi_bresp !== 2'b00)
      `uvm_error("WRITE_RESPONSE", "Invalid accepted response")

    @(negedge vif.clk);
    vif.s_axi_bready = 0;

    // A completed response must clear.
    @(negedge vif.clk);
    if (vif.s_axi_bvalid !== 1'b0)
      `uvm_error("BVALID_CLEAR", "Response did not clear")
  endtask

  task run_phase(uvm_phase phase);
    logic [7:0] value;
    phase.raise_objection(this);
    wait (vif.rst_n === 1'b1);
    repeat (5) @(posedge vif.clk);

    for (int k=0; k<10; k++) begin
      value = 8'h50 + k;
      delayed_write(value);
      repeat (12000) @(posedge vif.clk);
      env.agent.driver.read_byte();
    end

    `uvm_info("WRITE_BP",
              "Completed 10 writes with BREADY delayed 5 cycles",
              UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass

