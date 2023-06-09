//注意result最後正負的誰減誰 見L189 
//注意index需不需要-1 通常要到時脈圖去看 見L65 L71
//特殊情況的測資 見L67 L68 L69
//把不要的符號丟棄 見L159 L162 L172
module AEC(clk, rst, ascii_in, ready, valid, result);

// Input signal
input clk;
input rst;	
input ready;
input [7:0] ascii_in;

// Output signal
output reg valid;
output reg [6:0] result;

reg [2:0] state, next_state; // eight states at most 0~7
reg [6:0] stack [15:0];
reg [6:0] outputstring [15:0]; // 16 characters at mose 
reg [3:0] string_index=0,stack_index=0,data_index=0,result_index=0 ;
reg [3:0] stack_order=0,data_order=0;
reg [3:0] operation_order=0;
reg [6:0] data_stack_result_stack [15:0];


localparam WAIT = 3'd0;
localparam DATA_IN= 3'd1;
localparam SORT = 3'd2;
localparam g_POP1 = 3'd3; //stack一般優先度
localparam r_POP2 = 3'd4; //stack遇到右括號
localparam e_POP3 = 3'd5; //stack遇到等號
localparam OPERATION = 3'd6;
localparam OUT = 3'd7;
integer i;

//-----Your design-----//
always @(posedge clk,posedge ready) begin 
	if(rst) begin
		state<=WAIT;
	end
	else if (ready) begin
		state<= DATA_IN ;
	end
	else begin
		state <= next_state;
	end
end

always @(*) begin
	case(state)
		WAIT: begin
			next_state = DATA_IN ;
		end
		DATA_IN: begin
			if(ascii_in==8'd61) next_state = SORT ;
			else next_state = DATA_IN ;
		end
		SORT: begin
			if(stack_index>0 && ((data_stack_result_stack[data_order]==7'd42|| data_stack_result_stack[data_order]==7'd43 || data_stack_result_stack[data_order]==7'd45) && stack[stack_index-1]==8'd42)) next_state = g_POP1;
			else if(stack_index>0 && ((data_stack_result_stack[data_order]==7'd43|| data_stack_result_stack[data_order]==7'd45) && stack[stack_index-1]==7'd43)) next_state = g_POP1;
			else if(stack_index>0 && ((data_stack_result_stack[data_order]==7'd43|| data_stack_result_stack[data_order]==7'd45) && stack[stack_index-1]==7'd45)) next_state = g_POP1;
			else if(data_stack_result_stack[data_order]==7'd41) next_state = r_POP2 ;
			else if(data_stack_result_stack[data_order]==7'd61) next_state = e_POP3 ;
			else next_state = SORT;
		end
		g_POP1: begin
			if((stack[stack_index-1]==7'd42|| stack[stack_index-1]==7'd43 || stack[stack_index-1]==7'd45) && stack[stack_index-3]==7'd42) next_state = g_POP1;
			else if((stack[stack_index-1]==7'd43|| stack[stack_index-1]==7'd45) && stack[stack_index-3]==7'd43) next_state = g_POP1;
			else if((stack[stack_index-1]==7'd43|| stack[stack_index-1]==7'd45) && stack[stack_index-3]==7'd45) next_state = g_POP1;
			else next_state = SORT ;
		end
		r_POP2: begin
			if(stack[stack_index-1]==7'd40) next_state = SORT ;
			else next_state = r_POP2 ;
		end
		e_POP3: begin
			if(stack_index-1==0) next_state = OPERATION ;
			else next_state = e_POP3 ;
		end
		OPERATION: begin
			if(operation_order==string_index-1) next_state = OUT ;
			else next_state = OPERATION ;
		end
		OUT: begin
			next_state = WAIT ;
		end
	endcase
end
		//processing data when ascii_in come in every clk .
		// DATA_IN: begin  
			// if(ascii_in!=8'd61) next_state = DATA_IN;
			// else next_state = SORT ;
				
			// // if(ascii_in==8'd61) next_state = OPERATION;
			// // else if (stack_index==0) next_state = 
			// // else if (stack_index>0 && (ascii_in==8'd41)) next_state = POP ;
			// // else if (stack_index>0 && temp==8'd42 && ascii_in>=temp) next_state = POP ;
			// // else if (stack_index>0 && temp==8'd45 && ascii_in==8'd43) next_state = POP
			// // else state = DATA_IN ;
		// end
		
		// SORT: begin //sort才加data order
			// if(data_stack_result_stack[data_order-1]==8'd41) next_state = POP ;
			// else if(data_stack_result_stack[data_order-1]==8'd61) next_state = POP ;
			// else if(stack_index>0 && stack[stack_index-1]==8'd42 && data_stack_result_stack[data_order-1]>=8'd42  && data_stack_result_stack[data_order-1]<=8'd45) next_state = POP;
			// else if(stack_index>0 && stack[stack_index-1]==8'd43 && data_stack_result_stack[data_order-1]>=8'd43  && data_stack_result_stack[data_order-1]<=8'd45) next_state = POP;
			// else if(stack_index>0 && stack[stack_index-1]==8'd45 && (data_stack_result_stack[data_order-1]==8'd43||data_stack_result_stack[data_order-1]==8'd45 )) next_state = POP;
			// else next_state = SORT ;
		// end
		
		// POP: begin
			// if(stack[stack_index-1]==8'd40) next_state = SORT ;
			// else if (data_order-1==data_index) next_state = POP ;
			// else if (stack_index==0) next_state = OPERATION;
			// else next_state = POP ;
		// end
		
		// OPERATION: begin
			// if(operation_order==string_index-1) next_state = OUT ; 
			// else next_state = OPERATION ;
		// end
		// OUT: begin
			// next_state = WAIT ;
		// end
		// default: begin
			// next_state = WAIT ;
		// end
	// endcase
// end

always @(posedge clk) begin

	case(state)
		DATA_IN:begin
			data_stack_result_stack[data_index] <= ascii_in ;
			data_index <= data_index +1 ;
		end
		SORT: begin
			if((data_stack_result_stack[data_order]>7'd47 && data_stack_result_stack[data_order]<7'd58) || (data_stack_result_stack[data_order]>7'd96 && data_stack_result_stack[data_order]<7'd103)) begin
			outputstring[string_index] <= data_stack_result_stack[data_order];
			data_order <= data_order+1 ;
			string_index <= string_index+1;
			end
			else begin
				stack[stack_index] <= data_stack_result_stack[data_order] ;
				data_order <= data_order+1 ;
				stack_index <= stack_index+1;
			end
			
		end
		g_POP1:begin
			outputstring[string_index] <= stack[stack_index-2] ;
			stack[stack_index-2] <= stack[stack_index-1] ;
			string_index <= string_index+1;
			stack_index <= stack_index-1;
		end
		r_POP2:begin
			if (stack[stack_index-1]==7'd41) begin 
				stack_index <= stack_index-1;
			end
			else if (stack[stack_index-1]==7'd40) begin
				stack_index <= stack_index-1 ;
			end
			else begin
				outputstring[string_index] <= stack[stack_index-1] ;
				string_index <= string_index+1;	
				stack_index <= stack_index-1 ;
			end
		end
		e_POP3: begin
			if (stack[stack_index-1]==7'd61) begin
				stack_index <= stack_index-1;
			end
			else begin
				outputstring[string_index] <= stack[stack_index-1]  ;
				string_index <= string_index+1 ;
				stack_index <= stack_index-1;
			end
		end
		OPERATION: begin
			if(outputstring[operation_order]==7'd42) begin
				data_stack_result_stack[result_index-4'd2] <= data_stack_result_stack[result_index-4'd2]*data_stack_result_stack[result_index-4'd1];
				operation_order <= operation_order +1 ;
				result_index <= result_index-4'd1;
			end
			else if(outputstring[operation_order]==7'd43) begin
				data_stack_result_stack[result_index-4'd2] <= data_stack_result_stack[result_index-4'd2]+data_stack_result_stack[result_index-4'd1];
				operation_order <= operation_order +1 ;
				result_index <= result_index-4'd1;
			end
			else if(outputstring[operation_order]==7'd45) begin
				data_stack_result_stack[result_index-4'd2] <= (data_stack_result_stack[result_index-4'd2]>data_stack_result_stack[result_index-4'd1])?
					data_stack_result_stack[result_index-4'd2]-data_stack_result_stack[result_index-4'd1]:
					data_stack_result_stack[result_index-4'd1]-data_stack_result_stack[result_index-4'd2];
				operation_order <= operation_order +1 ;
				result_index <= result_index-4'd1;
			end
			else if(outputstring[operation_order]>7'd47 && outputstring[operation_order]<7'd58 ) begin
				data_stack_result_stack[result_index]<=outputstring[operation_order]-7'd48;
				operation_order <= operation_order+1;
				result_index <= result_index+1 ;
			end
			else if (outputstring[operation_order]>7'd96 && outputstring[operation_order]<7'd103) begin
				data_stack_result_stack[result_index]<=outputstring[operation_order]-7'd87;
				operation_order <= operation_order+1;
				result_index <= result_index+1 ;
			end
			else begin
				data_stack_result_stack[result_index]<=outputstring[operation_order];
				operation_order <= operation_order+1;
				result_index <= result_index+1 ;
			end
		end	
		OUT: begin
			valid <= 1;
			result <= data_stack_result_stack[0] ;
		end
		
		WAIT: begin
			valid <= 0;
			result <= 0;
			stack_index <= 0;
			string_index <= 0;
			stack_order <= 0;
			data_index <= 0;
			data_order <= 0;
			operation_order <=0;
			result_index <= 0 ;
			// for(i=0;i<15;i=i+1) stack[i] <= 4'd15;
			// for(i=0;i<15;i=i+1) data_stack_result_stack[i] <= 4'd15;
			// for(i=0;i<15;i=i+1) outputstring[i] <= 4'd15;
		end
	endcase
end
endmodule