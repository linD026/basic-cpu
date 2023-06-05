module counter_4bits (
    output [3:0] counter,
    input [3:0] base, 
    input clk,
    input reset
);
    reg [3:0] buffer;
    always @(negedge clk or reset) begin
        if (reset || (buffer == 9))
           buffer <= 0;
        else buffer <= buffer + 1'b1; 
    end
    assign counter = buffer;
    always @(base) begin
        buffer <= base;
    end
endmodule

module counter_BCD (
    output [7:0] out,
    input clk,
    input reset
);
    wire carry;
    wire [3:0] uint, ten, base;
    reg [7:0] buffer;

    // base will overwrite the buffer of 4bits counter
    // this will used at the carry into ten digit.
    assign base = buffer[7:4];

    counter_4bits uint_cnt(
        .counter(uint),
        .base(0'b0),
        .clk(clk),
        .reset(reset)
    );

    counter_4bits ten_cnt(
        .counter(ten),
        .base(base),
        .clk(clk),
        .reset(reset)
    );

    // update the BCD buffer
    always @(negedge clk or ten or uint) begin
        buffer <= {ten, uint};
        if (buffer[3:0] == 9)
            buffer[7:4] <= (buffer[7:4] + 1) % 10;
    end

    assign out = buffer;

endmodule