module test_fetch_cycle;
    wire [13:0] ir;
    reg clk, reset;
    fetch_cycle test (
        .clk(clk),
        .reset(reset),
        .ir(ir)
    );
  
    always #10 clk = ~clk;
    
    initial begin
        clk = 0; reset = 1;
        #20 reset = 0;
        #1000 $stop;
    end
endmodule
