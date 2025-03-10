
create_clock -period 20.000 -name sys_clk [get_ports sys_clk]
set_property -dict { PACKAGE_PIN R4 IOSTANDARD LVCMOS15 } [get_ports sys_clk]
set_property -dict { PACKAGE_PIN U7 IOSTANDARD LVCMOS15 } [get_ports sys_rst_n]

set_property -dict { PACKAGE_PIN M20 IOSTANDARD LVCMOS33 } [get_ports ehth_mdc]
set_property -dict { PACKAGE_PIN N22 IOSTANDARD LVCMOS33 } [get_ports eth_mdio]
set_property -dict { PACKAGE_PIN N20 IOSTANDARD LVCMOS33 } [get_ports eth_rst_n]

set_property -dict { PACKAGE_PIN V8 IOSTANDARD LVCMOS15 } [get_ports touch_key]

set_property -dict { PACKAGE_PIN V9 IOSTANDARD LVCMOS15 } [get_ports led[0]]
set_property -dict { PACKAGE_PIN Y8 IOSTANDARD LVCMOS15 } [get_ports led[1]]