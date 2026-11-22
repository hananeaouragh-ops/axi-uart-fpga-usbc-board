onerror {abort}
catch {quit -sim}
cd [file dirname [file normalize [info script]]]
file mkdir results
set stamp [clock seconds]
transcript file "results/fifo_$stamp.log"
transcript on
if {![file isdirectory work]} {vlib work}
vmap work work
vlog -sv rtl/fifo.v sim/fifo_tb/tb_fifo_checked.sv
vsim -wlf "results/fifo_$stamp.wlf" work.tb_fifo_checked
run -all
