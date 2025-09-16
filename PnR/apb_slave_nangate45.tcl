# gcd flow pipe cleaner
source "/home/vishwa/OpenROAD/test/helpers.tcl"
source "/home/vishwa/OpenROAD/test/flow_helpers.tcl"
source "/home/vishwa/OpenROAD/test/Nangate45/Nangate45.vars"

set design "apb_slave_memory"
set top_module "apb_slave_memory"
set synth_verilog "/home/vishwa/apb_project/synthesis/apb_slave_memory.synth.v"
set sdc_file "/home/vishwa/apb_project/sta/constraints.sdc"
set die_area {0 0 150 150}
set core_area {10 10 140 140}



#source  "flow_floorplan.tcl" 
#source   "flow_pdn.tcl"
#source   "flow_globalplacement.tcl"
#source   "flow_detailedplacement.tcl"
#source   "flow_cts.tcl"
source   "flow_routing.tcl"
#source -echo "/home/vishwa/OpenROAD/test/flow.tcl"
