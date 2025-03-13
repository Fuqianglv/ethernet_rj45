

module arp_tx(input clk,
              input rst_n,
              input arp_tx_en,
              input arp_tx_type,
              input [47:0] des_mac,
              input [31:0] des_ip,
              input [31:0] crc_data,
              input [7:0] crc_next,
              output reg tx_done,
              output reg gmii_tx_en,
              output reg [7:0] gmii_txd,
              output reg crc_en,
              output reg crc_clr);
    
    parameter BOARD_MAC = 48'h00_11_22_33_44_55;
    parameter BOARD_IP  = {8'd192, 8'd168, 8'd1, 8'd10};
    parameter DES_MAC   = 48'hff_ff_ff_ff_ff_ff;
    parameter DES_IP    = {8'd192, 8'd168, 8'd1, 8'd102};
    
    localparam st_idle       = 5'b00001;
    localparam st_preamble   = 5'b00010;
    localparam st_eth_head   = 5'b00100;
    localparam st_arp_data   = 5'b01000;
    localparam st_crc        = 5'b10000;
    localparam ETH_TYPE      = 16'h0806;
    localparam HD_TYPE       = 16'h0001;
    localparam PROTOCOL_TYPE = 16'h0800;
    
    localparam MIN_DATA_NUM = 16'd46;
    
    
    reg [4:0] cur_state;
    reg [4:0] next_state;
    reg [7:0] preamble[7:0];
    reg [7:0] eth_head[13:0];
    reg [7:0] arp_data[27:0];
    reg tx_en_d0, tx_en_d1, tx_en_d2;
    reg skip_en;
    reg [5:0] cnt;
    reg [4:0] data_cnt;
    reg tx_done_t;
    
    wire pos_tx_en;
    
    assign pos_tx_en = tx_en_d1 & (~tx_en_d2);
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_en_d0 <= 1'b0;
            tx_en_d1 <= 1'b0;
            tx_en_d2 <= 1'b0;
        end
        else begin
            tx_en_d0 <= arp_tx_en;
            tx_en_d1 <= tx_en_d0;
            tx_en_d2 <= tx_en_d1;
        end
    end
    
    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cur_state <= st_idle;
        end
        else begin
            cur_state <= next_state;
        end
    end
    
    always @(*) begin
        next_state = st_idle;
        case(cur_state)
            st_idle: begin
                if (skip_en) begin
                    next_state = st_preamble;
                end
                else begin
                    next_state = st_idle;
                end
            end
            st_preamble: begin
                if (skip_en) begin
                    next_state = st_eth_head;
                end
                else begin
                    next_state = st_preamble;
                end
            end
            st_eth_head: begin
                if (skip_en) begin
                    next_state = st_arp_data;
                end
                else begin
                    next_state = st_eth_head;
                end
            end
            st_arp_data: begin
                if (skip_en) begin
                    next_state = st_crc;
                end
                else begin
                    next_state = st_arp_data;
                end
            end
            st_crc: begin
                if (skip_en) begin
                    next_state = st_idle;
                end
                else begin
                    next_state = st_crc;
                end
            end
            default: begin
                next_state = st_idle;
            end
        endcase
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)begin
            skip_en    <= 1'b0;
            cnt        <= 6'd0;
            data_cnt   <= 5'd0;
            crc_en     <= 1'b0;
            gmii_tx_en <= 1'b0;
            gmii_txd   <= 8'h00;
            tx_done_t  <= 1'b0;
            
            preamble[0] = 8'h55;
            preamble[1] = 8'h55;
            preamble[2] = 8'h55;
            preamble[3] = 8'h55;
            preamble[4] = 8'h55;
            preamble[5] = 8'h55;
            preamble[6] = 8'h55;
            preamble[7] = 8'hD5;
            
            eth_head[0]  = DES_MAC[47:40];
            eth_head[1]  = DES_MAC[39:32];
            eth_head[2]  = DES_MAC[31:24];
            eth_head[3]  = DES_MAC[23:16];
            eth_head[4]  = DES_MAC[15:8];
            eth_head[5]  = DES_MAC[7:0];
            eth_head[6]  = BOARD_MAC[47:40];
            eth_head[7]  = BOARD_MAC[39:32];
            eth_head[8]  = BOARD_MAC[31:24];
            eth_head[9]  = BOARD_MAC[23:16];
            eth_head[10] = BOARD_MAC[15:8];
            eth_head[11] = BOARD_MAC[7:0];
            eth_head[12] = ETH_TYPE[15:8];
            eth_head[13] = ETH_TYPE[7:0];
            
            arp_data[0]  = HD_TYPE[15:8];
            arp_data[1]  = HD_TYPE[7:0];
            arp_data[2]  = PROTOCOL_TYPE[15:8];
            arp_data[3]  = PROTOCOL_TYPE[7:0];
            arp_data[4]  = 8'h06;
            arp_data[5]  = 8'h04;
            arp_data[6]  = 8'h00;
            arp_data[7]  = 8'h01;
            arp_data[8]  = BOARD_MAC[47:40];
            arp_data[9]  = BOARD_MAC[39:32];
            arp_data[10] = BOARD_MAC[31:24];
            arp_data[11] = BOARD_MAC[23:16];
            arp_data[12] = BOARD_MAC[15:8];
            arp_data[13] = BOARD_MAC[7:0];
            arp_data[14] = BOARD_IP[31:24];
            arp_data[15] = BOARD_IP[23:16];
            arp_data[16] = BOARD_IP[15:8];
            arp_data[17] = BOARD_IP[7:0];
            arp_data[18] = DES_MAC[47:40];
            arp_data[19] = DES_MAC[39:32];
            arp_data[20] = DES_MAC[31:24];
            arp_data[21] = DES_MAC[23:16];
            arp_data[22] = DES_MAC[15:8];
            arp_data[23] = DES_MAC[7:0];
            arp_data[24] = DES_IP[31:24];
            arp_data[25] = DES_IP[23:16];
            arp_data[26] = DES_IP[15:8];
            arp_data[27] = DES_IP[7:0];
        end
        else begin
            skip_en    <= 1'b0;
            crc_en     <= 1'b0;
            gmii_tx_en <= 1'b0;
            tx_done_t  <= 1'b0;
            case(next_state)
                st_idle: begin
                    if (pos_tx_en) begin
                        skip_en <= 1'b1;
                        if ((des_mac != 48'h00_00_00_00_00_00) || (des_ip != 32'h00_00_00_00)) begin
                            eth_head[0]  <= des_mac[47:40];
                            eth_head[1]  <= des_mac[39:32];
                            eth_head[2]  <= des_mac[31:24];
                            eth_head[3]  <= des_mac[23:16];
                            eth_head[4]  <= des_mac[15:8];
                            eth_head[5]  <= des_mac[7:0];
                            arp_data[18] <= des_mac[47:40];
                            arp_data[19] <= des_mac[39:32];
                            arp_data[20] <= des_mac[31:24];
                            arp_data[21] <= des_mac[23:16];
                            arp_data[22] <= des_mac[15:8];
                            arp_data[23] <= des_mac[7:0];
                            arp_data[24] <= des_ip[31:24];
                            arp_data[25] <= des_ip[23:16];
                            arp_data[26] <= des_ip[15:8];
                            arp_data[27] <= des_ip[7:0];
                        end
                        else begin
                            if (arp_tx_type == 1'b0) begin
                                arp_data[7] <= 8'h01;
                            end
                            else begin
                                arp_data[7] <= 8'h02;
                            end
                        end
                    end
                    else begin
                    end
                end
                st_preamble: begin
                    gmii_tx_en <= 1'b1;
                    gmii_txd   <= preamble[cnt];
                    if (cnt == 6'd7) begin
                        cnt     <= 6'd0;
                        skip_en <= 1'b1;
                    end
                    else begin
                        cnt <= cnt + 1;
                    end
                end
                st_eth_head: begin
                    gmii_tx_en <= 1'b1;
                    crc_en     <= 1'b1;
                    gmii_txd   <= eth_head[cnt];
                    if (cnt == 6'd13) begin
                        cnt     <= 6'd0;
                        skip_en <= 1'b1;
                    end
                    else begin
                        cnt <= cnt + 1;
                    end
                end
                st_arp_data: begin
                    gmii_tx_en <= 1'b1;
                    crc_en     <= 1'b1;
                    if(cnt == MIN_DATA_NUM-1) begin
                        skip_en <= 1'b1;
                        cnt     <= 6'd0;
                        data_cnt <= 5'd0;
                    end
                    else begin
                        cnt <= cnt + 1;
                    end
                    if (data_cnt == 5'd27) begin
                        data_cnt <= data_cnt + 1;
                        gmii_txd <= arp_data[data_cnt];
                    end
                    else begin
                        gmii_txd <= 0;
                    end
                end
                st_crc: begin
                    gmii_tx_en <= 1'b1;
                    cnt <= cnt + 1;
                    if (cnt == 6'd0) begin
                        gmii_txd <= {~crc_next[0],~crc_next[1],~crc_next[2],~crc_next[3],~crc_next[4],~crc_next[5],~crc_next[6],~crc_next[7]};
                    end
                    else if (cnt == 6'd1)begin
                        gmii_txd <= {~crc_next[16],~crc_next[17],~crc_next[18],~crc_next[19],~crc_next[20],~crc_next[21],~crc_next[22],~crc_next[23]};
                    end
                    else if(cnt == 6'd2)begin
                        gmii_txd <= {~crc_next[8],~crc_next[9],~crc_next[10],~crc_next[11],~crc_next[12],~crc_next[13],~crc_next[14],~crc_next[15]};
                    end
                    else if(cnt == 6'd3)begin
                        gmii_txd <= {~crc_data[0],~crc_data[1],~crc_data[2],~crc_data[3],~crc_data[4],~crc_data[5],~crc_data[6],~crc_data[7]};
                        tx_done_t <= 1'b1;
                        skip_en <= 1'b1;
                        cnt <= 6'd0;
                    end
                    else begin
                    end
                end
                default: begin
                end
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            tx_done <= 1'b0;
            crc_clr <= 1'b0;
        end
        else begin
            tx_done <= tx_done_t;
            crc_clr <= tx_done_t;
        end
    end
    
endmodule
