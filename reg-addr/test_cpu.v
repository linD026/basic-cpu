module test_cpu;
    wire [7:0] w_q;
    reg clk, reset;
    cpu test (
        .clk(clk),
        .reset(reset),
        .w_q_out(w_q)
    );
  
    always #10 clk = ~clk;
    
    initial begin
        clk = 0; reset = 1;
        #20 reset = 0;
        #2000 $stop;
    end
endmodule
