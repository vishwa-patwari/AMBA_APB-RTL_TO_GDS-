set apb_report "/home/vishwa/apb_project/PnR/reports/post_cts/final"
set apb_results "/home/vishwa/apb_project/PnR/results/routing"
set drv_report "/home/vishwa/apb_project/PnR/reports/post_cts/final/drv_count.rpt"

#Assumes flow helpers.tcl has been read.
 read_libraries
 read_verilog $synth_verilog
 link_design $top_module
 read_sdc $sdc_file

 utl::metric "IFP::ord_version" [ord::openroad_git_describe]
 # Note that sta::network instance count is not valid after tapcells are added.
 utl::metric "IFP::instance_count" [sta::network_instance_count]

 initialize_floorplan -site $site \
     -die_area $die_area \
     -core_area $core_area 
     
 #write_def $apb_results/post_floorplan.def
 source $tracks_file

 # remove buffers inserted by synthesis
 remove_buffers
 ################################################################
# I0 Placement(random)
 place_pins -random -hor_layers $io_placer_hor_layer -ver_layers $io_placer_ver_layer

###################################################
# Macro Placement
 if { [have_macros] } {
    global_placement -density $global_place_density
    macro_placement -halo $macro_place_halo -channel $macro_place_channel
}
#write_def $apb_results/post_macro_placement.tcl
 ##########################################################
# Tapcell insertion
 eval tapcell $tapcell_args
#write_def $apb_results/post_tapcell.def

###############################################################
#power distribution network insertion
source $pdn_cfg
pdngen

#write_def $apb_results/post_pdn.def

############################################################
#Global placement
foreach layer_adjustment $global_routing_layer_adjustments {
  lassign $layer_adjustment layer adjustment
  set_global_routing_layer_adjustment $layer $adjustment
}
set_routing_layers -signal $global_routing_layers \
   -clock $global_routing_clock_layers
set_macro_extension 2

global_placement -routability_driven -density $global_place_density \
-pad_left $global_place_pad -pad_right $global_place_pad

# I0 Placement
place_pins -hor_layers $io_placer_hor_layer -ver_layers $io_placer_ver_layer

# checkpoint
#set global_place_db [make_result_file ${design}_${platform}_global_place.db]
#write_db $apb_results/nangate45_global_place.db
#write_def $apb_results/post_global_placement.def

################################################################
# Repair max slew/cap/fanout violations and normalize slews
source $layer_rc_file
set_wire_rc -signal -layer $wire_rc_layer
set_wire_rc -clock -layer $wire_rc_layer_clk
set_dont_use $dont_use

estimate_parasitics -placement

repair_design -slew_margin $slew_margin -cap_margin $cap_margin

repair_tie_fanout -separation $tie_separation $tielo_port
repair_tie_fanout -separation $tie_separation $tiehi_port

####################################################################
set_placement_padding -global -left $detail_place_pad -right $detail_place_pad
detailed_placement


# post resize timing report (ideal clocks)
#report_worst_slack -min -digits 3 > $apb_report/min_slack.rpt
#report_worst_slack -max -digits 3 > $apb_report/max_slack.rpt
#report_tns -digits 3 > $apb_report/tns.rpt

# Check stew repair
#report_check_types -max_slew -max_capacitance -max_fanout -violators > $apb_report/max_cap_fanout.rpt

utl::metric "RSZ::repair_design_buffer_count" [rsz::repair_design_buffer_count]
utl::metric "RSZ::max_slew_slack" [expr [sta::max_slew_check_slack_limit]* 100]
utl::metric "RSZ::max_fanout_slack" [expr [sta::max_fanout_check_slack_limit]* 100]
utl::metric "RSZ::max_capacitance_slack" [expr [sta::max_capacitance_check_slack_limit]* 100]

#write_verilog $apb_results/post_detailed_placement.v
#write_def $apb_results/post_detailed_placement.def

####################################################################################################
# Clock Tree Synthesis
#Clone clock tree inverters next to register loads
# so cts does not try to buffer the inverted clocks.
repair_clock_inverters

clock_tree_synthesis -root_buf $cts_buffer -buf_list $cts_buffer \
  -sink_clustering_enable \
  -sink_clustering_max_diameter $cts_cluster_diameter
  
 #CTs leaves a long wire from the pad to the clock tree root.
repair_clock_nets

# place clock buffers
detailed_placement
#checkpoint
#set cts_db [make_result_file ${design}_${platform}_cts.db]

#write_db $apb_results/cts.db
##########################################################################################
#Setup/hold timingrepair
set_propagated_clock [all_clocks]

# Global routing is fast enough for the flow regressions.
# It is NOT FAST ENOUGH FOR PRODUCTION USE.
set repair_timing_use_grt_parasitics 0
if { $repair_timing_use_grt_parasitics } {
# Global route for parasitics - no guide file requied
global_route -congestion_iterations 100
estimate_parasitics -global_routing
} else {
estimate_parasitics -placement
}

repair_timing

#report_worst_slack -min -digits 3 > $apb_report/min_slack.rpt
#report_worst_slack -max -digits 3 > $apb_report/max_slack.rpt
#report_tns -digits 3 > $apb_report/tns.rpt

# Check stew repair
#report_check_types -max_slew -max_capacitance -max_fanout -violators > $apb_report/max_cap_fanout.rpt


utl::metric "RSZ::worst_slack_min" [sta::worst_slack -min]
utl::metric "RSZ::worst_slack_max" [sta::worst_slack -max]
utl::metric "RSZ::tns_max" [sta::total_negative_slack -max]
utl::metric "RSZ::hold_buffer_count" [rsz::hold_buffer_count]

#####################################################
# Detailed Placement
detailed_placement

# Capture utilization before fillers make it 100%
utl::metric "DPL::utilization" [format %.lf [expr [rsz::utilization]* 100]]
#utl::metric "DPL::design_area" [sta::format_area [rsz::design_area]]

# checkpoint
#set dpl_db [make_result_file ${design}_${platform}_dpl.db]
#write_db $apb_results/cts_dpl.db
#set verilog_file [make_result_file ${design}_${platform}.v]
#write_verilog $apb_results/cts.v

#######################################################
#Global routing
pin_access -bottom_routing_layer $min_routing_layer \
           -top_routing_layer $max_routing_layer
set route_guide [make_result_file $apb_results/${design}_${platform}.route_guide]
global_route -guide_file $route_guide \
   -congestion_iterations 100

set verilog_file [make_result_file $apb_results/${design}_${platform}.v]
write_verilog -remove_cells $filler_cells $verilog_file

# Antenna repair

# repair_antennas -iterations 3

check_antennas
utl::metric "GRT::ANT::errors" [ant::antenna_violation_count]

# Filler placement
filler_placement $filler_cells
check_placement -verbose
# checkpoint
set fill_db [make_result_file ${design}_${platform}_fill.db]
write_db $apb_results/${design}_${platform}.db

#Detailed routing
# Run pin access again after inserting diodes and moving cells
pin_access -bottom_routing_layer $min_routing_layer \
           -top_routing_layer $max_routing_layer
set_thread_count [exec getconf _NPROCESSORS_ONLN]

detailed_route \
    -output_drc [make_result_file "$apb_results/${design}_${platform}_route_drc.rpt"] \
    -output_maze [make_result_file "$apb_results/${design}_${platform}_maze.log"] \
    -no_pin_access \
    -save_guide_updates \
    -bottom_routing_layer $min_routing_layer \
    -top_routing_layer $max_routing_layer \
    -verbose 0

               
write_guides [make_result_file "$apb_results/${design}_${platform}_output_guide.mod"]
set drv_count [detailed_route_num_drvs]

set fp [open $drv_report "w"]
puts $fp "Detailed Route DRVs = $drv_count"
close $fp


check_antennas

utl::metric "DRT::ANT::errors" [ant::antenna_violation_count]
set routed_db [make_result_file $apb_results/${design}_${platform}_route.db]
write_db $routed_db
set routed_def [make_result_file $apb_results/${design}_${platform}_route_final.def]
write_def $routed_def

# Extraction
 if { $rcx_rules_file != ""} {
   define_process_corner  -ext_model_index 0 X
   extract_parasitics -ext_model_file $rcx_rules_file
   set spef_file [make_result_file $apb_results${design}_${platform}.spef]
   write_spef $spef_file
   read_spef $spef_file
} else {
# Use global routing based parasitics inlieu of rc extraction
estimate_parasitics -global_routing
}
# Final Report

# Report checks
report_checks -path_delay min_max -format full_clock_expanded \
    -fields {input_pin slew capacitance} -digits 3 \
    > $apb_report/report_checks.rpt

# Worst slack
report_worst_slack -min -digits 3 > $apb_report/min_slack.rpt
report_worst_slack -max -digits 3 > $apb_report/max_slack.rpt

# TNS
report_tns -digits 3 > $apb_report/tns.rpt

# Slew / Capacitance / Fanout violations
report_check_types -max_slew -max_capacitance -max_fanout -violators -digits 3 \
    > $apb_results/max_cap_fanout.rpt

# Clock skew
report_clock_skew -digits 3 > $apb_report/clock_skew.rpt

# Power
report_power -corner $power_corner > $apb_report/power.rpt

# Floating nets
report_floating_nets -verbose > $apb_report/floating_nets.rpt

# Design area
report_design_area > $apb_report/design_area.rpt


utl::metric "DRT::worst_slack_min" [sta::worst_slack -min]
utl::metric "DRT::worst_slack_max" [sta::worst_slack -max]
utl::metric "DRT::tns_max" [sta::total_negative_slack -max]
utl::metric "DRT::clock_skew" [expr abs([sta::worst_clock_skew -setup])]
#slew/cap/fanout slack/limit
utl::metric "DRT::max_slew_slack" [expr [sta::max_slew_check_slack_limit]* 100]
utl::metric "DRT::max_fanout_slack" [expr [sta::max_fanout_check_slack_limit]* 100]
utl::metric "DRT::max_capacitance_slack" [expr [sta::max_capacitance_check_slack_limit]* 100];
# report clock period as a metric for updating limits
#utl::metric "DRT::clock_period" [get_property [lindex [all_clocks] θ] period]


