module rgy (
    input clk,
    input reset,
    output [3:0] rgy0,
    output [3:0] rgy1
);
    parameter RED = 0;
    parameter YELLOW = 1;
    parameter GREEN = 2;

    reg [3:0] __rgy0, __rgy1;
    reg [3:0] ps, ns;

    always @(posedge clk) begin
        if (reset) ps <= 0;
        else ps <= ns;
    end

    // controller
    /* simulater will be like this:
     *
     *     0  1  2  3  4  5  6  7  8  9  10  11  12  13  14  15  0  1
     *    ────────────────────────┐                             ┌────
     *  R0                        └─────────────────────────────┘
     *  
     *                                                  ┌───────┐
     *  Y0──────────────────────────────────────────────┘       └────
     *  
     *                            ┌─────────────────────┐
     *  G0────────────────────────┘                     └────────────
     *  
     *                            ┌─────────────────────────────┐
     *  R1────────────────────────┘                             └────
     *  
     *                      ┌─────┐
     *  Y1──────────────────┘     └──────────────────────────────────
     *  
     *    ──────────────────┐                                   ┌────
     *  G1                  └───────────────────────────────────┘
     */
    always @(*) begin
        __rgy0 = 0;
        __rgy1 = 0;
        ns = 0;
        case (ps)
        0: begin
            // Except the first turn, it will be:
            // rgy0 YELLOW to RED
            // rgy1 RED to GREEN
            __rgy0[RED] = 1;
            __rgy0[YELLOW] = 0;
            __rgy0[GREEN] = 0;
            __rgy1[RED] = 0;
            __rgy1[YELLOW] = 0;
            __rgy1[GREEN] = 1;
            ns = 1;
        end
        1: begin
            __rgy0[RED] = 1;
            __rgy0[YELLOW] = 0;
            __rgy0[GREEN] = 0;
            __rgy1[RED] = 0;
            __rgy1[YELLOW] = 0;
            __rgy1[GREEN] = 1;
            ns = 2;
        end
        2: begin
            __rgy0[RED] = 1;
            __rgy0[YELLOW] = 0;
            __rgy0[GREEN] = 0;
            __rgy1[RED] = 0;
            __rgy1[YELLOW] = 0;
            __rgy1[GREEN] = 1;
            ns = 3;
        end
        3: begin
            __rgy0[RED] = 1;
            __rgy0[YELLOW] = 0;
            __rgy0[GREEN] = 0;
            __rgy1[RED] = 0;
            __rgy1[YELLOW] = 0;
            __rgy1[GREEN] = 1;
            ns = 4;
        end
        4: begin
            __rgy0[RED] = 1;
            __rgy0[YELLOW] = 0;
            __rgy0[GREEN] = 0;
            __rgy1[RED] = 0;
            __rgy1[YELLOW] = 0;
            __rgy1[GREEN] = 1;
            ns = 5;
        end
        5: begin
            __rgy0[RED] = 1;
            __rgy0[YELLOW] = 0;
            __rgy0[GREEN] = 0;
            __rgy1[RED] = 0;
            __rgy1[YELLOW] = 0;
            __rgy1[GREEN] = 1;
            ns = 6;
        end
        6: begin
            // rgy1 GREEN to YELLOW
            __rgy0[RED] = 1;
            __rgy0[YELLOW] = 0;
            __rgy0[GREEN] = 0;
            __rgy1[RED] = 0;
            __rgy1[YELLOW] = 1;
            __rgy1[GREEN] = 0;
            ns = 7;
        end
        7: begin
            __rgy0[RED] = 1;
            __rgy0[YELLOW] = 0;
            __rgy0[GREEN] = 0;
            __rgy1[RED] = 0;
            __rgy1[YELLOW] = 1;
            __rgy1[GREEN] = 0;
            ns = 8;
        end
        8: begin
            // rgy0 RED to GREEN
            // rgy1 YELLOW to RED
            __rgy0[RED] = 0;
            __rgy0[YELLOW] = 0;
            __rgy0[GREEN] = 1;
            __rgy1[RED] = 1;
            __rgy1[YELLOW] = 0;
            __rgy1[GREEN] = 0;
            ns = 9;
        end
        9: begin
            __rgy0[RED] = 0;
            __rgy0[YELLOW] = 0;
            __rgy0[GREEN] = 1;
            __rgy1[RED] = 1;
            __rgy1[YELLOW] = 0;
            __rgy1[GREEN] = 0;
            ns = 10;
        end
        10: begin
            __rgy0[RED] = 0;
            __rgy0[YELLOW] = 0;
            __rgy0[GREEN] = 1;
            __rgy1[RED] = 1;
            __rgy1[YELLOW] = 0;
            __rgy1[GREEN] = 0;
            ns = 11;
        end
        11: begin
            __rgy0[RED] = 0;
            __rgy0[YELLOW] = 0;
            __rgy0[GREEN] = 1;
            __rgy1[RED] = 1;
            __rgy1[YELLOW] = 0;
            __rgy1[GREEN] = 0;
            ns = 12;
        end
        12: begin
            __rgy0[RED] = 0;
            __rgy0[YELLOW] = 0;
            __rgy0[GREEN] = 1;
            __rgy1[RED] = 1;
            __rgy1[YELLOW] = 0;
            __rgy1[GREEN] = 0;
            ns = 13;
        end
        13: begin
            __rgy0[RED] = 0;
            __rgy0[YELLOW] = 0;
            __rgy0[GREEN] = 1;
            __rgy1[RED] = 1;
            __rgy1[YELLOW] = 0;
            __rgy1[GREEN] = 0;
            ns = 14;
        end
        14: begin
            // rgy0 GREEN to YELLOW
            __rgy0[RED] = 0;
            __rgy0[YELLOW] = 1;
            __rgy0[GREEN] = 0;
            __rgy1[RED] = 1;
            __rgy1[YELLOW] = 0;
            __rgy1[GREEN] = 0;
            ns = 15;
        end
        15: begin
            __rgy0[RED] = 0;
            __rgy0[YELLOW] = 1;
            __rgy0[GREEN] = 0;
            __rgy1[RED] = 1;
            __rgy1[YELLOW] = 0;
            __rgy1[GREEN] = 0;
            ns = 0; // loop
        end
        endcase
    end

    assign rgy0 = __rgy0;
    assign rgy1 = __rgy1;

endmodule