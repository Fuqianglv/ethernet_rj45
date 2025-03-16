

module udp_rx(input clk,
              input rst_n,
              input gmii_rx_dv,
              input [7:0] gmii_rxd,
              output reg rec_pkt_done,
              output reg rec_en,
              output reg [7 :0] rec_data,
              output reg [15:0] rec_byte_num);
    
    parameter BOARD_MAC = 48'h00_11_22_33_44_55;
    parameter BOARD_IP  = {8'd192,8'd168,8'd1,8'd10};
    
    localparam  st_idle     = 7'b000_0001;
    localparam  st_preamble = 7'b000_0010;
    localparam  st_eth_head = 7'b000_0100;
    localparam  st_ip_head  = 7'b000_1000;
    localparam  st_udp_head = 7'b001_0000;
    localparam  st_rx_data  = 7'b010_0000;
    localparam  st_rx_end   = 7'b100_0000;
    
    localparam  ETH_TYPE = 16'h0800   ;
    localparam  UDP_TYPE = 8'd17      ;
    
    reg  [6:0]   cur_state       ;
    reg  [6:0]   next_state      ;
    
    reg          skip_en         ;
    reg          error_en        ;
    reg  [4:0]   cnt             ;
    reg  [47:0]  des_mac         ;
    reg  [15:0]  eth_type        ;
    reg  [31:0]  des_ip          ;
    reg  [5:0]   ip_head_byte_num;
    reg  [15:0]  udp_byte_num    ;
    reg  [15:0]  data_byte_num   ;
    reg  [15:0]  data_cnt        ;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)begin
            cur_state <= st_idle;
        end
        else begin
            cur_state <= next_state;
        end
    end
    
    always @(*) begin
        next_state = st_idle;
        case(cur_state)
            st_idle : begin
                if (skip_en) begin
                    next_state = st_preamble;
                end
                else begin
                    next_state = st_idle;
                end
            end
            st_preamble : begin
                if (skip_en)  begin
                    next_state = st_eth_head;
                end
                else if (error_en) begin
                    next_state = st_rx_end;
                end
                else begin
                    next_state = st_preamble;
                end
            end
            st_eth_head : begin
                if (skip_en) begin
                    next_state = st_ip_head;
                end
                else if (error_en) begin
                    next_state = st_rx_end;
                end
                else begin
                    next_state = st_eth_head;
                end
            end
            st_ip_head : begin
                if (skip_en) begin
                    next_state = st_udp_head;
                end
                else if (error_en)begin
                    next_state = st_rx_end;
                end
                else begin
                    next_state = st_ip_head;
                end
            end
            st_udp_head : begin
                if (skip_en) begin
                    next_state = st_rx_data;
                end
                else begin
                    next_state = st_udp_head;
                end
            end
            st_rx_data : begin
                if (skip_en) begin
                    next_state = st_rx_end;
                end
                else begin
                    next_state = st_rx_data;
                end
            end
            st_rx_end : begin
                if (skip_en) begin
                    next_state = st_idle;
                end
                else begin
                    next_state = st_rx_end;
                end
            end
            default : begin
                next_state = st_idle;
            end
        endcase
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            skip_en          <= 1'b0;
            error_en         <= 1'b0;
            cnt              <= 5'd0;
            des_mac          <= 48'd0;
            eth_type         <= 16'd0;
            des_ip           <= 32'd0;
            ip_head_byte_num <= 6'd0;
            udp_byte_num     <= 16'd0;
            data_byte_num    <= 16'd0;
            data_cnt         <= 16'd0;
            rec_en           <= 1'b0;
            rec_data         <= 32'd0;
            rec_pkt_done     <= 1'b0;
            rec_byte_num     <= 16'd0;
        end
        else begin
            skip_en      <= 1'b0;
            error_en     <= 1'b0;
            rec_pkt_done <= 1'b0;
            case(next_state)
                st_idle : begin
                    if ((gmii_rx_dv == 1'b1) && (gmii_rxd == 8'h55)) begin
                        skip_en <= 1'b1;
                    end
                end
                st_preamble : begin
                    if (gmii_rx_dv) begin
                        cnt <= cnt + 5'd1;
                        if ((cnt < 5'd6) && (gmii_rxd != 8'h55))  begin
                            error_en <= 1'b1;
                        end
                        else if (cnt == 5'd6) begin
                            cnt <= 5'd0;
                            if (gmii_rxd == 8'hd5)    begin
                                skip_en <= 1'b1;
                            end
                            else begin
                                error_en <= 1'b1;
                            end
                        end
                    end
                end
                st_eth_head : begin
                    if (gmii_rx_dv) begin
                        cnt <= cnt + 5'b1;
                        if (cnt < 5'd6) begin
                            des_mac <= {des_mac[39:0],gmii_rxd};
                        end
                        else if (cnt == 5'd12) begin
                            eth_type[15:8] <= gmii_rxd;
                        end
                        else if (cnt == 5'd13) begin
                            eth_type[7:0] <= gmii_rxd;
                            cnt           <= 5'd0;
                            
                            if (((des_mac == BOARD_MAC) ||(des_mac == 48'hff_ff_ff_ff_ff_ff))
                                && eth_type[15:8] == ETH_TYPE[15:8] && gmii_rxd == ETH_TYPE[7:0])
                                begin
                                skip_en <= 1'b1;
                                end
                            else begin
                                error_en <= 1'b1;
                            end
                        end
                    end
                end
                st_ip_head : begin
                    if (gmii_rx_dv) begin
                        cnt <= cnt + 5'd1;
                        if (cnt == 5'd0)begin
                            ip_head_byte_num <= {gmii_rxd[3:0],2'd0};
                        end
                        else if (cnt == 5'd9) begin
                            if (gmii_rxd != UDP_TYPE) begin
                                error_en <= 1'b1;
                                cnt      <= 5'd0;
                            end
                        end
                        else if ((cnt >= 5'd16) && (cnt <= 5'd18))begin
                            des_ip <= {des_ip[23:0],gmii_rxd};
                        end
                        else if (cnt == 5'd19) begin
                            des_ip <= {des_ip[23:0],gmii_rxd};
                            if ((des_ip[23:0] == BOARD_IP[31:8])
                                && (gmii_rxd == BOARD_IP[7:0])) begin
                                skip_en <= 1'b1;
                                cnt     <= 5'd0;
                                end
                            else begin
                                error_en <= 1'b1;
                                cnt      <= 5'd0;
                            end
                        end
                    end
                end
                st_udp_head : begin
                    if (gmii_rx_dv) begin
                        cnt <= cnt + 5'd1;
                        if (cnt == 5'd4) begin
                            udp_byte_num[15:8] <= gmii_rxd;
                        end
                        else if (cnt == 5'd5) begin
                            udp_byte_num[7:0] <= gmii_rxd;
                        end
                        else if (cnt == 5'd7) begin
                            
                            data_byte_num <= udp_byte_num - 16'd8;
                            skip_en       <= 1'b1;
                            cnt           <= 5'd0;
                        end
                        else begin
                            
                        end
                    end
                end
                st_rx_data : begin
                    if (gmii_rx_dv) begin
                        data_cnt <= data_cnt + 16'd1;
                        rec_data <= gmii_rxd;
                        rec_en   <= 1'b1;
                        if (data_cnt == data_byte_num - 16'd1) begin
                            skip_en      <= 1'b1;
                            data_cnt     <= 16'd0;
                            rec_pkt_done <= 1'b1;
                            rec_byte_num <= data_byte_num;
                        end
                    end
                end
                st_rx_end : begin
                    rec_en <= 1'b0;
                    if (gmii_rx_dv == 1'b0 && skip_en == 1'b0) begin
                        skip_en <= 1'b1;
                    end
                    else begin
                    end
                end
                default : ;
            endcase
        end
    end
    
endmodule
