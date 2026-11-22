
onerror {abort}
catch {quit -sim}
cd [file dirname [file normalize [info script]]]
file mkdir results
set stamp [clock seconds]
transcript file "results/backpressure_$stamp.log"
transcript on

vlog rtl/baud_gen.v rtl/fifo.v rtl/uart_rx.v rtl/uart_tx.v rtl/axi_uart_top.v
vlog -sv +incdir+sim/uvm_tb sim/uvm_tb/axi_uart_if.sv
vlog -sv +incdir+sim/uvm_tb sim/uvm_tb/axi_uart_pkg.sv
vlog -sv +incdir+sim/uvm_tb sim/uvm_tb/tb_backpressure.sv

vsim -wlf "results/backpressure_$stamp.wlf" -voptargs="+acc" work.tb_backpressure
run 2 ms

