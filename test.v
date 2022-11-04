module test();
   reg signed [3:0] a, b;
   wire [7:0] 	     p;
   reg 		     rst;
   wire 	     halt;

   wire 	     clk;
initial
  begin
     $dumpfile("target/waveform.vcd");
     $dumpvars(0, test);
     
     $display("Hello World");
     a = 11;
     b = 10;
     rst = 0;

     #20 $display("p = %d", p);
     
     $finish;
  end 
   clock c(.clk(clk));
   slmul4 m1(.clk(clk), .x(a), .y(b), .p(p), .reset(rst), .halt(halt));
endmodule 

module clock(output reg clk);
   initial while (1) begin
      clk = 0;
      #1 clk = 1;
      #1 clk = 0;
   end
endmodule

