
module mdio_ctrl(input clk,
                 input rst_n,
                 input soft_rst_trig,
                 input op_done,
                 input [15:0] op_rd_data,
                 input op_rd_ack,
                 output reg op_exec,
                 output reg op_rh_wl,
                 output reg [4:0] op_addr,
                 output reg [15:0] op_wr_data,
                 output [1:0] led);
    
    parameter TIME_CNT = 24'd1_000_000;
    
    reg rst_trig_d0;
    reg rst_trig_d1;
    reg rst_trig_d2;
    reg rst_trig_flag;
    reg [23:0] timer_cnt;
    reg timer_done;
    reg start_next;
    reg read_next;
    reg link_error;
    reg [2:0] flow_cnt;
    reg [1:0] speed_status;
    
    wire pos_rst_trig;
    
    assign pos_rst_trig = ~rst_trig_d2 & rst_trig_d1;
    
    assign led = link_error ?2'b00: speed_status;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rst_trig_d0 <= 1'b0;
            rst_trig_d1 <= 1'b0;
            rst_trig_d2 <= 1'b0;
        end
        else begin
            rst_trig_d0 <= soft_rst_trig;
            rst_trig_d1 <= rst_trig_d0;
            rst_trig_d2 <= rst_trig_d1;
        end
    end
    
    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timer_cnt  <= 24'd0;
            timer_done <= 1'b0;
        end
        else if (timer_cnt == TIME_CNT - 1) begin
            timer_done <= 1'b1;
            timer_cnt  <= 24'd0;
        end
        else begin
            timer_cnt  <= timer_cnt + 1'b1;
            timer_done <= 1'b0;
        end
    end
    
    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            flow_cnt      <= 3'b0;
            rst_trig_flag <= 1'b0;
            speed_status  <= 2'b00;
            op_exec       <= 1'b0;
            op_rh_wl      <= 1'b0;
            op_addr       <= 5'b0;
            op_wr_data    <= 16'b0;
            start_next    <= 1'b0;
            read_next     <= 1'b0;
        end
        else begin
            op_exec <= 1'b0;
            if (pos_rst_trig) begin
                rst_trig_flag <= 1'b1;
            end
            else begin
            end
            case(flow_cnt)
                3'b000:begin
                    if (rst_trig_flag) begin
                        op_exec    <= 1'b1;
                        op_rh_wl   <= 1'b0;
                        op_addr    <= 5'b00000;
                        op_wr_data <= 16'h9140;
                        flow_cnt   <= 3'd1;
                    end
                    else if (timer_done) begin
                        op_exec  <= 1'b1;
                        op_rh_wl <= 1'b1;
                        op_addr  <= 5'b00001;
                        flow_cnt <= 3'd2;
                    end
                    else if (start_next)begin
                        op_exec    <= 1'b1;
                        op_rh_wl   <= 1'b1;
                        op_addr    <= 5'h11;
                        flow_cnt   <= 3'd2;
                        start_next <= 1'b0;
                        read_next  <= 1'b1;
                    end
                end
                3'b001:begin
                    if (op_done) begin
                        flow_cnt      <= 3'b0;
                        rst_trig_flag <= 1'b0;
                    end
                end
                3'b010:begin
                    if (op_done) begin
                        if (op_rd_ack == 1'b0 && read_next == 1'b0)begin
                            flow_cnt <= 3'd3;
                        end
                        else if (op_rd_ack == 1'b0 && read_next == 1'b1)begin
                            read_next <= 3'b0;
                            flow_cnt  <= 3'd4;
                        end
                        else begin
                            flow_cnt <= 3'd0;
                        end
                    end
                end
                3'b011:begin
                    flow_cnt <= 3'd0;
                    if (op_rd_data[5] == 1'b1&&op_rd_data[2] == 1'b1)begin
                        start_next <= 1'b1;
                        link_error <= 1'b0;
                    end
                    else begin
                        link_error <= 1'b1;
                    end
                end
                3'b100:begin
                    flow_cnt <= 3'd0;
                    if(op_rd_data[15:4] == 2'b10)
                        speed_status <= 2'b11;
                    else if(op_rd_data[15:4] == 2'b01)
                        speed_status <= 2'b10;
                    else if(op_rd_data[15:4] == 2'b00)
                        speed_status <= 2'b01;
                    else
                        speed_status <= 2'b00;
                end
            endcase
        end
    end  
endmodule
