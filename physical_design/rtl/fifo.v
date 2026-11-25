// Synchronous FIFO Buffer
module fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  rd,
    input  wire                  wr,
    input  wire [DATA_WIDTH-1:0] w_data,
    output wire                  empty,
    output wire                  full,
    output wire [DATA_WIDTH-1:0] r_data
);

    reg [DATA_WIDTH-1:0] array_reg [2**ADDR_WIDTH-1:0];
    reg [ADDR_WIDTH-1:0] w_ptr_reg, w_ptr_next;
    reg [ADDR_WIDTH-1:0] r_ptr_reg, r_ptr_next;
    reg full_reg, empty_reg, full_next, empty_next;

    wire wr_en;

    always @(posedge clk) begin
        if (wr_en)
            array_reg[w_ptr_reg] <= w_data;
    end

    assign r_data = array_reg[r_ptr_reg];
    assign wr_en  = wr & ~full_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            w_ptr_reg <= 0;
            r_ptr_reg <= 0;
            full_reg  <= 1'b0;
            empty_reg <= 1'b1;
        end else begin
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            full_reg  <= full_next;
            empty_reg <= empty_next;
        end
    end

    always @* begin
        w_ptr_next = w_ptr_reg;
        r_ptr_next = r_ptr_reg;
        full_next  = full_reg;
        empty_next = empty_reg;

        case ({wr_en, rd & ~empty_reg})
            2'b01: begin // Lecture
                r_ptr_next = r_ptr_reg + 1'b1;
                full_next  = 1'b0;
                if (r_ptr_next == w_ptr_reg)
                    empty_next = 1'b1;
            end
            2'b10: begin // Écriture
                w_ptr_next = w_ptr_reg + 1'b1;
                empty_next = 1'b0;
                if (w_ptr_next == r_ptr_reg)
                    full_next = 1'b1;
            end
            2'b11: begin // Lecture et Écriture simultanées
                w_ptr_next = w_ptr_reg + 1'b1;
                r_ptr_next = r_ptr_reg + 1'b1;
            end
            default: ;
        endcase
    end

    assign full  = full_reg;
    assign empty = empty_reg;

endmodule