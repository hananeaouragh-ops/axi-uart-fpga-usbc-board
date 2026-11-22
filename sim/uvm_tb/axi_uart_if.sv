interface axi_uart_if (input logic clk, input logic rst_n);
  // AXI-Lite Write
  logic [3:0]  s_axi_awaddr;
  logic        s_axi_awvalid;
  logic        s_axi_awready;
  logic [31:0] s_axi_wdata;
  logic        s_axi_wvalid;
  logic        s_axi_wready;
  logic [1:0]  s_axi_bresp;
  logic        s_axi_bvalid;
  logic        s_axi_bready;

  // AXI-Lite Read
  logic [3:0]  s_axi_araddr;
  logic        s_axi_arvalid;
  logic        s_axi_arready;
  logic [31:0] s_axi_rdata;
  logic [1:0]  s_axi_rresp;
  logic        s_axi_rvalid;
  logic        s_axi_rready;

  // UART
  logic tx;
  logic rx;

  // Loopback: TX renvoye sur RX
  assign rx = tx;

  initial begin
    s_axi_awaddr  = '0;
    s_axi_awvalid = 1'b0;
    s_axi_wdata   = '0;
    s_axi_wvalid  = 1'b0;
    s_axi_bready  = 1'b0;
    s_axi_araddr  = '0;
    s_axi_arvalid = 1'b0;
    s_axi_rready  = 1'b0;
  end
endinterface