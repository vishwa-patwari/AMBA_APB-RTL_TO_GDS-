# -------- Load library --------
read_liberty /home/vishwa/OpenROAD/test/Nangate45/Nangate45_typ.lib

# -------- Load synthesized netlist --------
read_verilog /home/vishwa/apb_project/synthesis/apb_slave_memory.synth.v
link_design apb_slave_memory

# -------- Read constraints --------
read_sdc /home/vishwa/apb_project/sta/constraints.sdc

# -------- Reports --------
report_checks -path_delay min_max -fields {slew cap input_pins nets fanout} -digits 4 > reports/timing.rpt
report_tns   > reports/tns.rpt
report_wns   > reports/wns.rpt
report_clock > reports/clocks.rpt

exit

