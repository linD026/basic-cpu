module test_counter_ports;

    reg clk, reset;
    wire [9:0] port_a;
    wire [9:0] port_b;

    counter_ports test(
        .clk(clk),
        .reset(reset),
        .port_a(port_a),
        .port_b(port_b)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1;
        #10 reset = 0;
        #1000 $stop;
    end

    initial begin
        $monitor($time, " port A:%d, port B: %d", port_a, port_b);
    end

endmodule