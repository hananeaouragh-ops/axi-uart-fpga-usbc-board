
source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
source $::env(SCRIPTS_DIR)/openroad/common/resizer.tcl
load_rsz_corners
read_current_odb
set_propagated_clock [all_clocks]
source $::env(SCRIPTS_DIR)/openroad/common/set_rc.tcl

# Stronger equivalent cells, preserving logic.

set db [ord::get_db]
set block [ord::get_db_block]

foreach {name cell} {
    _0959_ sky130_fd_sc_hd__nor3_4
    _0718_ sky130_fd_sc_hd__nor4_4
} {
    set inst [$block findInst $name]
    set master [$db findMaster $cell]
    if {$inst == "NULL" || $master == "NULL"} {
        error "Missing instance or cell: $name $cell"
    }
    if {![$inst swapMaster $master]} {
        error "Cell replacement failed: $name"
    }
    puts "RESIZED $name -> $cell"
}


# Split each overloaded branch into two buffered branches.
set block [ord::get_db_block]
set master [[ord::get_db] findMaster sky130_fd_sc_hd__clkbuf_8]
if {$master == "NULL"} {error "Buffer master not found"}

foreach driver {
    clkbuf_2_0__f_s_axi_aclk
    clkbuf_2_1__f_s_axi_aclk
    clkbuf_2_2__f_s_axi_aclk
    clkbuf_2_3__f_s_axi_aclk
    fanout111
} {
    set inst [$block findInst $driver]
    if {$inst == "NULL"} {error "Missing instance: $driver"}
    set output [$inst findITerm X]
    set net [$output getNet]
    set loads {}
    foreach terminal [$net getITerms] {
        if {[$terminal getIoType] == "INPUT"} {
            lappend loads $terminal
        }
    }
    set count [llength $loads]
    puts "TARGET $driver loads=$count"
    if {$count <= 8} {continue}
    if {$count > 20} {error "Unexpected fanout on $driver"}

    set midpoint [expr {($count + 1) / 2}]
    for {set branch 0} {$branch < 2} {incr branch} {
        if {$branch == 0} {
            set group [lrange $loads 0 [expr {$midpoint-1}]]
        } else {
            set group [lrange $loads $midpoint end]
        }

        set name "closure_${driver}_${branch}"
        set newnet [odb::dbNet_create $block "${name}_net"]
        set buffer [odb::dbInst_create $block $master $name]
        [$buffer findITerm A] connect $net
        [$buffer findITerm X] connect $newnet

        set xsum 0
        set ysum 0
        foreach terminal $group {
            lassign [[$terminal getInst] getLocation] x y
            incr xsum $x
            incr ysum $y
            $terminal disconnect
            $terminal connect $newnet
        }
        set length [llength $group]
        $buffer setLocation [expr {$xsum/$length}] [expr {$ysum/$length}]
        $buffer setPlacementStatus PLACED
    }
}

source $::env(SCRIPTS_DIR)/openroad/common/dpl.tcl
source $::env(SCRIPTS_DIR)/openroad/common/grt.tcl
write_views
