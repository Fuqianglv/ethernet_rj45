# CLOCK and RESET
create_clock -period 20.000 -name sys_clk [get_ports sys_clk]
set_property -dict { PACKAGE_PIN R4 IOSTANDARD LVCMOS15 } [get_ports sys_clk]
set_property -dict { PACKAGE_PIN U7 IOSTANDARD LVCMOS15 } [get_ports sys_rst_n]

# Ethernet 
create_clock -period 8.000 -name eth_rxc [get_ports eth_rxc]
set_property -dict { PACKAGE_PIN M20 IOSTANDARD LVCMOS33 } [get_ports eth_mdc]
set_property -dict { PACKAGE_PIN N22 IOSTANDARD LVCMOS33 } [get_ports eth_mdio]

set_property -dict { PACKAGE_PIN N20 IOSTANDARD LVCMOS33 } [get_ports eth_rst_n]

set_property -dict { PACKAGE_PIN Y18 IOSTANDARD LVCMOS33 } [get_ports eth_rxc]
set_property -dict { PACKAGE_PIN Y21 IOSTANDARD LVCMOS33 } [get_ports eth_rx_ctl]
set_property -dict { PACKAGE_PIN Y22 IOSTANDARD LVCMOS33 } [get_ports eth_rxd[0]]
set_property -dict { PACKAGE_PIN AB21 IOSTANDARD LVCMOS33 } [get_ports eth_rxd[1]]
set_property -dict { PACKAGE_PIN AB22 IOSTANDARD LVCMOS33 } [get_ports eth_rxd[2]]
set_property -dict { PACKAGE_PIN Y19 IOSTANDARD LVCMOS33 } [get_ports eth_rxd[3]]

set_property -dict { PACKAGE_PIN W19 IOSTANDARD LVCMOS33 } [get_ports eth_txc]
set_property -dict { PACKAGE_PIN W20 IOSTANDARD LVCMOS33 } [get_ports eth_tx_ctl]
set_property -dict { PACKAGE_PIN W22 IOSTANDARD LVCMOS33 } [get_ports eth_txd[0]]
set_property -dict { PACKAGE_PIN W21 IOSTANDARD LVCMOS33 } [get_ports eth_txd[1]]
set_property -dict { PACKAGE_PIN T20 IOSTANDARD LVCMOS33 } [get_ports eth_txd[2]]
set_property -dict { PACKAGE_PIN P20 IOSTANDARD LVCMOS33 } [get_ports eth_txd[3]]

# TOUCH KEY and LED
set_property -dict { PACKAGE_PIN V8 IOSTANDARD LVCMOS15 } [get_ports touch_key]
set_property -dict { PACKAGE_PIN V9 IOSTANDARD LVCMOS15 } [get_ports led[0]]
set_property -dict { PACKAGE_PIN Y8 IOSTANDARD LVCMOS15 } [get_ports led[1]]