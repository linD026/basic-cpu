module test_counter_4bits;
    reg clk, reset;
    wire [3:0] counter;

    counter_4bits test(
        .clk(clk),
        .reset(reset),
        .counter(counter),
        .base(0'b0)
    );
    
    always #10 clk = ~clk;
    initial begin
        #0 clk = 0; reset = 1;
        #50 reset = 0;
        #1000 $stop;
    end

    initial begin
        $monitor($time, " counter = %d", counter);     
    end
endmodule