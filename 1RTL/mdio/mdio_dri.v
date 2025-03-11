
module mdio_dri #(parameter PHY_ADDR = 5'b00100,
                  parameter CLK_DIV = 6'd10)
                 (input clk,
                  input rst_n,
                  input op_exec,
                  input op_rh_wl,
                  input [4:0] op_addr,
                  input [15:0] op_wr_data,
                  output reg op_done,
                  output reg [15:0] op_rd_data,
                  output reg op_rd_ack,
                  output reg dri_clk,
                  output reg eth_mdc,
                  inout eth_mdio);

localparam st_idle    = 6'b00_0001;
localparam st_pre     = 6'b00_0010;
localparam st_start   = 6'b00_0100;
localparam st_addr    = 6'b00_1000;
localparam st_wr_data = 6'b01_0000;
localparam st_rd_data = 6'b10_0000;

reg [5:0] cur_state, next_state;

reg [5:0] clk_cnt;
reg [15:0] wr_data_t;
reg [4:0] addr_t;
reg [6:0] cnt;
reg st_done;
reg [1:0] op_code;
reg mdio_dir;
reg mdio_out;
reg [15:0] rd_data_t;

wire mdio_in;
wire [5:0] clk_divide;

assign eth_mdio = mdio_dir ? mdio_out : 1'bz;
assign mdio_in  = eth_mdio;

assign clk_divide = CLK_DIV >> 1;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)begin
        dri_clk <= 1'b0;
        clk_cnt <= 6'b0;
    end
    else if (clk_cnt == clk_divide[5:1]-1'd1)begin
        dri_clk <= ~dri_clk;
        clk_cnt <= 6'b0;
    end
    else begin
        clk_cnt <= clk_cnt + 1'b1;
    end
    
end

always @(posedge dri_clk or negedge rst_n) begin
    if (!rst_n) begin
        eth_mdc <= 1'b0;
    end
    else if (cnt[0] == 1'b0) begin
        eth_mdc <= 1'b1;
    end
    else begin
        eth_mdc <= 1'b0;
    end
end

always @(posedge dri_clk or negedge rst_n) begin
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
        st_idle:begin
            if (op_exec)begin
                next_state = st_pre;
            end
            else begin
                next_state = st_idle;
            end
        end
        st_pre:begin
            if (st_done)begin
                next_state = st_start;
            end
            else begin
                next_state = st_pre;
            end
        end
        st_start:begin
            if (st_done)begin
                next_state = st_addr;
            end
            else begin
                next_state = st_start;
            end
        end
        st_addr:begin
            if (st_done)begin
                if (op_code == 2'b01)begin
                    next_state = st_wr_data;
                end
                else begin
                    next_state = st_rd_data;
                end
            end
            else begin
                next_state = st_addr;
            end
        end
        st_wr_data:begin
            if (st_done)begin
                next_state = st_idle;
            end
            else begin
                next_state = st_wr_data;
            end
        end
        st_rd_data:begin
            if (st_done)begin
                next_state = st_idle;
            end
            else begin
                next_state = st_rd_data;
            end
        end
        default:begin
            next_state = st_idle;
        end
    endcase
    
end

always @(posedge dri_clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt        <= 7'b0;
        op_code    <= 2'b00;
        addr_t     <= 5'b0;
        wr_data_t  <= 16'b0;
        rd_data_t  <= 16'b0;
        op_done    <= 1'b0;
        st_done    <= 1'b0;
        op_rd_data <= 16'b0;
        op_rd_ack  <= 1'b0;
        mdio_dir   <= 1'b0;
        mdio_out   <= 1'b1;
    end
    else begin
        st_done <= 1'b0;
        cnt     <= cnt + 1'b1;
        case(cur_state)
            st_idle:begin
                op_done  <= 1'b0;
                cnt      <= 7'b0;
                mdio_dir <= 1'b0;
                mdio_out <= 1'b1;
                if (op_exec)begin
                    op_code   <= {op_rh_wl,~op_rh_wl};
                    addr_t    <= op_addr;
                    wr_data_t <= op_wr_data;
                    op_rd_ack <= 1'b1;
                end
            end
            st_pre:begin
                mdio_dir <= 1'b1;
                mdio_out <= 1'b1;
                if (cnt == 7'd62)begin
                    st_done <= 1'b1;
                end
                else if (cnt == 7'd63)begin
                    cnt <= 7'b0;
                end
            end
            st_start:begin
                case(cnt)
                    7'd1:mdio_out <= 1'b0;
                    7'd3:mdio_out <= 1'b1;
                    7'd5:mdio_out <= op_code[1];
                    7'd6:st_done  <= 1'b1;
                    7'd7:begin
                        mdio_out <= op_code[0];
                        cnt      <= 7'b0;
                    end
                    default:begin
                        
                    end
                endcase
            end
            st_addr:begin
                case (cnt)
                    7'd1:mdio_out  <= PHY_ADDR[4];
                    7'd3:mdio_out  <= PHY_ADDR[3];
                    7'd5:mdio_out  <= PHY_ADDR[2];
                    7'd7:mdio_out  <= PHY_ADDR[1];
                    7'd9:mdio_out  <= PHY_ADDR[0];
                    7'd11:mdio_out <= addr_t[4];
                    7'd13:mdio_out <= addr_t[3];
                    7'd15:mdio_out <= addr_t[2];
                    7'd17:mdio_out <= addr_t[1];
                    7'd18:st_done  <= 1'b1;
                    7'd19:begin
                        mdio_out <= addr_t[0];
                        cnt      <= 7'b0;
                    end
                    default:begin
                        
                    end
                endcase
            end
            st_wr_data:begin
                case(cnt)
                    7'd1:mdio_out  <= 1'b1;
                    7'd3:mdio_out  <= 1'b0;
                    7'd5:mdio_out  <= wr_data_t[15];
                    7'd7:mdio_out  <= wr_data_t[14];
                    7'd9:mdio_out  <= wr_data_t[13];
                    7'd11:mdio_out <= wr_data_t[12];
                    7'd13:mdio_out <= wr_data_t[11];
                    7'd15:mdio_out <= wr_data_t[10];
                    7'd17:mdio_out <= wr_data_t[9];
                    7'd19:mdio_out <= wr_data_t[8];
                    7'd21:mdio_out <= wr_data_t[7];
                    7'd23:mdio_out <= wr_data_t[6];
                    7'd25:mdio_out <= wr_data_t[5];
                    7'd27:mdio_out <= wr_data_t[4];
                    7'd29:mdio_out <= wr_data_t[3];
                    7'd31:mdio_out <= wr_data_t[2];
                    7'd33:mdio_out <= wr_data_t[1];
                    7'd35:mdio_out <= wr_data_t[0];
                    7'd37:begin
                        mdio_out <= 1'b1;
                        mdio_dir <= 1'b0;
                    end
                    7'd39:st_done <= 1'b1;
                    7'd40:begin
                        cnt     <= 7'b0;
                        op_done <= 1'b1;
                    end
                    default:begin
                        
                    end
                endcase
            end
            st_rd_data:begin
                case(cnt)
                    7'd1:begin
                        mdio_out <= 1'b1;
                        mdio_dir <= 1'b0;
                    end
                    7'd2:begin
                        
                    end
                    7'd4:op_rd_ack      <= mdio_in;
                    7'd6:rd_data_t[15]  <= mdio_in;
                    7'd8:rd_data_t[14]  <= mdio_in;
                    7'd10:rd_data_t[13] <= mdio_in;
                    7'd12:rd_data_t[12] <= mdio_in;
                    7'd14:rd_data_t[11] <= mdio_in;
                    7'd16:rd_data_t[10] <= mdio_in;
                    7'd18:rd_data_t[9]  <= mdio_in;
                    7'd20:rd_data_t[8]  <= mdio_in;
                    7'd22:rd_data_t[7]  <= mdio_in;
                    7'd24:rd_data_t[6]  <= mdio_in;
                    7'd26:rd_data_t[5]  <= mdio_in;
                    7'd28:rd_data_t[4]  <= mdio_in;
                    7'd30:rd_data_t[3]  <= mdio_in;
                    7'd32:rd_data_t[2]  <= mdio_in;
                    7'd34:rd_data_t[1]  <= mdio_in;
                    7'd36:rd_data_t[0]  <= mdio_in;
                    7'd39:st_done       <= 1'b1;
                    7'd40:begin
                        cnt        <= 7'b0;
                        op_done    <= 1'b1;
                        op_rd_data <= rd_data_t;
                        rd_data_t  <= 16'b0;
                    end
                    default:begin
                        
                    end
                endcase
            end
            default:begin
            end
        endcase
    end
end


endmodule
