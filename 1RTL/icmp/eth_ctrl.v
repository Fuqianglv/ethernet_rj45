
module eth_ctrl(input clk,
                input rst_n,
                input arp_rx_done,
                input arp_rx_type,
                output reg arp_tx_en,
                output arp_tx_type,
                input arp_tx_done,
                input arp_gmii_tx_en,
                input [7:0] arp_gmii_txd,
                input icmp_tx_start_en,
                input icmp_tx_done,
                input icmp_gmii_tx_en,
                input [7:0] icmp_gmii_txd,
                output gmii_tx_en,
                output [7:0] gmii_txd);
    
    
    reg        protocol_sw;
    reg        icmp_tx_busy;
    reg        arp_rx_flag;
    
    
    
    assign arp_tx_type = 1'b1;
    assign gmii_tx_en  = protocol_sw ? icmp_gmii_tx_en : arp_gmii_tx_en;
    assign gmii_txd    = protocol_sw ? icmp_gmii_txd : arp_gmii_txd;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            icmp_tx_busy <= 1'b0;
        end
        else if (icmp_tx_start_en)begin
            icmp_tx_busy <= 1'b1;
        end
            else if (icmp_tx_done)begin
            icmp_tx_busy <= 1'b0;
            end
        else begin
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            arp_rx_flag <= 1'b0;
        else if (arp_rx_done && (arp_rx_type == 1'b0))
            arp_rx_flag <= 1'b1;
        else
            arp_rx_flag <= 1'b0;
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            protocol_sw <= 1'b0;
            arp_tx_en   <= 1'b0;
        end
        else begin
            arp_tx_en <= 1'b0;
            if (icmp_tx_start_en)
                protocol_sw <= 1'b1;
            else if (arp_rx_flag && (icmp_tx_busy == 1'b0)) begin
                protocol_sw <= 1'b0;
                arp_tx_en   <= 1'b1;
            end
            else begin
                
            end
        end
    end
    
endmodule
