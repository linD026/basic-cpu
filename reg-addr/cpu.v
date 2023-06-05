module ROM(Rom_data_out, Rom_addr_in);

//---------
    output [13:0] Rom_data_out;
    input [10:0] Rom_addr_in; 
//---------
    
    reg   [13:0] data;
    wire  [13:0] Rom_data_out;
    
    always @(Rom_addr_in)
        begin
            case (Rom_addr_in)
                10'h0 : data = 14'h01A5;
                10'h1 : data = 14'h0103;
                10'h2 : data = 14'h3006;
                10'h3 : data = 14'h07A5;
                10'h4 : data = 14'h3005;
                10'h5 : data = 14'h0725;
                10'h6 : data = 14'h3E02;
                10'h7 : data = 14'h05A5;
                10'h8 : data = 14'h03A5;
                10'h9 : data = 14'h09A5;
                10'ha : data = 14'h280A;
                10'hb : data = 14'h3400;
                10'hc : data = 14'h3400;
                default: data = 14'h0;   
            endcase
        end

     assign Rom_data_out = data;

endmodule


// Quartus II Verilog Template
// Single port RAM with single read/write address
module single_port_ram_128x8(
	data,
	addr,
	en,
	clk,
	q
);
	input [6:0] addr;
	input [7:0] data;
	input en, clk;
	output [7:0] q;
	
	// Declare the RAM variable
	//reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];
	reg [7:0] ram[127:0];
	
	// Variable to hold the registered read address
	//reg [6:0] addr_reg;
	
	always @ (posedge clk)
	begin
		// Write
		if (en)
			ram[addr] <= data;
		
			//addr_reg <= addr;
	end

	// Continuous assignment implies read returns NEW data.
	// This is the natural behavior of the TriMatrix memory
	// blocks in Single Port mode.  

	assign q = ram[addr];
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
    reg [10:0] pc_next;
    reg [10:0] pc_q, mar_q;
    wire [13:0] rom_out;
    reg [13:0] ir_q;
    reg [4:0] ps, ns;
    reg [7:0] w_q;
    reg [7:0] alu_q;
    reg [3:0] op;
    reg sel_pc, sel_alu, ram_en;
    reg [7:0] mux1_out;
    wire [7:0] ram_out;
    wire ADDLW, SUBLW, ANDLW, IORLW, XORLW, MOVLW;
    wire ADDWF, ANDWF, CLRF, CLRW, COMF, DECF, d;

    always @(posedge clk) begin
      if (reset) ps <= 0;
      else ps <= ns;
    end

    /* PC multpex
     */
    always @(*) begin
      case (sel_pc)
        0: pc_next = pc_q + 1;
        1: pc_next = ir_q[10:0];
        default: pc_next = 0;
      endcase
    end

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
    parameter OP_INC = 6;
    parameter OP_DEC = 7;
    parameter OP_CLEAN = 8;
    parameter OP_COM = 9;
    
    /* ALU
     */
    always @(*) begin
      case (op)
      OP_ADDLW: alu_q = mux1_out + w_q;
      OP_SUBLW: alu_q = mux1_out - w_q;
      OP_ANDLW: alu_q = mux1_out & w_q;
      OP_IORLW: alu_q = mux1_out | w_q;
      OP_XORLW: alu_q = mux1_out ^ w_q;
      OP_MOVLW: alu_q = mux1_out;
      OP_INC: alu_q = mux1_out + 1;
      OP_DEC: alu_q = mux1_out - 1;
      OP_CLEAN: alu_q = 0;
      OP_COM: alu_q = ~mux1_out;
      default: alu_q = 8'bx;
      endcase
    end

    /* Accumulator - ALU register
     */
    always @(posedge clk) begin
        if (reset) w_q <= 0;
        if (load_w) w_q <= alu_q;
    end

    /* ALU multpex
     */
    always @(*) begin
      case (sel_alu)
        0: mux1_out = ir_q[7:0];
        1: mux1_out = ram_out;
        default mux1_out = ir_q[7:0];
      endcase
    end

    /* RAM
     */
    single_port_ram_128x8 ram(
      	.data(alu_q[7:0]),
      	.addr(ir_q[6:0]),
      	.en(ram_en),
      	.clk(clk),
	     .q(ram_out)
    );

    /* Instruction set select
     */
    assign MOVLW = (ir_q[13:8] == 6'b11_0000);
    assign ADDLW = (ir_q[13:8] == 6'b11_1110);
    assign SUBLW = (ir_q[13:8] == 6'b11_1100);
    assign ANDLW = (ir_q[13:8] == 6'b11_1001);
    assign IORLW = (ir_q[13:8] == 6'b11_1000);
    assign XORLW = (ir_q[13:8] == 6'b11_1010);

    assign GOTO  = (ir_q[13:11] == 3'b10_1);
    assign ADDWF = (ir_q[13:8] == 6'b00_0111);
    assign ANDWF = (ir_q[13:8] == 6'b00_0101);
    assign CLRF  = (ir_q[13:8] == 6'b00_0001);
    assign CLRW  = (ir_q[13:8] == 6'b00_0001);
    assign COMF  = (ir_q[13:8] == 6'b00_1001);
    assign DECF  = (ir_q[13:8] == 6'b00_0011);
    // TODO INCF

    assign d = ir_q[7];
    
    /* controller
     */
    always @(*) begin
      load_pc = 0;
      load_mar = 0;
      load_ir = 0;
      load_w = 0;
      sel_alu = 0;
      sel_pc = 0;
      ram_en = 0;
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

              if (GOTO) begin
                  sel_pc = 1;
                  load_pc = 1;
              end
              if (ADDWF) begin
                  op = OP_ADDLW;
                  sel_alu = 1;
                  if (d == 0) load_w = 1;
                  else ram_en = 1;
              end
              if (ANDWF) begin
                  op = OP_ANDLW;
                  sel_alu = 1;
                  if (d == 0) load_w = 1;
                  else ram_en = 1;
              end
              if (CLRF) begin
                  op = OP_CLEAN;
                  ram_en = 1;
              end
              if (CLRW) begin
                  op = OP_CLEAN;
                  sel_alu = 1;
                  load_w = 1;
              end
              if (COMF) begin
                  op = OP_COM;
                  sel_alu = 1;
                  ram_en = 1;
              end
              if (DECF) begin
                  op = OP_DEC;
                  sel_alu = 1;
                  ram_en = 1;
              end
              // TODO INCF

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
