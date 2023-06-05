module test_counter_adder;
    parameter RED = 0;
    parameter YELLOW = 1;
    parameter GREEN = 2;

    reg clk, reset;
    wire [3:0] rgy0, rgy1;

    rgy test(
        .clk(clk),
        .reset(reset),
        .rgy0(rgy0),
        .rgy1(rgy1)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1;
        #10 reset = 0;
        #1000 $stop;
    end

    initial begin
        $monitor($time, " rgy0 R: %d G: %d Y: %d; rgy1 R: %d G: %d Y: %d",
                        rgy0[RED], rgy0[GREEN], rgy0[YELLOW],
                        rgy1[RED], rgy1[GREEN], rgy1[YELLOW]);
    end

endmodule