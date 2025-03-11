

module gmii_to_rgmii(input idelay_clk,
                     output gmii_rx_clk,
                     output gmii_rx_dv,
                     output [7:0] gmii_rxd,
                     output gmii_tx_clk,
                     output gmii_tx_en,
                     output [7:0] gmii_txd,
                     input rgmii_rxc,
                     input rgmii_rx_ctl,
                     input [3:0] rgmii_rxd,
                     input rgmii_txc,
                     output rgmii_tx_ctl,
                     output [3:0] rgmii_txd);
    
    parameter IDELAY_VALUE = 0;

    assign gmii_rx_clk = gmii_rx_clk;

    rgmii_rx #(
        .IDELAY_VALUE(IDELAY_VALUE)
    )u_rgmii_rx(
        .idelay_clk   (idelay_clk   ),
        .rgmii_rxc    (rgmii_rxc    ),
        .rgmii_rx_ctl (rgmii_rx_ctl ),
        .rgmii_rxd    (rgmii_rxd    ),
        .gmii_rx_clk  (gmii_rx_clk  ),
        .gmii_rx_dv   (gmii_rx_dv   ),
        .gmii_rxd     (gmii_rxd     )
    );
    
    rgmii_tx u_rgmii_tx(
        .gmii_tx_clk  (gmii_tx_clk  ),
        .gmii_tx_en   (gmii_tx_en   ),
        .gmii_txd     (gmii_txd     ),
        .rgmii_txc    (rgmii_txc    ),
        .rgmii_tx_ctl (rgmii_tx_ctl ),
        .rgmii_txd    (rgmii_txd    )
    );
    
    
endmodule
