

module eth_ctrl(
    input              clk       		,    
    input              rst_n     		,    
                                  
    input              arp_rx_done   	,    
    input              arp_rx_type   	,    
    output  reg        arp_tx_en	 	,    
    output             arp_tx_type   	,    
    input              arp_tx_done   	,    
    input              arp_gmii_tx_en	,    
    input     [7:0]    arp_gmii_txd  	,    

    input              icmp_tx_start_en , 	 
    input              icmp_tx_done	    , 	 
    input              icmp_gmii_tx_en  , 	 
    input     [7:0]    icmp_gmii_txd    , 	 

	input	           icmp_rec_en      ,	 
	input     [7:0]    icmp_rec_data    ,	 
	input	   		   icmp_tx_req      ,	 
	output    [7:0]    icmp_tx_data     ,	 

    input              udp_tx_start_en  ,	 
    input              udp_tx_done      ,	 
    input              udp_gmii_tx_en   ,	 
    input     [7:0]    udp_gmii_txd     ,	 

	input	  [7:0]    udp_rec_data		,  	 
	input			   udp_rec_en		,  	 
	input			   udp_tx_req		,  	 
	output	   [7:0]   udp_tx_data		,  	 

	input	   [7:0]   tx_data	    	,	 
	output			   tx_req	    	,    
	output reg		   rec_en	    	,    
	output reg [7:0]   rec_data			,    
             	   
    output reg         gmii_tx_en		,    
    output reg [7:0]   gmii_txd        	 	 
    );


reg [1:0]  protocol_sw; 	
reg		   icmp_tx_busy;	
reg        udp_tx_busy; 	
reg        arp_rx_flag; 	
reg		   icmp_tx_req_d0;	
reg		   udp_tx_req_d0;   


assign arp_tx_type = 1'b1;   											
assign tx_req = udp_tx_req ? 1'b1 : icmp_tx_req;			    
assign icmp_tx_data = icmp_tx_req_d0 ? tx_data : 8'd0;			
assign udp_tx_data  = udp_tx_req_d0  ? tx_data : 8'd0;			

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		icmp_tx_req_d0 <= 1'd0;
		udp_tx_req_d0 <= 1'd0;
	end
	else begin
		icmp_tx_req_d0 <= icmp_tx_req;
        udp_tx_req_d0  <= udp_tx_req;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rec_en	  <= 1'd0;
        rec_data  <= 1'd0;
	end
	else if (icmp_rec_en) begin
		rec_en	  <= icmp_rec_en;
        rec_data  <= icmp_rec_data;
	end
	else if(udp_rec_en) begin
		rec_en	  <= udp_rec_en;
        rec_data  <= udp_rec_data;
	end
	else begin
		rec_en	  <= 1'd0;
        rec_data  <= rec_data;
	end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
		gmii_tx_en <= 1'd0;
		gmii_txd   <= 8'd0;
	end
	else begin
		case(protocol_sw)
			2'b00:	begin
				gmii_tx_en <= arp_gmii_tx_en;
				gmii_txd   <= arp_gmii_txd;
			end
			2'b01: begin
				gmii_tx_en <= udp_gmii_tx_en;
				gmii_txd   <= udp_gmii_txd  ;		
			end
			2'b10: begin
				gmii_tx_en <= icmp_gmii_tx_en;
				gmii_txd   <= icmp_gmii_txd;
			end
			default:;
		endcase
	end
end	

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        icmp_tx_busy <= 1'b0;
	end
    else if(icmp_tx_start_en)
        icmp_tx_busy <= 1'b1;
    else if(icmp_tx_done)
        icmp_tx_busy <= 1'b0;
	else ;	
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        udp_tx_busy <= 1'b0;
    else if(udp_tx_start_en)
        udp_tx_busy <= 1'b1;
    else if(udp_tx_done)
        udp_tx_busy <= 1'b0;
	else ;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        arp_rx_flag <= 1'b0;
    else if(arp_rx_done && (arp_rx_type == 1'b0))   
        arp_rx_flag <= 1'b1;
    else 
        arp_rx_flag <= 1'b0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        protocol_sw <= 2'b0;
        arp_tx_en <= 1'b0;
    end
    else begin
        arp_tx_en <= 1'b0;
		if (udp_tx_start_en) begin
			protocol_sw <= 2'b01;
		end
        else if(icmp_tx_start_en) begin
            protocol_sw <= 2'b10;
		end
        else if((arp_rx_flag && (udp_tx_busy == 1'b0)) || (arp_rx_flag && (icmp_tx_busy == 1'b0))) begin
            protocol_sw <= 2'b0;
            arp_tx_en <= 1'b1;
        end    
		else ;
    end        
end

endmodule