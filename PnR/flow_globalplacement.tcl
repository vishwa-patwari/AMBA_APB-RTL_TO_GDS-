set apb_report "/home/vishwa/apb_project/PnR/reports"
set apb_results "/home/vishwa/apb_project/PnR/results/globalplacement"
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
write_db $apb_results/nangate45_global_place.db
write_def $apb_results/post_global_placement.def

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
