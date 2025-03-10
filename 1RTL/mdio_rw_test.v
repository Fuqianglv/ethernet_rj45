
module mdio_rw_test(input sys_clk,
                    input sys_rst_n,
                    output eth_mdc,
                    inout eth_mdio,
                    output eth_rst_n,
                    input touch_key,
                    output [1:0] led);
    
    wire op_exec;
    wire op_rh_wl;
    wire [4:0] op_addr;
    wire [15:0] op_wr_data;
    wire op_done;
    wire [15:0] op_rd_data;
    wire op_rd_ack;
    wire dri_clk;
    
    assign eth_rst_n = sys_rst_n;
    
    mdio_dri #(
    .CLK_DIV(6'h10),
    .PHY_ADDR(5'b00100)
    )
    u_mdio_dri(
    .clk        (sys_clk),
    .rst_n      (sys_rst_n),
    .op_exec    (op_exec),
    .op_rh_wl   (op_rh_wl),
    .op_addr    (op_addr),
    .op_wr_data (op_wr_data),
    .op_done    (op_done),
    .op_rd_data (op_rd_data),
    .op_rd_ack  (op_rd_ack),
    .dri_clk    (dri_clk),
    .eth_mdc    (eth_mdc),
    .eth_mdio   (eth_mdio)
    );
    
    mdio_ctrl u_mdio_ctrl(
    .clk           (dri_clk),
    .rst_n         (sys_rst_n),
    .soft_rst_trig (touch_key),
    .op_done       (op_done),
    .op_rd_data    (op_rd_data),
    .op_rd_ack     (op_rd_ack),
    .op_exec       (op_exec),
    .op_rh_wl      (op_rh_wl),
    .op_addr       (op_addr),
    .op_wr_data    (op_wr_data),
    .led           (led)
    );
    
    
    
endmodule
