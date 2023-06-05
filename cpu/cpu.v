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
				11'h2:	data = 14'h3802;		//IORLW
				11'h3:	data = 14'h39FE;		//ANDLW
				11'h4:	data = 14'h3C47;		//SUBLW
				11'h5:	data = 14'h3A55;		//XORLW
				11'h6:	data = 14'h3AAA;		//XORLW
				default:data = 14'hX;
            endcase
        end
     assign Rom_data_out = data;

endmodule

module cpu (
    input reset,
    input clk,
    output [7:0] w_q_out
);

    parameter T0_INIT = 0;
    parameter T1 = 1;
    parameter T2 = 2;
    parameter T3 = 3;    
    parameter T4 = 4;
    parameter T5 = 5;
    parameter T6 = 6;

    reg load_pc, load_mar, load_ir, load_w;
    wire [10:0] pc_next;
    reg [10:0] pc_q, mar_q;
    wire [13:0] rom_out;
    reg [13:0] ir_q;
    reg [4:0] ps, ns;
    reg [7:0] w_q;
    reg [7:0] alu_q;
    reg [3:0] op;
    wire ADDLW, SUBLW, ANDLW, IORLW, XORLW, MOVLW;

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
    
    parameter OP_ADDLW = 0;
    parameter OP_SUBLW = 1;
    parameter OP_ANDLW = 2;
    parameter OP_IORLW = 3;
    parameter OP_XORLW = 4;
    parameter OP_MOVLW = 5;
    
    /* ALU
     */
    always @(*) begin
      case (op)
      OP_ADDLW: alu_q = ir_q[7:0] + w_q;
      OP_SUBLW: alu_q = ir_q[7:0] - w_q;
      OP_ANDLW: alu_q = ir_q[7:0] & w_q;
      OP_IORLW: alu_q = ir_q[7:0] | w_q;
      OP_XORLW: alu_q = ir_q[7:0] ^ w_q;
      OP_MOVLW: alu_q = ir_q[7:0];
      default: alu_q = 8'bx;
      endcase
    end

    /* Accumulator - ALU register
     */
    always @(posedge clk) begin
        if (reset) w_q <= 0;
        if (load_w) w_q <= alu_q;
    end

    /* Instruction set select
     */
    assign MOVLW = (ir_q[13:8] == 6'b11_0000);
    assign ADDLW = (ir_q[13:8] == 6'b11_1110);
    assign SUBLW = (ir_q[13:8] == 6'b11_1100);
    assign ANDLW = (ir_q[13:8] == 6'b11_1001);
    assign IORLW = (ir_q[13:8] == 6'b11_1000);
    assign XORLW = (ir_q[13:8] == 6'b11_1010);

    /* controller
     */
    always @(*) begin
      load_pc = 0;
      load_mar = 0;
      load_ir = 0;
      load_w = 0;
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
              ns = T4;
          end
          T4: begin
              if (MOVLW) begin
                  load_w = 1;
                  op = OP_MOVLW;
              end
              if (ADDLW) begin
                  load_w = 1;
                  op = OP_ADDLW;
              end
              if (SUBLW) begin
                  load_w = 1;
                  op = OP_SUBLW;
              end
              if (ANDLW) begin
                  load_w = 1;
                  op = OP_ANDLW;
              end
              if (IORLW) begin
                  load_w = 1;
                  op = OP_IORLW;
              end
              if (XORLW) begin
                  load_w = 1;
                  op = OP_XORLW;
              end
              ns = T5;
          end
          T5: begin
              ns = T6;
          end
          T6: begin
              ns = T1;
          end
      endcase
    end
    
    /* Output
     */
     assign w_q_out = w_q;
endmodule
