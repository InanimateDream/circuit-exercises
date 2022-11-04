// -*-verilog-*-

module fa1 (input x, y, cin, output s, cout);
    assign s = x ^ y ^ cin;
    assign cout = x & cin | y & cin | x & y;
endmodule // fa1

module fa4 (input [3:0] x, y, input cin, output [3:0] s, output cout);
    wire [2:0] cs;
    fa1 a1(x[0], y[0], cin, s[0], cs[0]);
    fa1 a2(x[1], y[1], cs[0], s[1], cs[1]);
    fa1 a3(x[2], y[2], cs[1], s[2], cs[2]);
    fa1 a4(x[3], y[3], cs[2], s[3], cout);
endmodule // fa4

module fa8 (input [7:0] x, y, input cin, output [7:0] s, output cout);
   wire cs;
   fa4 a1(x[3:0], y[3:0], cin, s[3:0], cs);
   fa4 a2(x[7:4], y[7:4], cs, s[7:4], cout);
endmodule // fa8

module acc8(input clk, cin, ena, input [7:0] x, output [7:0] acc);
   reg [7:0] acc_;
   reg 	     is_first = 1;

   always @(posedge clk/*, negedge clk*/) begin
      if (ena) begin
	 if (is_first) begin
	    acc_ <= 8'h0;
	    is_first <= 0;
	 end else
	    acc_ <= acc;
      end else
	 is_first <= 1;
   end
   fa8 a1(.x(x), .y(acc_), .cin(cin), .s(acc));
endmodule // acc8

module shiftr4 (input clk, input reset, input load, input shift, input [3:0] data, output reg [3:0] q);
   always @(posedge clk)
     q <= reset ? 4'b0000 : load ? data : shift ? {1'b0, q[3:1]} : q;
endmodule // shiftr4

module shiftl4 (input clk, input reset, input load, input shift, input [3:0] data, output reg [3:0] q);
   always @(posedge clk)
     q <= reset ? 4'b0000 : load ? data : shift ? {q[2:0], 1'b0} : q;
endmodule // shiftl4

module shiftl8 (input clk, input reset, input load, input shift, input [7:0] data, output reg [7:0] q);
   always @(posedge clk)
     q <= reset ? 8'h0 : load ? data : shift ? {q[6:0], 1'b0} : q;
endmodule // shiftl8

module slmul4(input clk, reset, input [3:0] x, y, output reg [7:0] p, output reg halt);
   wire [3:0] _x;
   wire [7:0] _y;
   reg  [7:0] _pp;
   wire [7:0] acc;

   reg 	      first = 1;
   reg 	      second = 1;
   reg 	      acc_ena = 0;
   reg 	      rst = 1;
   reg 	      load = 0;
   reg 	      shift = 0;
   
   always @(posedge clk) begin
      if (reset) begin
	 halt <= 1;
	 _pp <= 4'h0;
	 
	 first <= 1;
	 second <= 1;
	 acc_ena = 0;
	 
 	 rst <= 1;
	 load <= 0;
	 shift <= 0;
      end else if (first) begin
	 halt <= 0;
	 first <= 0;
	 rst <= 0;

	 if (x ^ 4'h0)
	    load <= 1;
	 else begin
	    p <= 0;
	    halt <= 1;
	    rst <= 1;
	 end
      end else begin
	 if (_x ^ 4'h0) begin
	    acc_ena <= 1;
	    _pp <= _y & {7{_x[0]}};
	    
	    load <= 0;
	    shift <= 1;
	 end else begin
	    if (second)
	      second <= 0;
	    else begin
	       if (~halt) begin
		  p <= acc;
		  halt <= 1;
		  acc_ena <= 0;
		  rst <= 1;
		  shift <= 0;
	       end
	    end
	 end
      end
   end

   acc8 accumulator(.clk(clk), .cin(1'b0), .ena(acc_ena), .x(_pp), .acc(acc));
   shiftl8 partial_product(.clk(clk), .reset(rst), .load(load), .shift(shift), .data(y), .q(_y));
   shiftr4 multiplier(.clk(clk), .reset(rst), .load(load), .shift(shift), .data(x), .q(_x));   
endmodule // slmul4

