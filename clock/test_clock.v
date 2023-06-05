module test_counter;
    reg clk, reset;
    wire [2:0] hr_tens, min_tens;
    wire [3:0] hr_units, min_units;
    counter_clock test1(.clk(clk), .reset(reset),
                        .hr_tens(hr_tens),
                        .hr_units(hr_units),
                        .min_tens(min_tens),
                        .min_units(min_units));
    always #5 clk = ~clk;
    initial begin
        clk = 0; reset = 1;
        #10 reset = 0;
        #16000 $stop;
    end

    initial begin
        $monitor($time, " hr:%d%d min:%d%d", hr_tens, hr_units, min_tens, min_units);     
    end
endmodule