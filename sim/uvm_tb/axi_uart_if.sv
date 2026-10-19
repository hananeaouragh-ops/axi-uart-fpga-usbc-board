interface axi_uart_if (input logic clk, input logic rst_n);
  // Signals AXI-Lite Write
  logic [3:0]  s_axi_awaddr;
  logic        s_axi_awvalid;
  logic        s_axi_awready;
  logic [31:0] s_axi_wdata;
  logic        s_axi_wvalid;
  logic        s_axi_wready;
  logic [1:0]  s_axi_bresp;
  logic        s_axi_bvalid;
  logic        s_axi_bready;

  // Lines Serial UART
  logic tx;
  logic rx;
endinterface