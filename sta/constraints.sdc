# ===== Clock =====
create_clock -name pclk -period 10 [get_ports pclk]
set_clock_uncertainty 0.1 [get_clocks pclk]

# ===== Reset =====
set_false_path -from [get_ports prst_n]

# ===== Input Ports (excluding pclk, prst_n) =====
set_input_delay 2 -clock pclk [get_ports {paddr pwrite penable pselx pwdata}]
set_input_delay 1 -clock pclk [get_ports {paddr pwrite penable pselx pwdata}]
set_drive 0 [get_ports {paddr pwrite penable pselx pwdata}]

# ===== Output Ports =====
set_output_delay 2 -clock pclk [get_ports {prdata pready pslverr}]
set_output_delay 1 -clock pclk [get_ports {prdata pready pslverr}]
set_load 0.1 [get_ports {prdata pready pslverr}]

# ===== Report =====
report_checks

