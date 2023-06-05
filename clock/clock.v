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

/*
 *                 +----------------+
 *       +-------->| min unit digit |
 *       |         |    counter     |
 *     reset       +------+---------+
 *     at|9               |
 *       +----------------+  carry out (limit 9)
 *                        |
 *                  +-----v---------+
 *       +--------->| min ten digit |
 *       |          |  accumulater  |
 *     reset        +-----+---------+
 *     at|5               |
 *       +----------------+
 *                        | carry out (limit 5)
 *                        |
 *                 +------v---------+
 *      +----------+ hr unit digit  +---------+
 *      |          |       &        |         |
 * reset|at 23     |  hr ten digit  |<--------+
 *      +--------->|  accumulater   |     carry out (unit limit 9)
 *                 +----------------+
 */

module counter_clock (
    input clk,
    input reset,
    output [2:0] min_tens, /* max value of min is 59, so it need {3,4} bits */
    output [3:0] min_units,
    output [2:0] hr_tens,
    output [3:0] hr_units
);
    reg [6:0] hr_buffer, min_buffer;
    wire [3:0] __min_uints;

    counter_4bits min_uint_cnt(
        .counter(__min_uints),
        .base(0'b0),
        .clk(clk),
        .reset(reset)
    );

    always @(negedge clk or reset) begin
        if (reset) begin
            min_buffer <=0;
            hr_buffer <= 0;
        end
        else min_buffer[3:0] <= __min_uints;
        
        // if min is out of bound (> 59 next time)
        // carry out, reset and adding into hr buffer
        if (min_buffer[6:4] == 5 && min_buffer[3:0] == 9) begin
            min_buffer[6:4] <= 0;
            hr_buffer[3:0] <= (hr_buffer[3:0] + 1) % 10;
            // if hr unit is out of bound (> x9 or 23 next time)
            // carry out, reset and adding into hr tens
            if (hr_buffer[3:0] == 9 || 
                (hr_buffer[6:4] == 2 && hr_buffer[3:0] == 3)) begin
                hr_buffer[3:0] <= 0;
                hr_buffer[6:4] <= (hr_buffer[6:4] + 1) % 3;
            end
        end
        // if min unit is out of bound (> x9 next time)
        else if (min_buffer[3:0] == 9)
            min_buffer[6:4] <= (min_buffer[6:4] + 1) % 10;
    end

    assign min_units = min_buffer[3:0];
    assign min_tens = min_buffer[6:4];
    assign hr_units = hr_buffer[3:0];
    assign hr_tens = hr_buffer[6:4];
endmodule