// Top-Level AXI4-Lite UART Peripheral Controller (100 MHz Clock System)
module axi_uart_top #(
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_S_AXI_ADDR_WIDTH = 4
)(
    // Horloge Système (100 MHz) & Reset
    input  wire                          s_axi_aclk,
    input  wire                          s_axi_aresetn,

    // Bus AXI4-Lite : Write Address Channel
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
    input  wire                          s_axi_awvalid,
    output reg                           s_axi_awready,

    // Bus AXI4-Lite : Write Data Channel
    input  wire [C_S_AXI_DATA_WIDTH-1:0] s_axi_wdata,
    input  wire [C_S_AXI_DATA_WIDTH/8-1:0] s_axi_wstrb,
    input  wire                          s_axi_wvalid,
    output reg                           s_axi_wready,

    // Bus AXI4-Lite : Write Response Channel
    output reg  [1:0]                    s_axi_bresp,
    output reg                           s_axi_bvalid,
    input  wire                          s_axi_bready,

    // Bus AXI4-Lite : Read Address Channel
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] s_axi_araddr,
    input  wire                          s_axi_arvalid,
    output reg                           s_axi_arready,

    // Bus AXI4-Lite : Read Data Channel
    output wire [C_S_AXI_DATA_WIDTH-1:0] s_axi_rdata,
    output reg  [1:0]                    s_axi_rresp,
    output reg                           s_axi_rvalid,
    input  wire                          s_axi_rready,

    // Lignes Séries UART
    input  wire                          rx,
    output wire                          tx
);

    // Signaux internes
    wire s_tick;
    wire tx_done_tick, rx_done_tick;
    wire tx_empty, tx_full;
    wire rx_empty, rx_full;
    wire [7:0] rx_data, tx_data_fifo, rx_data_fifo;
    reg  tx_fifo_wr, rx_fifo_rd;

    // Bus de lecture AXI
    assign s_axi_rdata = {24'h0, rx_data_fifo};

    // Générateur d'Horloge Baud Rate
    baud_gen #(.CLK_FREQ(100000000), .BAUD_RATE(115200)) baud_gen_inst (
        .clk(s_axi_aclk),
        .rst_n(s_axi_aresetn),
        .s_tick(s_tick)
    );

    // Récepteur UART & FIFO RX
    uart_rx uart_rx_inst (
        .clk(s_axi_aclk),
        .rst_n(s_axi_aresetn),
        .rx(rx),
        .s_tick(s_tick),
        .rx_done_tick(rx_done_tick),
        .dout(rx_data)
    );

    fifo #(.DATA_WIDTH(8), .ADDR_WIDTH(4)) rx_fifo_inst (
        .clk(s_axi_aclk),
        .rst_n(s_axi_aresetn),
        .rd(rx_fifo_rd),
        .wr(rx_done_tick),
        .w_data(rx_data),
        .empty(rx_empty),
        .full(rx_full),
        .r_data(rx_data_fifo)
    );

    // Émetteur UART & FIFO TX
    fifo #(.DATA_WIDTH(8), .ADDR_WIDTH(4)) tx_fifo_inst (
        .clk(s_axi_aclk),
        .rst_n(s_axi_aresetn),
        .rd(tx_done_tick),
        .wr(tx_fifo_wr),
        .w_data(s_axi_wdata[7:0]),
        .empty(tx_empty),
        .full(tx_full),
        .r_data(tx_data_fifo)
    );

    uart_tx uart_tx_inst (
        .clk(s_axi_aclk),
        .rst_n(s_axi_aresetn),
        .tx_start(~tx_empty),
        .s_tick(s_tick),
        .din(tx_data_fifo),
        .tx_done_tick(tx_done_tick),
        .tx(tx)
    );

    // Logique d'Écriture AXI4-Lite
    always @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (!s_axi_aresetn) begin
            s_axi_awready <= 1'b0;
            s_axi_wready  <= 1'b0;
            s_axi_bvalid  <= 1'b0;
            s_axi_bresp   <= 2'b00;
            tx_fifo_wr    <= 1'b0;
        end else begin
            tx_fifo_wr <= 1'b0;
            if (~s_axi_awready && s_axi_awvalid && s_axi_wvalid) begin
                s_axi_awready <= 1'b1;
                s_axi_wready  <= 1'b1;
                if (s_axi_awaddr[3:0] == 4'h0 && !tx_full) begin
                    tx_fifo_wr <= 1'b1;
                end
            end else begin
                s_axi_awready <= 1'b0;
                s_axi_wready  <= 1'b0;
            end

            if (s_axi_awready && s_axi_wready) begin
                s_axi_bvalid <= 1'b1;
            end else if (s_axi_bready && s_axi_bvalid) begin
                s_axi_bvalid <= 1'b0;
            end
        end
    end

    // Logique de Lecture AXI4-Lite
    always @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (!s_axi_aresetn) begin
            s_axi_arready <= 1'b0;
            s_axi_rvalid  <= 1'b0;
            s_axi_rresp   <= 2'b00;
            rx_fifo_rd    <= 1'b0;
        end else begin
            rx_fifo_rd <= 1'b0;
            if (~s_axi_arready && s_axi_arvalid) begin
                s_axi_arready <= 1'b1;
                s_axi_rvalid  <= 1'b1;
                if (s_axi_araddr[3:0] == 4'h0 && !rx_empty) begin
                    rx_fifo_rd <= 1'b1;
                end
            end else begin
                s_axi_arready <= 1'b0;
            end

            if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
            end
        end
    end

endmodule