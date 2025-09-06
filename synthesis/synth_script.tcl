# ===============================================
# Yosys Synthesis Script
# Project : APB Slave Memory
# Library : Sky130HD
# Author  : Vishwa
# ===============================================

# 1. Read RTL
read_verilog ../rtl/apb_slave_memory.v

# 2. Define top module
hierarchy -check -top apb_slave_memory

# 3. Generic synthesis
proc; opt; fsm; opt; memory; opt
techmap; opt

# 4. Map flip-flops to Sky130HD cells
dfflibmap -liberty /home/vishwa/OpenROAD/test/sky130hd/sky130_fd_sc_hd__tt_025C_1v80.lib

# 5. Map logic to Sky130HD cells
abc -liberty /home/vishwa/OpenROAD/test/sky130hd/sky130_fd_sc_hd__tt_025C_1v80.lib

# 6. Cleanup
clean

# 7. Reports
tee -o reports/synth_stat.rpt stat -liberty /home/vishwa/OpenROAD/test/sky130hd/sky130_fd_sc_hd__tt_025C_1v80.lib
tee -o reports/check.rpt check
tee -o reports/hierarchy.rpt hierarchy
tee -o reports/cell_usage.rpt stat

# 8. Write outputs
write_verilog apb_slave_memory.synth.v
write_json    apb_slave_memory.json


