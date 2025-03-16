

module udp(input rst_n,
           input gmii_rx_clk,
           input gmii_rx_dv,
           input [7:0] gmii_rxd,
           input gmii_tx_clk,
           output gmii_tx_en,
           output [7:0] gmii_txd,
           output rec_pkt_done,
           output rec_en,
           output [7:0] rec_data,
           output [15:0] rec_byte_num,
           input tx_start_en,
           input [7:0] tx_data,
           input [15:0] tx_byte_num,
           input [47:0] des_mac,
           input [31:0] des_ip,
           output tx_done,
           output tx_req);
    
    
    parameter BOARD_MAC = 48'h00_11_22_33_44_55;
    parameter BOARD_IP  = {8'd192,8'd168,8'd1,8'd10};
    parameter  DES_MAC  = 48'hff_ff_ff_ff_ff_ff;
    parameter  DES_IP   = {8'd192,8'd168,8'd1,8'd102};
    
    wire          crc_en  ;
    wire          crc_clr ;
    wire  [7:0]   crc_d8  ;
    
    wire  [31:0]  crc_data;
    wire  [31:0]  crc_next;
    
    
    assign  crc_d8 = gmii_txd;
    
    
    udp_rx
    #(
    .BOARD_MAC       (BOARD_MAC),
    .BOARD_IP        (BOARD_IP)
    )
    u_udp_rx(
    .clk             (gmii_rx_clk),
    .rst_n           (rst_n),
    .gmii_rx_dv      (gmii_rx_dv),
    .gmii_rxd        (gmii_rxd),
    .rec_pkt_done    (rec_pkt_done),
    .rec_en          (rec_en),
    .rec_data        (rec_data),
    .rec_byte_num    (rec_byte_num)
    );
    
    
    udp_tx
    #(
    .BOARD_MAC       (BOARD_MAC),
    .BOARD_IP        (BOARD_IP),
    .DES_MAC         (DES_MAC),
    .DES_IP          (DES_IP)
    )
    u_udp_tx(
    .clk             (gmii_tx_clk),
    .rst_n           (rst_n),
    .tx_start_en     (tx_start_en),
    .tx_data         (tx_data),
    .tx_byte_num     (tx_byte_num),
    .des_mac         (des_mac),
    .des_ip          (des_ip),
    .crc_data        (crc_data),
    .crc_next        (crc_next[31:24]),
    .tx_done         (tx_done),
    .tx_req          (tx_req),
    .gmii_tx_en      (gmii_tx_en),
    .gmii_txd        (gmii_txd),
    .crc_en          (crc_en),
    .crc_clr         (crc_clr)
    );
    
    crc32_d8   u_crc32_d8(
    .clk             (gmii_tx_clk),
    .rst_n           (rst_n),
    .data            (crc_d8),
    .crc_en          (crc_en),
    .crc_clr         (crc_clr),
    .crc_data        (crc_data),
    .crc_next        (crc_next)
    );
    
endmodule
