
module eth_udp_loop(input sys_clk,
                    input sys_rst_n,
                    input eth_rxc,
                    input eth_rx_ctl,
                    input [3:0] eth_rxd,
                    output eth_txc,
                    output eth_tx_ctl,
                    output [3:0] eth_txd,
                    output eth_rst_n);
    
    
    parameter  BOARD_MAC   = 48'h00_11_22_33_44_55;
    parameter  BOARD_IP    = {8'd192,8'd168,8'd1,8'd10};
    parameter  DES_MAC     = 48'hff_ff_ff_ff_ff_ff;
    parameter  DES_IP      = {8'd192,8'd168,8'd1,8'd102};
    parameter IDELAY_VALUE = 0;
    
    wire          clk_200m   		  ;
    
    wire          gmii_rx_clk		  ;
    wire          gmii_rx_dv 		  ;
    wire  [7:0]   gmii_rxd   		  ;
    wire          gmii_tx_clk		  ;
    wire          gmii_tx_en 		  ;
    wire  [7:0]   gmii_txd   		  ;
    
    wire          arp_gmii_tx_en	  ;
    wire  [7:0]   arp_gmii_txd  	  ;
    wire          arp_rx_done   	  ;
    wire          arp_rx_type   	  ;
    wire  [47:0]  src_mac       	  ;
    wire  [31:0]  src_ip        	  ;
    wire          arp_tx_en     	  ;
    wire          arp_tx_type   	  ;
    wire  [47:0]  des_mac       	  ;
    wire  [31:0]  des_ip        	  ;
    wire          arp_tx_done   	  ;
    
    wire          icmp_gmii_tx_en	  ;
    wire  [7:0]   icmp_gmii_txd  	  ;
    wire          icmp_rec_pkt_done   ;
    wire          icmp_rec_en         ;
    wire  [7:0]  icmp_rec_data       ;
    wire  [15:0]  icmp_rec_byte_num   ;
    wire  [15:0]  icmp_tx_byte_num    ;
    wire          icmp_tx_done   	  ;
    wire          icmp_tx_req         ;
    wire  [7:0]  icmp_tx_data        ;
    wire          icmp_tx_start_en    ;
    
    wire          udp_gmii_tx_en	  ;
    wire  [7:0]   udp_gmii_txd  	  ;
    wire          rec_pkt_done  	  ;
    wire          udp_rec_en    	  ;
    wire  [7:0]  udp_rec_data  	  ;
    wire  [15:0]  rec_byte_num  	  ;
    wire  [15:0]  tx_byte_num   	  ;
    wire          udp_tx_done   	  ;
    wire          udp_tx_req    	  ;
    wire  [7:0]  udp_tx_data   	  ;
    wire          tx_start_en   	  ;
    
    wire  [7:0]	  rec_data			  ;
    wire		  rec_en			  ;
    wire		  tx_req			  ;
    wire  [7:0]	  tx_data	    	  ;
    
    
    assign icmp_tx_start_en = icmp_rec_pkt_done;
    assign icmp_tx_byte_num = icmp_rec_byte_num;
    
    assign tx_start_en = rec_pkt_done;
    assign tx_byte_num = rec_byte_num;
    assign des_mac     = src_mac;
    assign des_ip      = src_ip;
    assign eth_rst_n   = sys_rst_n;
    
    clk_wiz_0 u_clk_wiz_0
    (
    .clk_out1(clk_200m),
    .reset(~sys_rst_n),
    .locked(locked),
    .clk_in1(sys_clk)
    );
    
    
    gmii_to_rgmii
    #(
    .IDELAY_VALUE (IDELAY_VALUE)
    )
    u_gmii_to_rgmii(
    .idelay_clk    (clk_200m),
    
    .gmii_rx_clk   (gmii_rx_clk),
    .gmii_rx_dv    (gmii_rx_dv),
    .gmii_rxd      (gmii_rxd),
    .gmii_tx_clk   (gmii_tx_clk),
    .gmii_tx_en    (gmii_tx_en),
    .gmii_txd      (gmii_txd),
    
    .rgmii_rxc     (eth_rxc),
    .rgmii_rx_ctl  (eth_rx_ctl),
    .rgmii_rxd     (eth_rxd),
    .rgmii_txc     (eth_txc),
    .rgmii_tx_ctl  (eth_tx_ctl),
    .rgmii_txd     (eth_txd)
    );
    
    
    arp
    #(
    .BOARD_MAC     (BOARD_MAC),
    .BOARD_IP      (BOARD_IP),
    .DES_MAC       (DES_MAC),
    .DES_IP        (DES_IP)
    )
    u_arp(
    .rst_n         (sys_rst_n  	),
    
    .gmii_rx_clk   (gmii_rx_clk	),
    .gmii_rx_dv    (gmii_rx_dv 	),
    .gmii_rxd      (gmii_rxd   	),
    .gmii_tx_clk   (gmii_tx_clk	),
    .gmii_tx_en    (arp_gmii_tx_en),
    .gmii_txd      (arp_gmii_txd),
    
    .arp_rx_done   (arp_rx_done	),
    .arp_rx_type   (arp_rx_type	),
    .src_mac       (src_mac    	),
    .src_ip        (src_ip     	),
    .arp_tx_en     (arp_tx_en  	),
    .arp_tx_type   (arp_tx_type	),
    .des_mac       (des_mac    	),
    .des_ip        (des_ip     	),
    .tx_done       (arp_tx_done	)
    );
    
    icmp
    #(
    .BOARD_MAC     (BOARD_MAC),
    .BOARD_IP      (BOARD_IP),
    .DES_MAC       (DES_MAC),
    .DES_IP        (DES_IP)
    )
    u_icmp(
    .rst_n         (sys_rst_n   	),
    
    .gmii_rx_clk   (gmii_rx_clk 	),
    .gmii_rx_dv    (gmii_rx_dv  	),
    .gmii_rxd      (gmii_rxd    	),
    .gmii_tx_clk   (gmii_tx_clk 	),
    .gmii_tx_en    (icmp_gmii_tx_en	),
    .gmii_txd      (icmp_gmii_txd	),
    
    .rec_pkt_done  (icmp_rec_pkt_done),
    .rec_en        (icmp_rec_en),
    .rec_data      (icmp_rec_data),
    .rec_byte_num  (icmp_rec_byte_num),
    .tx_start_en   (icmp_tx_start_en),
    .tx_data       (icmp_tx_data),
    .tx_byte_num   (icmp_tx_byte_num),
    .des_mac       (des_mac     	),
    .des_ip        (des_ip      	),
    .tx_done       (icmp_tx_done	),
    .tx_req        (icmp_tx_req)
    );
    
    udp
    #(
    .BOARD_MAC     (BOARD_MAC),
    .BOARD_IP      (BOARD_IP),
    .DES_MAC       (DES_MAC),
    .DES_IP        (DES_IP)
    )
    u_udp(
    .rst_n         (sys_rst_n),
    
    .gmii_rx_clk   (gmii_rx_clk),
    .gmii_rx_dv    (gmii_rx_dv),
    .gmii_rxd      (gmii_rxd),
    .gmii_tx_clk   (gmii_tx_clk),
    .gmii_tx_en    (udp_gmii_tx_en),
    .gmii_txd      (udp_gmii_txd),
    
    .rec_pkt_done  (rec_pkt_done),
    .rec_en        (udp_rec_en),
    .rec_data      (udp_rec_data),
    .rec_byte_num  (rec_byte_num),
    .tx_start_en   (tx_start_en),
    .tx_data       (udp_tx_data),
    .tx_byte_num   (tx_byte_num),
    .des_mac       (des_mac),
    .des_ip        (des_ip),
    .tx_done       (udp_tx_done),
    .tx_req        (udp_tx_req)
    );
    
    
    async_fifo_2048x8b u_async_fifo_2048x8b (
    .rst		(~sys_rst_n	)	,
    .wr_clk	(gmii_rx_clk)	,
    .rd_clk	(gmii_rx_clk)	,
    .din		(rec_data	)	,
    .wr_en	(rec_en		)	,
    .rd_en	(tx_req		)	,
    .dout		(tx_data	)	,
    .full		()				,
    .empty	()
    );
    
    
    eth_ctrl u_eth_ctrl(
    .clk            	(gmii_rx_clk	),
    .rst_n          	(sys_rst_n		),
    
    .arp_rx_done    	(arp_rx_done   	),
    .arp_rx_type    	(arp_rx_type   	),
    .arp_tx_en      	(arp_tx_en     	),
    .arp_tx_type    	(arp_tx_type   	),
    .arp_tx_done    	(arp_tx_done   	),
    .arp_gmii_tx_en 	(arp_gmii_tx_en	),
    .arp_gmii_txd   	(arp_gmii_txd  	),
    
    .icmp_tx_start_en	(icmp_tx_start_en),
    .icmp_tx_done		(icmp_tx_done	),
    .icmp_gmii_tx_en	(icmp_gmii_tx_en),
    .icmp_gmii_txd		(icmp_gmii_txd	),
    
    .icmp_rec_en       	(icmp_rec_en),
    .icmp_rec_data     	(icmp_rec_data),
    .icmp_tx_req       	(icmp_tx_req),
    .icmp_tx_data      	(icmp_tx_data),
    
    .udp_tx_start_en	(tx_start_en   	),
    .udp_tx_done    	(udp_tx_done   	),
    .udp_gmii_tx_en 	(udp_gmii_tx_en	),
    .udp_gmii_txd   	(udp_gmii_txd  	),
    
    .udp_rec_data		(udp_rec_data	),
    .udp_rec_en			(udp_rec_en		),
    .udp_tx_req			(udp_tx_req		),
    .udp_tx_data		(udp_tx_data	),
    
    .rec_data			(rec_data	),
    .rec_en	        	(rec_en	),
    .tx_req	        	(tx_req	),
    .tx_data	    	(tx_data	),
    
    .gmii_tx_en     	(gmii_tx_en    	),
    .gmii_txd       	(gmii_txd      	)
    );
    
endmodule
