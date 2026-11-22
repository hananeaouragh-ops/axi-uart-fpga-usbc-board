
class axi_uart_reset_test extends axi_uart_test;
  `uvm_component_utils(axi_uart_reset_test)

  virtual axi_uart_if vif;

  function new(string name = "axi_uart_reset_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_uart_if)::get(
          this, "", "vif", vif))
      `uvm_fatal("RESET", "Missing virtual interface")
  endfunction

  task run_phase(uvm_phase phase);
    uvm_event reset_request;
    uvm_event reset_done;

    phase.raise_objection(this);
    reset_request = uvm_event_pool::get_global("reset_request");
    reset_done = uvm_event_pool::get_global("reset_done");

    wait (vif.rst_n === 1'b1);
    repeat (5) @(posedge vif.clk);

    // Start a transfer, then interrupt the UART frame.
    env.agent.driver.write_byte(32'hA5);
    wait (vif.tx === 1'b0);
    repeat (1000) @(posedge vif.clk);

    `uvm_info("RESET", "Reset during UART transmission", UVM_LOW)
    reset_request.trigger();
    reset_done.wait_trigger();

    // Exactly one pending byte must be discarded by reset.
    if (env.scoreboard.writes != 1 ||
        env.scoreboard.reads != 0 ||
        env.scoreboard.expected.size() != 1)
      `uvm_fatal("RESET_SETUP", "Expected one pending transfer")

    env.scoreboard.expected.delete();
    env.scoreboard.writes = 0;

    `uvm_info("RESET", "Discarded the interrupted byte", UVM_LOW)

    // No old frame should resume after reset.
    repeat (12000) begin
      @(posedge vif.clk);
      if (vif.tx !== 1'b1)
        `uvm_fatal("RESET_IDLE", "UART did not remain idle after reset")
    end

    // Reuse the normal sequence and its real comparisons.
    seq = axi_uart_base_sequence::type_id::create("after_reset");
    seq.start(env.agent.sequencer);

    if (env.scoreboard.match_count != 10 ||
        env.scoreboard.mismatches != 0)
      `uvm_error("RESET_RECOVERY", "Transfers after reset failed")
    else
      `uvm_info("RESET_RECOVERY",
                "10 loopback transfers matched after reset", UVM_LOW)

    phase.drop_objection(this);
  endtask
endclass

