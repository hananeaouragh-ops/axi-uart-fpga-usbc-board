// Baud Rate Generator (100 MHz Clock -> 115200 Baud with 16x Oversampling)
module baud_gen #(
    parameter CLK_FREQ  = 100000000,
    parameter BAUD_RATE = 115200
)(
    input  wire clk,
    input  wire rst_n,
    output reg  s_tick
);

    // Diviseur Modulo N = CLK_FREQ / (16 * BAUD_RATE)
    // Pour 100 MHz et 115 200 Baud : N = 100_000_000 / 1_843_200 = 54
    localparam N = CLK_FREQ / (16 * BAUD_RATE);

    // Registre de compteur sur 16 bits (compatible synthèse Verilog-2001)
    reg [15:0] count_reg, count_next;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_reg <= 16'd0;
        end else begin
            count_reg <= count_next;
        end
    end

    always @* begin
        if (count_reg == (N - 1)) begin
            count_next = 16'd0;
            s_tick     = 1'b1;
        end else begin
            count_next = count_reg + 1'b1;
            s_tick     = 1'b0;
        end
    end

endmodule