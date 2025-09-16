set apb_report "/home/vishwa/apb_project/PnR/reports"
set apb_results "/home/vishwa/apb_project/PnR/results/floorplan"
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
     
 write_def $apb_results/post_floorplan.def
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
write_def $apb_results/post_macro_placement.tcl
 ##########################################################
# Tapcell insertion
 eval tapcell $tapcell_args
write_def $apb_results/post_tapcell.def
