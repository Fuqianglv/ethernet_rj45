

module arp(input rst_n,
           input gmii_rx_clk,
           input gmii_rx_dv,
           input [7:0] gmii_rxd,
           input gmii_tx_clk,
           output gmii_tx_en,
           output [7:0] gmii_txd,
           output arp_rx_done,
           output arp_rx_type,
           output [47:0] src_mac,
           output [31:0] src_ip,
           input arp_tx_en,
           input arp_tx_type,
           input [47:0] des_mac,
           input [31:0] des_ip,
           output tx_done);
    
    parameter BOARD_MAC = 48'h00_11_22_33_44_55;
    parameter BOARD_IP  = {8'd192, 8'd168, 8'd1, 8'd10};
    parameter DES_MAC   = 48'hff_ff_ff_ff_ff_ff;
    parameter DES_IP    = {8'd192, 8'd168, 8'd1, 8'd102};
    
    wire crc_en;
    wire crc_clr;
    wire [7:0] crc_d8;
    wire [31:0] crc_next;
    wire [31:0] crc_data;
    
    assign crc_d8 = gmii_rxd;
    
    arp_rx #(
    .BOARD_MAC(BOARD_MAC),
    .BOARD_IP(BOARD_IP)
    )u_arp_rx(
    .clk         (gmii_rx_clk),
    .rst_n       (rst_n),
    .gmii_rx_dv  (gmii_rx_dv),
    .gmii_rxd    (gmii_rxd),
    .arp_rx_done (arp_rx_done),
    .arp_rx_type (arp_rx_type),
    .src_mac     (src_mac),
    .src_ip      (src_ip)
    );
    
    arp_tx #(
    .BOARD_MAC(BOARD_MAC),
    .BOARD_IP(BOARD_IP),
    .DES_MAC(DES_MAC),
    .DES_IP(DES_IP)
    )u_arp_tx(
    .clk         (gmii_tx_clk),
    .rst_n       (rst_n),
    .arp_tx_en   (arp_tx_en),
    .arp_tx_type (arp_tx_type),
    .des_mac     (des_mac),
    .des_ip      (des_ip),
    .crc_data    (crc_data),
    .crc_next    (crc_next[31:24]),
    .tx_done     (tx_done),
    .gmii_tx_en  (gmii_tx_en),
    .gmii_txd    (gmii_txd),
    .crc_en      (crc_en),
    .crc_clr     (crc_clr)
    );
    
    crc32_d8 u_crc32_d8(
    .clk      (gmii_tx_clk),
    .rst_n    (rst_n),
    .data     (crc_d8),
    .crc_en   (crc_en),
    .crc_clr  (crc_clr),
    .crc_data (crc_data),
    .crc_next (crc_next)
    );
    
    
    
endmodule
