class axi_uart_base_sequence extends uvm_sequence #(axi_uart_item);
  `uvm_object_utils(axi_uart_base_sequence)

  function new(string name = "axi_uart_base_sequence");
    super.new(name);
  endfunction

  task body();
    axi_uart_item item;

    for (int k = 0; k < 10; k++) begin
      item = axi_uart_item::type_id::create("item");
      start_item(item);

      if (!item.randomize() with {
        addr == 4'h0;
        data inside {[0:255]};
      }) begin
        `uvm_fatal("RAND", "Randomization failed")
      end

      case (k)
        0: item.data = 32'h00;
        1: item.data = 32'hFF;
        2: item.data = 32'h55;
        3: item.data = 32'hAA;
      endcase

      item.is_read = 0;
      finish_item(item);
    end
  endtask
endclass
