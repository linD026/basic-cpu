module counters(
    input clk,
    input reset,
    output [3:0] out
);

    reg cp1, cp2;
    reg [3:0] ps, ns;
    reg [3:0] counter1, counter2;

    /* for the purpose of problem, generally we can
    * just output the result from the two counters.
    */
    reg [3:0] w; 

    always @(posedge clk) begin
        if (reset) ps <= 0;
        else ps <= ns;
    end

    /* two counters
    */

    always @(posedge clk) begin
        if (reset) counter1 <= 4'b0000;
        else if (cp1) counter1 <= counter1 + 1;
    end

    always @(posedge clk) begin
        if (reset) counter2 <= 4'b0000;
        else if (cp2) counter2 <= counter2 + 1;
    end

    /* controller and adder
    */

    always @(*) begin
        ns = 0;
        cp1 = 0;
        cp2 = 0;
        case (ps)
        0: begin
            cp1 = 1;
            cp2 = 1;
            ns = 1;
        end
        1: begin
            cp1 = 1;
            cp2 = 1;
            ns = 2;
        end
        2: begin
            cp1 = 1;
            cp2 = 1;
            ns = 3;
        end
        3: begin
            cp1 = 1;
            cp2 = 1;
            ns = 4;
        end
        4: begin
            /* cp1 stop */
            cp2 = 1;
            ns = 5;
        end
        5: begin
            cp2 = 1;
            ns = 6;
        end
        6: begin
            cp2 = 1;
            ns = 7;
        end
        7: begin
            cp2 = 1;
            ns = 8;
        end
        8: begin
            cp2 = 1;
            ns = 9;
        end
        9: begin
            w <= counter1 + counter2;
            /* To make the debug more easily, stay at this statement. */
            ns = 9;
        end
        endcase
    end

    assign out = w;

endmodule