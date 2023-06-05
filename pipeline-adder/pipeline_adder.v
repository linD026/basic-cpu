module pipeline_adder (
    input clk,
    input reset,
    input [4:0] a,
    input [4:0] b,
    input [4:0] c,
    input [4:0] d,
    input [4:0] e,
    output [4:0] s
);

/*
 *                     pipeline                     pipeline
 *                       +--+                         +--+
 *        +---+          |  |                         |  |
 * A ----->   | __ab_sum |  | ab_sum                  |  |
 *        |   +----------+  +---+                     |  |
 *        | + |          |  |   |                     |  |
 * B ----->   |          |  |   |   +-----+           |  |
 *        +---+          |  |   +--->     |           |  |     +-------+
 *                       |  |       |     | __abcd_sum|  |  x  |       |
 *                       |  |       |  -  +-----------+  +----->       |
 *                       |  |       |     |           |  |     |       |
 *        +---+          |  |   +--->     |           |  |     |       |
 * C ----->   | __cd_sum |  |   |   +-----+           |  |     |       |  s
 *        |   +----------+  +---+                     |  |     |   &   +----->
 *        | + |          |  | cd_sum                  |  |     |       |
 * D ----->   |          |  |                         |  |     |       |
 *        +---+          |  |                         |  |     |       |
 *                       |  | e_tmp1                  |  |  y  |       |
 * E --------------------+  +-------------------------+  +----->       |
 *                       |  |                         |  |     +-------+
 *                       |  |                         |  |
 *                       +--+                         +--+
 */

    reg [4:0] ab_sum, cd_sum, e_tmp1, x, y;
    wire [4:0] __ab_sum, __cd_sum, __abcd_sum;

    /* first layer - two adders
     */
    assign __ab_sum = a + b;
    assign __cd_sum = c + d;

    /* second layer - pipeline
     */
    always @(posedge clk) begin
        if (reset) ab_sum <= 0;
        else ab_sum <= __ab_sum;
    end
    always @(posedge clk) begin
        if (reset) cd_sum <= 0;
        else cd_sum <= __cd_sum;
    end
    always @(posedge clk) begin
        if (reset) e_tmp1 <= 0;
        else e_tmp1 <= e;
    end

    /* third layer - subtractor
     */
    assign __abcd_sum = ab_sum - cd_sum;

    /* fourth layer - pipeline 
     */
    always @(posedge clk) begin
        if (reset) x <= 0;
        else x <= __abcd_sum;
    end
    always @(posedge clk) begin
        if (reset) y <= 0;
        else y <= e_tmp1;
    end

    /* fifth layer - logic AND
     */
    assign s = x & y;

endmodule