import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_uart_test extends uvm_test;
  `uvm_component_utils(axi_uart_test)

  axi_uart_env           env;
  axi_uart_base_sequence seq;

  function new(string name = "axi_uart_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi_uart_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq = axi_uart_base_sequence::type_id::create("seq");
    seq.start(env.agent.sequencer);
    #500;
    phase.drop_objection(this);
  endtask
endclass