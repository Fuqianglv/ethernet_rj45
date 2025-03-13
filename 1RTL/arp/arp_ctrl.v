

module arp_ctrl(
    input clk,
    input rst_n,

    input touch_key,
    input arp_rx_done,
    input arp_rx_type,
    output reg arp_tx_en,
    output reg arp_tx_type
);

reg touch_key_d0;
reg touch_key_d1;
reg touch_key_d2;

wire pos_touch_key;

assign pos_touch_key = touch_key_d1 & (~touch_key_d2);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        touch_key_d0 <= 1'b0;
        touch_key_d1 <= 1'b0;
        touch_key_d2 <= 1'b0;
    end
    else begin
        touch_key_d0 <= touch_key;
        touch_key_d1 <= touch_key_d0;
        touch_key_d2 <= touch_key_d1;
    end
end

always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        arp_tx_en <= 1'b0;
        arp_tx_type <= 1'b0;
    end
    else begin
        if (pos_touch_key) begin
            arp_tx_en <= 1'b1;
            arp_tx_type <= 1'b0;
        end
        else if (arp_rx_done&&(~arp_rx_type)) begin
            arp_tx_en <= 1'b1;
            arp_tx_type <= 1'b1;
        end
        else begin
            arp_tx_en <= 1'b0;
            arp_tx_type <= 1'b0;
        end
    end
end

endmodule