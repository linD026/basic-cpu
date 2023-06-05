module counter_ports (
    input clk,
    input reset,
    output [9:0] port_a,
    output [9:0] port_b
);
    parameter STATE_PORT_NONE = 2'b00;
    parameter STATE_PORT_A = 2'b01;
    parameter STATE_PORT_B = 2'b10;

    reg [4:0] ps, ns;
    reg [1:0] port_select;
    reg cnt;
    reg [9:0] __port_a, __port_b, counter, buffer;
    wire [9:0] sum;

    always @(posedge clk) begin
        if (reset) ps <= 0;
        else ps <= ns;
    end

    /* Counter part
     */

    always @(posedge clk) begin
        if (reset) counter <= 0;
        else if (cnt) counter <= counter + 1;
    end

    /* Adder part
     */

    assign sum = counter + buffer;

    /* Buffer part - Added with the counter
     */

    always @(posedge clk) begin
        if (reset) buffer <= 0;
        else buffer <= sum;
    end

    /* Controller part
     */

    always @(*) begin
        /* set the default of cnt at 1 for reducing the case statements */
        cnt = 1;
        ns = 0;
        port_select = STATE_PORT_NONE;
        case (ps)
        0: ns = 1;
        1: ns = 2;
        2: ns = 3;
        3: ns = 4;
        4: ns = 5;
        5: ns = 6;
        6: ns = 7;
        7: ns = 8;
        8: ns = 9;
        9: ns = 10;
        10: begin
            /* sum access the port A */
            port_select = STATE_PORT_A; 
            ns = 11;
        end
        11: ns = 12;
        12: ns = 13;
        13: ns = 14;
        14: ns = 15;
        15: ns = 16;
        16: ns = 17;
        17: ns = 18;
        18: ns = 19;
        19: ns = 20;
        20: begin
            /* sum access the port B */
            port_select = STATE_PORT_B;
            ns = 21;            
        end 
        21: begin
            /* Stop statement */
            cnt = 0;
            ns = 21;
        end
        endcase
    end

    /* Ports part
     */

    always @(posedge clk) begin
        if (reset) begin
            __port_a <= 0;
            __port_b <= 0;            
        end
        else if (port_select == STATE_PORT_A) __port_a <= sum;
        else if (port_select == STATE_PORT_B) __port_b <= sum;
    end

    assign port_a = __port_a;
    assign port_b = __port_b;

endmodule