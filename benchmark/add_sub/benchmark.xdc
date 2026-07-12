####################################################
## Clock
####################################################

set_property PACKAGE_PIN N18 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

create_clock -name sys_clk -period 20.000 [get_ports clk]

####################################################
## Reset
####################################################

set_property PACKAGE_PIN U20 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]