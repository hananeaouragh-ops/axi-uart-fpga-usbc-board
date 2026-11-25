`timescale 1ns / 1ps

module tb_axi_uart;

    reg clk;
    reg rst_n;

    // Signaux Bus AXI
    reg  [3:0]  awaddr;
    reg         awvalid;
    wire        awready;
    reg  [31:0] wdata;
    reg         wvalid;
    wire        wready;
    wire [1:0]  bresp;
    wire        bvalid;
    reg         bready;

    reg  [3:0]  araddr;
    reg         arvalid;
    wire        arready;
    wire [31:0] rdata;
    wire [1:0]  rresp;
    wire        rvalid;
    reg         rready;

    wire tx, rx;

    // Bouclage matériel TX vers RX (Loopback)
    assign rx = tx;

    // Instanciation de l'UUT (Unit Under Test)
    axi_uart_top uut (
        .s_axi_aclk(clk),
        .s_axi_aresetn(rst_n),
        .s_axi_awaddr(awaddr),
        .s_axi_awvalid(awvalid),
        .s_axi_awready(awready),
        .s_axi_wdata(wdata),
        .s_axi_wstrb(4'b1111),
        .s_axi_wvalid(wvalid),
        .s_axi_wready(wready),
        .s_axi_bresp(bresp),
        .s_axi_bvalid(bvalid),
        .s_axi_bready(bready),
        .s_axi_araddr(araddr),
        .s_axi_arvalid(arvalid),
        .s_axi_arready(arready),
        .s_axi_rdata(rdata),
        .s_axi_rresp(rresp),
        .s_axi_rvalid(rvalid),
        .s_axi_rready(rready),
        .rx(rx),
        .tx(tx)
    );

    // Génération de l'horloge 100 MHz (Période = 10ns)
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        awvalid = 0;
        wvalid = 0;
        bready = 1;
        arvalid = 0;
        rready = 1;

        #100;
        rst_n = 1;
        #100;

        // Étape 1 : Écriture de la donnée 0xA5 via AXI4-Lite
        $display("[TB] Writing Byte 0xA5 over AXI4-Lite bus...");
        awaddr  = 4'h0;
        wdata   = 32'h000000A5;
        awvalid = 1;
        wvalid  = 1;

        wait(awready && wready);
        #10;
        awvalid = 0;
        wvalid  = 0;

        // Attente de la transmission série et réception complète
        #120000;

        // Étape 2 : Lecture de la donnée reçue dans la FIFO RX via AXI4-Lite
        $display("[TB] Reading Byte back from RX FIFO over AXI4-Lite...");
        araddr  = 4'h0;
        arvalid = 1;
        wait(arready);
        #10;
        arvalid = 0;

        wait(rvalid);
        if (rdata[7:0] == 8'hA5) begin
            $display("[TB SUCCESS] Loopback Data Matched: 0x%h", rdata[7:0]);
        end else begin
            $display("[TB ERROR] Data Mismatch! Expected 0xA5, got 0x%h", rdata[7:0]);
        end

        #1000;
        $finish;
    end

endmodule