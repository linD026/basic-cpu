module test_counter_adder;

    reg clk, reset;
    wire [3:0] out;

    counters test(
        .clk(clk),
        .reset(reset),
        .out(out)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1;
        #10 reset = 0;
        #1000 $stop;
    end

    initial begin
        $monitor($time, " %d", out);
    end

endmodule