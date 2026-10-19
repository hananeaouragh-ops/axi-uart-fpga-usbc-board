import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_uart_base_sequence extends uvm_sequence #(axi_uart_item);
  `uvm_object_utils(axi_uart_base_sequence)

  function new(string name = "axi_uart_base_sequence");
    super.new(name);
  endfunction

  virtual task body();
    axi_uart_item item;
    repeat (10) begin
      item = axi_uart_item::type_id::create("item");
      start_item(item);
      if (!item.randomize()) begin
        `uvm_error("SEQ", "Échec de la randomisation")
      end
      finish_item(item);
    end
  endtask
endclass