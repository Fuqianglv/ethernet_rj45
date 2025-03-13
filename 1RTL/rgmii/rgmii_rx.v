
module rgmii_rx(input idelay_clk,
                input rgmii_rxc,
                input rgmii_rx_ctl,
                input [3:0] rgmii_rxd,
                output gmii_rx_clk,
                output gmii_rx_dv,
                output [7:0] gmii_rxd);
    
    parameter IDELAY_VALUE = 0;
    
    wire rgmii_rxc_bufg;
    wire rgmii_rx_bufio;
    wire [3:0] rgmii_rxd_delay;
    wire rgmii_rx_ctl_delay;
    wire [1:0] gmii_rxdv_t;
    
    assign gmii_rx_clk = rgmii_rxc_bufg;
    assign gmii_rx_dv  = gmii_rxdv_t[0] & gmii_rxdv_t[1];
    
    BUFG BUFG_inst (
    .I(rgmii_rxc),
    .O(rgmii_rxc_bufg)
    );
    
    BUFIO BUFIO_inst (
    .I(rgmii_rxc),
    .O(rgmii_rx_bufio)
    );
    
    (* IODELAY_GROUP = "rgmii_rx_delay" *)
    IDELAYCTRL IDELAYCTRL_inst (
    .RDY(),
    .REFCLK(idelay_clk),
    .RST(1'b0)
    );
    
    (* IDELAY_GROUP = "rgmii_rx_delay" *)
    IDELAYE2 # (
    .IDELAY_TYPE("FIXED"),
    .IDELAY_VALUE(IDELAY_VALUE),
    .REFCLK_FREQUENCY(200.0)
    )
    u_delay_rx_ctrl (
    .CNTVALUEOUT(),
    .DATAOUT(rgmii_rx_ctl_delay),
    .C (1'b0),
    .CE(1'b0),
    .CINVCTRL(1'b0),
    .CNTVALUEIN(5'b0),
    .DATAIN(1'b0),
    .IDATAIN(rgmii_rx_ctl),
    .INC(1'b0),
    .LD(1'b0),
    .LDPIPEEN(1'b0),
    .REGRST(1'b0)
    );
    
    IDDR #(
    .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
    .INIT_Q1(1'b0),
    .INIT_Q2(1'b0),
    .SRTYPE("SYNC")
    )
    u_iddr_rx_ctl(
    .Q1(gmii_rxdv_t[0]),
    .Q2(gmii_rxdv_t[1]),
    .C(rgmii_rxc_bufio),
    .CE(1'b1),
    .D(rgmii_rx_ctl_delay),
    .R(1'b0),
    .S(1'b0)
    );
    
    genvar i;
    generate for (i = 0;i<4;i = i+1)
    (* IODELAY_GROUP = "rgmii_rx_delay" *)
    begin : rxdata_bus
    (* IODELAY_GROUP = "rgmii_rx_delay" *)
    IDELAYE2 # (
    .IDELAY_TYPE("FIXED"),
    .IDELAY_VALUE(IDELAY_VALUE),
    .REFCLK_FREQUENCY(200.0)
    )
    u_delay_rxd(
    .CNTVALUEOUT(),
    .DATAOUT(rgmii_rxd_delay[i]),
    .C (1'b0),
    .CE(1'b0),
    .CINVCTRL(1'b0),
    .CNTVALUEIN(5'b0),
    .DATAIN(1'b0),
    .IDATAIN(rgmii_rxd[i]),
    .INC(1'b0),
    .LD(1'b0),
    .LDPIPEEN(1'b0),
    .REGRST(1'b0)
    );
    
    IDDR #(
    .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
    .INIT_Q1(1'b0),
    .INIT_Q2(1'b0),
    .SRTYPE("SYNC")
    )
    u_iddr_rxd(
    .Q1(gmii_rxd[i]),
    .Q2(gmii_rxd[i+4]),
    .C(rgmii_rxc_bufg),
    .CE(1'b1),
    .D(rgmii_rxd_delay[i]),
    .R(1'b0),
    .S(1'b0)
    );
    end
    endgenerate
    
endmodule
