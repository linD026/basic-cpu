module test_pipeline_adder;

    reg clk, reset;
    reg [4:0] a, b, c, d, e;
    wire [4:0] s;

    pipeline_adder test(
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .s(s)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1;
        #10 reset = 0;
        #15 a = 6; b = 7; c = 8; d = 3; e = 10;
        #20 a = 4; b = 8; c = 7; d = 3; e = 1;
        #25 a = 1; b = 9; c = 6; d = 3; e = 5;
        #30 a = 8; b = 7; c = 3; d = 7; e = 2;
        #35 a = 6; b = 10; c = 3; d = 3; e = 10;
        #40 a = 11; b = 9; c = 6; d = 5; e = 6;
        #45 a = 6; b = 8; c = 2; d = 7; e = 1;
        #50 a = 11; b = 10; c = 4; d = 3; e = 2;
        #55 a = 7; b = 4; c = 10; d = 7; e = 9;
        #60 a = 2; b = 8; c = 11; d = 13; e = 5;
        #100 $stop;
    end

    initial begin
        $monitor($time, " Ans: %d, result: %d", ((a + b) - (c + d)) & e, s);
    end

endmodule