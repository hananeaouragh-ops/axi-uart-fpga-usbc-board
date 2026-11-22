
onerror {abort}
catch {quit -sim}

cd [file dirname [file normalize [info script]]]
file mkdir results

set stamp [clock seconds]
transcript file "results/uvm_$stamp.log"
transcript on

if {![file isdirectory work]} {
    vlib work
}
vmap work work

vlog rtl/baud_gen.v rtl/fifo.v rtl/uart_rx.v rtl/uart_tx.v rtl/axi_uart_top.v
vlog -sv +incdir+sim/uvm_tb sim/uvm_tb/axi_uart_if.sv
vlog -sv +incdir+sim/uvm_tb sim/uvm_tb/axi_uart_pkg.sv
vlog -sv +incdir+sim/uvm_tb sim/uvm_tb/tb_top.sv

vsim -wlf "results/uvm_$stamp.wlf" -voptargs="+acc" work.tb_top
run 2 ms

