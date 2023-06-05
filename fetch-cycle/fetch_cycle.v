module ROM(
output [13:0] Rom_data_out, 
input [10:0] Rom_addr_in
);
    reg   [13:0] data;
    always @(*)
        begin
            case (Rom_addr_in)
				11'h0:	data = 14'h3044;		//MOVLW
				11'h1:	data = 14'h3E01;		//ADDLW
				11'h2:	data = 14'h3E02;		//ADDLW
				11'h3:	data = 14'h3E03;		//ADDLW
				11'h4:	data = 14'h3E04;		//ADDLW
				11'h5:	data = 14'h3E05;		//ADDLW
				11'h6:	data = 14'h3E06;		//ADDLW
				11'h7:	data = 14'h3E07;		//ADDLW
				default:data = 14'hX;
            endcase
        end
     assign Rom_data_out = data;

endmodule

module fetch_cycle (
    input reset,
    input clk,
    output [13:0] ir
);

    parameter T0_INIT = 0;
    parameter T1 = 1;
    parameter T2 = 2;
    parameter T3 = 3;    

    reg load_pc, load_mar, load_ir;
    wire [10:0] pc_next;
    reg [10:0] pc_q, mar_q;
    wire [13:0] rom_out;
    reg [13:0] ir_q;
    reg [4:0] ps, ns;

    always @(posedge clk) begin
      if (reset) ps <= 0;
      else ps <= ns;
    end

    /* Adder - pc_next = pc_q + 1;
     */
    assign pc_next = pc_q + 1;

    /* Program Counter - update the pc_q each 3 clk
     */
    always @(posedge clk) begin
        if (reset) pc_q <= 0;
        else if (load_pc) pc_q <= pc_next; 
    end

    /* Memory Address Register - MAR
     */
    always @(posedge clk) begin
        if (load_mar) mar_q <= pc_q;
    end

    /* ROM
     */
    ROM __rom(
        .Rom_addr_in(mar_q),
        .Rom_data_out(rom_out)
    );

    /* Instruction Register - IR
     */
    always @(posedge clk) begin
        if (reset) ir_q <= 0;
        else if (load_ir) ir_q <= rom_out;
    end
    assign ir = ir_q;

    /* fetch cycle controller
     */
    always @(*) begin
      load_pc = 0;
      load_mar = 0;
      load_ir = 0;
      ns = T0_INIT;
      case (ps)
          T0_INIT: ns = T1;
          T1: begin
              load_mar = 1;
              ns = T2;
          end
          T2: begin
              load_pc = 1;
              ns = T3;
          end
          T3: begin
              load_ir = 1;
              ns = T1;
          end
      endcase
    end
endmodule
