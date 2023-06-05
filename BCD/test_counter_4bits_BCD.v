module test_counter_4bits_BCD;
    reg clk, reset;
    wire [3:0] unit_digit, ten_digit;

    counter_BCD test(
        .out({ten_digit, unit_digit}),
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;
    initial begin
        clk = 0; reset = 1;
        #10 reset = 0;
        #1000 $stop;
    end

    initial begin
        $monitor($time, "   %d%d", ten_digit, unit_digit);     
    end
endmodule