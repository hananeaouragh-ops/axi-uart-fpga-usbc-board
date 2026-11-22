
`timescale 1ns/1ps

module tb_fifo_checked;
  reg clk = 0;
  reg rst_n = 0;
  reg rd = 0;
  reg wr = 0;
  reg [7:0] w_data = 0;
  wire empty, full;
  wire [7:0] r_data;

  logic [7:0] reference_queue[$];
  int cycles = 0;
  int comparisons = 0;

  always #5 clk = ~clk;

  fifo #(.DATA_WIDTH(8), .ADDR_WIDTH(4)) dut (
    .clk(clk), .rst_n(rst_n),
    .rd(rd), .wr(wr), .w_data(w_data),
    .empty(empty), .full(full), .r_data(r_data)
  );

  task check_flags();
    if (empty !== (reference_queue.size() == 0))
      $fatal(1, "EMPTY incorrect: count=%0d", reference_queue.size());
    if (full !== (reference_queue.size() == 16))
      $fatal(1, "FULL incorrect: count=%0d", reference_queue.size());
  endtask

  task step(input bit do_write, input bit do_read,
            input logic [7:0] value);
    bit accept_write, accept_read;
    logic [7:0] expected_byte;

    @(negedge clk);
    check_flags();
    accept_write = do_write && reference_queue.size() < 16;
    accept_read  = do_read  && reference_queue.size() > 0;
    wr = do_write;
    rd = do_read;
    w_data = value;

    @(posedge clk);

    if (accept_read) begin
      expected_byte = reference_queue.pop_front();
      if (r_data !== expected_byte)
        $fatal(1, "DATA mismatch: expected=%02h actual=%02h",
               expected_byte, r_data);
      comparisons++;
    end

    if (accept_write)
      reference_queue.push_back(value);

    #1;
    check_flags();
    cycles++;
  endtask

  task apply_reset();
    @(negedge clk);
    wr = 0;
    rd = 0;
    rst_n = 0;
    reference_queue.delete();
    repeat (3) @(negedge clk);
    check_flags();
    rst_n = 1;
  endtask

  initial begin
    apply_reset();

    // Reading an empty FIFO must not change its state.
    repeat (3) step(0, 1, 0);

    // Fill all 16 entries.
    for (int k=0; k<16; k++)
      step(1, 0, k);
    $display("PASS: FIFO full after 16 writes");

    // Extra writes must not overwrite stored bytes.
    repeat (3) step(1, 0, 8'hEE);

    // Drain and verify original order.
    repeat (16) step(0, 1, 0);
    $display("PASS: overflow attempts preserved data; FIFO empty");

    // Several pointer wraparounds.
    repeat (3) begin
      for (int k=0; k<16; k++)
        step(1, 0, $urandom_range(0,255));
      repeat (16) step(0, 1, 0);
    end
    $display("PASS: pointer wraparound");

    // Simultaneous operations at empty and full boundaries.
    step(1, 1, 8'h42);
    step(0, 1, 0);
    repeat (16) step(1, 0, $urandom_range(0,255));
    step(1, 1, 8'h99);

    // Reset while data is still stored.
    apply_reset();
    $display("PASS: reset discarded pending data");

    // Random read/write combinations.
    repeat (500)
      step($urandom_range(0,1), $urandom_range(0,1),
           $urandom_range(0,255));

    while (reference_queue.size() > 0)
      step(0, 1, 0);

    @(negedge clk);
    wr = 0;
    rd = 0;
    $display("FIFO TEST PASS: cycles=%0d comparisons=%0d",
             cycles, comparisons);
    $finish;
  end

  initial begin
    #100000;
    $fatal(1, "FIFO test timeout");
  end
endmodule

