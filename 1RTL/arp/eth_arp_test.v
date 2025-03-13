

module eth_arp_test(input sys_clk,
                    input sys_rst_n,
                    input touch_key,
                    input eth_rxc,
                    input eth_rx_ctl,
                    input [3:0] eth_rxd,
                    output eth_txc,
                    output eth_tx_ctl,
                    output [3:0] eth_txd,
                    output eth_rst_n);
    
    parameter BOARD_MAC    = 48'h00_11_22_33_44_55;
    parameter BOARD_IP     = {8'd192, 8'd168, 8'd1, 8'd10};
    parameter DES_MAC      = 48'hff_ff_ff_ff_ff_ff;
    parameter DES_IP       = {8'd192, 8'd168, 8'd1, 8'd102};
    parameter IDELAY_VALUE = 0;
    
    wire clk_200m;
    wire gmii_rx_clk;
    wire gmii_rx_dv;
    wire [7:0] gmii_rxd;
    wire gmii_tx_clk;
    wire gmii_tx_en;
    wire [7:0] gmii_txd;
    wire arp_rx_done;
    wire arp_rx_type;
    wire [47:0] src_mac;
    wire [31:0] src_ip;
    wire arp_tx_en;
    wire arp_tx_type;
    wire tx_done;
    wire [47:0] des_mac;
    wire [31:0] des_ip;
    
    
    assign des_mac   = src_mac;
    assign des_ip    = src_ip;
    assign eth_rst_n = sys_rst_n;
    
    //PLL
    clk_wiz_0 clk_wiz_0_inst
    (
    // Clock out ports
    .clk_out1(clk_200m),     // output clk_out1
    // Status and control signals
    .reset(~sys_rst_n), // input reset
    .locked(locked),       // output locked
    // Clock in ports
    .clk_in1(sys_clk));      // input clk_in1
    
    gmii_to_rgmii #(
    .IDELAY_VALUE(IDELAY_VALUE)
    )u_gmii_to_rgmii(
    .idelay_clk   (clk_200m),
    .gmii_rx_clk  (gmii_rx_clk),
    .gmii_rx_dv   (gmii_rx_dv),
    .gmii_rxd     (gmii_rxd),
    .gmii_tx_clk  (gmii_tx_clk),
    .gmii_tx_en   (gmii_tx_en),
    .gmii_txd     (gmii_txd),
    .rgmii_rxc    (eth_rxc),
    .rgmii_rx_ctl (eth_rx_ctl),
    .rgmii_rxd    (eth_rxd),
    .rgmii_txc    (eth_txc),
    .rgmii_tx_ctl (eth_tx_ctl),
    .rgmii_txd    (eth_txd)
    );
    
    arp #(
    .BOARD_MAC(BOARD_MAC),
    .BOARD_IP(BOARD_IP),
    .DES_MAC(DES_MAC),
    .DES_IP(DES_IP)
    )u_arp(
    .rst_n       (sys_rst_n),
    .gmii_rx_clk (gmii_rx_clk),
    .gmii_rx_dv  (gmii_rx_dv),
    .gmii_rxd    (gmii_rxd),
    .gmii_tx_clk (gmii_tx_clk),
    .gmii_tx_en  (gmii_tx_en),
    .gmii_txd    (gmii_txd),
    .arp_rx_done (arp_rx_done),
    .arp_rx_type (arp_rx_type),
    .src_mac     (src_mac),
    .src_ip      (src_ip),
    .arp_tx_en   (arp_tx_en),
    .arp_tx_type (arp_tx_type),
    .des_mac     (des_mac),
    .des_ip      (des_ip),
    .tx_done     (tx_done)
    );
    
    arp_ctrl u_arp_ctrl(
    .clk         (gmii_rx_clk),
    .rst_n       (sys_rst_n),
    .touch_key   (touch_key),
    .arp_rx_done (arp_rx_done),
    .arp_rx_type (arp_rx_type),
    .arp_tx_en   (arp_tx_en),
    .arp_tx_type (arp_tx_type)
    );
    
    
endmodule
