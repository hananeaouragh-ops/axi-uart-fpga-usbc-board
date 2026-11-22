`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
import axi_uart_pkg::*;

`include "axi_uart_reset_test.sv"
module tb_reset;
  // ... (kolchi mn "logic clk;" w l'te7t bla tbdil)
  logic clk;
  logic rst_n;

  // Horloge 100 MHz
  always #5 clk = ~clk;

  initial begin
    clk   = 0;
    rst_n = 0;
    #50;
    rst_n = 1;
  end

  // Interface AXI UART
  axi_uart_if vif (
    .clk   (clk),
    .rst_n (rst_n)
  );

  // DUT
  axi_uart_top dut (
    .s_axi_aclk    (clk),
    .s_axi_aresetn (rst_n),

    .s_axi_awaddr  (vif.s_axi_awaddr),
    .s_axi_awvalid (vif.s_axi_awvalid),
    .s_axi_awready (vif.s_axi_awready),

    .s_axi_wdata   (vif.s_axi_wdata),
    .s_axi_wstrb   (4'hF),
    .s_axi_wvalid  (vif.s_axi_wvalid),
    .s_axi_wready  (vif.s_axi_wready),

    .s_axi_bresp   (vif.s_axi_bresp),
    .s_axi_bvalid  (vif.s_axi_bvalid),
    .s_axi_bready  (vif.s_axi_bready),

    .s_axi_araddr  (vif.s_axi_araddr),
    .s_axi_arvalid (vif.s_axi_arvalid),
    .s_axi_arready (vif.s_axi_arready),

    .s_axi_rdata   (vif.s_axi_rdata),
    .s_axi_rresp   (vif.s_axi_rresp),
    .s_axi_rvalid  (vif.s_axi_rvalid),
    .s_axi_rready  (vif.s_axi_rready),

    .tx            (vif.tx),
    .rx            (vif.rx)
  );

  // Test UVM
  initial begin
    uvm_config_db#(virtual axi_uart_if)::set(null, "*", "vif", vif);
    run_test("axi_uart_reset_test");
  end


  initial begin : reset_controller
    uvm_event request_event;
    uvm_event done_event;
    request_event = uvm_event_pool::get_global("reset_request");
    done_event = uvm_event_pool::get_global("reset_done");

    request_event.wait_trigger();
    @(negedge clk);
    rst_n = 0;

    repeat (5) @(negedge clk);

    if (vif.tx !== 1'b1 ||
        vif.s_axi_bvalid !== 1'b0 ||
        vif.s_axi_rvalid !== 1'b0)
      $fatal(1, "RESET outputs are incorrect");

    rst_n = 1;
    repeat (2) @(negedge clk);
    done_event.trigger();
  end

  initial begin : watchdog
    #3000000;
    $fatal(1, "Reset test timeout: 3 ms");
  end
endmodule

