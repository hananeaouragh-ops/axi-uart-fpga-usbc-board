
class axi_uart_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi_uart_scoreboard)

  uvm_analysis_imp #(axi_uart_item, axi_uart_scoreboard)
    item_collected_export;

  logic [7:0] expected[$];
  int unsigned writes = 0;
  int unsigned reads = 0;
  int unsigned match_count = 0;
  int unsigned mismatches = 0;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    item_collected_export = new("item_collected_export", this);
  endfunction

  function void write(axi_uart_item item);
    logic [7:0] exp;

    if (!item.is_read) begin
      if (item.addr === 4'h0) begin
        expected.push_back(item.data[7:0]);
        writes++;
      end
    end else begin
      reads++;
      if (expected.size() == 0) begin
        mismatches++;
        `uvm_error("UNEXPECTED_RX", "Read without expected byte")
      end else begin
        exp = expected.pop_front();
        if (item.data[7:0] !== exp) begin
          mismatches++;
          `uvm_error("MISMATCH",
            $sformatf("Expected=%02h Actual=%02h",
                      exp, item.data[7:0]))
        end else begin
          match_count++;
          `uvm_info("MATCH",
            $sformatf("Expected=%02h Actual=%02h",
                      exp, item.data[7:0]), UVM_LOW)
        end
      end
    end
  endfunction

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);

    if (expected.size() != 0)
      `uvm_error("MISSING_RX",
        $sformatf("%0d bytes not received", expected.size()))

    if (writes != 10 || reads != 10 ||
        match_count != 10 || mismatches != 0)
      `uvm_error("CHECK", "Expected 10 correct loopback transfers")
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SUMMARY",
      $sformatf("writes=%0d reads=%0d match_count=%0d mismatches=%0d",
                writes, reads, match_count, mismatches), UVM_LOW)
  endfunction
endclass

