import uvm_pkg::*;
`include "uvm_macros.svh"

module tb_top;
  logic clk;
  logic rst_n;

  // Clock generation (50 MHz)
  always #10 clk = ~clk;

  initial begin
    clk = 0;
    rst_n = 0;
    #50 rst_n = 1;
  end

  // Interface Instance
  axi_uart_if vif(clk, rst_n);

  // DUT Instance
  axi_uart_top dut (
    .s_axi_aclk(clk),
    .s_axi_aresetn(rst_n),
    .s_axi_awaddr  (vif.s_axi_awaddr),
    .s_axi_awvalid (vif.s_axi_awvalid),
    .s_axi_awready (vif.s_axi_awready),
    .s_axi_wdata   (vif.s_axi_wdata),
    .s_axi_wvalid  (vif.s_axi_wvalid),
    .s_axi_wready  (vif.s_axi_wready),
    .s_axi_bresp   (vif.s_axi_bresp),
    .s_axi_bvalid  (vif.s_axi_bvalid),
    .s_axi_bready  (vif.s_axi_bready),
    .tx            (vif.tx),
    .rx            (vif.rx)
  );

  initial begin
    uvm_config_db#(virtual axi_uart_if)::set(null, "*", "vif", vif);
    run_test("axi_uart_test");
  end
endmodule