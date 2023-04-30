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
reg [6:0] data_stack [15:0];
reg [6:0] outputstring [15:0]; // 16 characters at mose 
reg [3:0] string_index=0,stack_index=0,data_index=0,result_index=0 ;
reg [3:0] stack_order=0,data_order=0;
reg [3:0] operation_order=0;
reg [6:0] result_stack [15:0];
reg [7:0] temp=0 ;

localparam WAIT = 3'd0;
localparam DATA_IN= 3'd1;
localparam SORT = 3'd2;
localparam g_POP1 = 3'd3; //stack一般優先度
localparam r_POP2 = 3'd4; //stack遇到右括號
localparam e_POP3 = 3'd5; //stack遇到等號
localparam OPERATION = 3'd6;
localparam OUT = 3'd7;


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
			if(ascii_in!=8'61) next_state = DATA_IN ;
			else next_state = SORT ;
		end
		SORT: begin
			if(stack_index>0 && ((data_stack[data_order]==4'd42||4'd43||4'd45) && stack[stack_index-1]==4'd42)) next_state = g_POP1;
			else if(stack_index>0 && ((data_stack[data_order]==4'd43||4'd45) && stack[stack_index-1]==4'd43)) next_state = g_POP1;
			else if(stack_index>0 && ((data_stack[data_order]==4'd43||4'd45) && stack[stack_index-1]==4'd45)) next_state = g_POP1;
			else if(data_stack[data_order]==4'd41) next_state = r_POP2 ;
			else if(data_stack[data_order]==4'd61) next_state = e_POP2 ;
			else next_state = SORT;
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
			// if(data_stack[data_order-1]==8'd41) next_state = POP ;
			// else if(data_stack[data_order-1]==8'd61) next_state = POP ;
			// else if(stack_index>0 && stack[stack_index-1]==8'd42 && data_stack[data_order-1]>=8'd42  && data_stack[data_order-1]<=8'd45) next_state = POP;
			// else if(stack_index>0 && stack[stack_index-1]==8'd43 && data_stack[data_order-1]>=8'd43  && data_stack[data_order-1]<=8'd45) next_state = POP;
			// else if(stack_index>0 && stack[stack_index-1]==8'd45 && (data_stack[data_order-1]==8'd43||data_stack[data_order-1]==8'd45 )) next_state = POP;
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
			data_stack[data_index] <= ascii_in ;
			data_index <= data_index +1 ;
		end
		SORT: begin
			
		end
			// data_stack[data_index] <= ascii_in;
			// data_index <= data_index+1 ;
			// // if((ascii_in>=8'd48 && ascii_in<=8'd57 )|| (ascii_in>=8'd97 && ascii_in<=8'd102)) begin
				// // outputstring[string_index] <= ascii_in ;
				// // string_index <= string_index +1 ;
			// // end
			// // else if (stack_index>0 && stack[stack_index-1]==8'd42 && ascii_in>=8'd42 ) begin
				// // outputstring[string_index] <= stack[stack_index-1]
				// // string_index <= string_index +1 ;
				// // stack_index <= stack_index-1 ;
			// // end
			// // else if (stack_index>0 && stack[stack_index-1]==8'd43 && ascii_in>=8'd43 ) begin
				// // outputstring[string_index] <= stack[stack_index-1]
				// // string_index <= string_index +1 ;
				// // stack_index <= stack_index-1 ;
			// // end
			// // else if (stack_index>0 && stack[stack_index-1]==8'd45 && (ascii_in==8'd43||ascii_in==8'd45 )) begin
				// // outputstring[string_index] <= stack[stack_index-1]
				// // string_index <= string_index +1 ;
				// // stack_index <= stack_index-1 ;
			// // end
			// // else begin
				// // stack[stack_index] <= ascii_in ;
				// // stack_index <= stack_index+1 ;
			// // end
			
		// end
		// SORT:begin
			// if ((data_stack[data_order-1]<8'd58 && data_stack[data_order-1]>8'd47 ) || ((stack[stack_order-1])>=8'd97 && (stack[stack_order-1])<=8'd102 )) begin
				// outputstring[string_index] <= data_stack[data_order-1] ;
				// data_order <= data_order+1;
				// string_index <= string_index+1;
				// // temp <= stack_order ;
				// // stack_deparen[deparen_order] <= stack[stack_order-1];
				// // deparen_order <= deparen_order+1 ;
				// // stack_order <= stack_order -1 ;
			// end
			// else begin
				// stack[stack_index] <= data_stack[data_order-1];
				// stack_index <= stack_index +1;
				// data_order <= data_order+ 1;
						
			// end
		// end
		// POP:begin
			// if (stack_index==0) begin
				// string_index <= string_index +1 ;
			// end
			// // else if((stack[stack_index-8'd1]==8'd42 && stack[stack_index]>=8'd42) || 
				// // (stack[stack_index-8'd1]==8'd43 && stack[stack_index]>=8'd43) ||
				// // (stack[stack_index-8'd1]==8'd45 && (stack[stack_index]==8'd43||stack[stack_index]==8'd45 )))begin			
				
					// // outputstring[string_index] <= stack[stack_index-1];			
					// // stack_index <= stack_index -1 ;
					// // string_index <= string_index +1 ; 
					// // en_swap <= 1 ;				
					// // temp <= stack[stack_index];
			// // end
			// else if(stack[stack_index-2]==8'd42 && stack[stack_index-1]>=8'd42 && stack[stack_index-1]<=8'd45) begin
				// outputstring[string_index] <= stack[stack_index-2];	
				// stack[stack_index-2] <= stack[stack_index-1] ;
				// stack_index <= stack_index -1 ;
				// string_index <= string_index +1;
			// end
			// else if(stack[stack_index-2]==8'd43 && stack[stack_index-1]>=8'd43 && stack[stack_index-1]<=8'd45) begin
				// outputstring[string_index] <= stack[stack_index-2];
				// stack[stack_index-2] <= stack[stack_index-1] ;
				// stack_index <= stack_index -1 ;
				// string_index <= string_index +1;
			// end
			// else if(stack[stack_index-2]==8'd45 && (stack[stack_index-1]==8'd43||stack[stack_index-1]==8'd45 )) begin
				// outputstring[string_index] <= stack[stack_index-2];
			    // stack[stack_index-2] <= stack[stack_index-1] ;
			    // stack_index <= stack_index -1 ;
			    // string_index <= string_index +1;
			// end
			// else if (stack[stack_index-1]==8'd61) begin
				// stack_index <= stack_index -1 ;
			// end
			// else begin
				// outputstring[string_index] <= stack[stack_index-1] ;
				// stack_index <= stack_index -1 ;
				// string_index <= string_index +1 ;
			// end
		// end
		// OPERATION: begin
			// if(outputstring[operation_order-1]==8'd42) begin
				// result_stack[result_index-4'd2] <= result_stack[result_index-4'd2]*result_stack[result_index-4'd1];
				// operation_order <= operation_order +1 ;
				// result_index <= result_index-4'd2;
			// end
			// else if(outputstring[operation_order-1]==8'd43) begin
				// result_stack[result_index-4'd2] <= result_stack[result_index-4'd2]+result_stack[result_index-4'd1];
				// operation_order <= operation_order +1 ;
				// result_index <= result_index-4'd2;
			// end
			// else if(outputstring[operation_order-1]==8'd45) begin
				// result_stack[result_index-4'd2] <= result_stack[result_index-4'd2]-result_stack[result_index-4'd1];
				// operation_order <= operation_order +1 ;
				// result_index <= result_index-4'd2;
			// end
			// else begin
				// if(outputstring[operation_order-1]>8'd47 && outputstring[operation_order-1]<8'd58 ) begin
					// result_stack[result_index]<=outputstring[operation_order-1]-8'd48;
					// operation_order <= operation_order+1;
					// result_index <= result_index+1 ;
				// end
				// else if (outputstring[operation_order-1]>8'd96 && outputstring[operation_order-1]<8'd103) begin
					// result_stack[result_index]<=outputstring[operation_order-1]-8'd87;
					// operation_order <= operation_order+1;
					// result_index <= result_index+1 ;
				// end
				// else begin
					// result_stack[result_index]<=outputstring[operation_order-1];
					// operation_order <= operation_order+1;
					// result_index <= result_index+1 ;
				// end
			// end
		// end
		// OUT: begin
			// valid <= 1;
			// result <= result_stack[0] ;
		// end
		// WAIT: begin
			// valid <= 0;
			// result <= 0;
			// stack_index <= 0;
			// string_index <= 0;
			// stack_order <= 1	;
			// temp <= 0;
			// en_swap <= 0 ;
			// data_index <= 0;
			// data_order <= 1;
			// operation_order <=1;
		// end
	// endcase
// end
// endmodule