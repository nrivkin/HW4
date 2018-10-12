//------------------------------------------------------------------------------
// MIPS register file
//   width: 32 bits
//   depth: 32 words (reg[0] is static zero register)
//   2 asynchronous read ports
//   1 synchronous, positive edge triggered write port
//------------------------------------------------------------------------------

module regfile
(
output[31:0]	ReadData1,	// Contents of first register read
output[31:0]	ReadData2,	// Contents of second register read
input[31:0]	WriteData,	// Contents to write to register
input[4:0]	ReadRegister1,	// Address of first register to read
input[4:0]	ReadRegister2,	// Address of second register to read
input[4:0]	WriteRegister,	// Address of register to write
input		RegWrite,	// Enable writing of register when High
input		Clk		// Clock (Positive Edge Triggered)
);

    // These two lines are clearly wrong.  They are included to showcase how the 
    // test harness works. Delete them after you understand the testing process, 
    // and replace them with your actual code.
    //assign ReadData1 = 42;
    //assign ReadData2 = 42;

    // instantiate modules
	// wires
	wire[31:0] regOut [31:0];
	wire decode;
	wire[31:0] decOut;
	// decoder
	decoder1to32 decoder (decOut, RegWrite, WriteRegister);
	// 0 register
	register32zero regzero(regOut[0], WriteData, decOut[0], Clk);
	// registers
	register32 reg1 (regOut[1], WriteData, decOut[1], Clk);
	register32 reg2 (regOut[2], WriteData, decOut[2], Clk);
	register32 reg3 (regOut[3], WriteData, decOut[3], Clk);
	register32 reg4 (regOut[4], WriteData, decOut[4], Clk);
	register32 reg5 (regOut[5], WriteData, decOut[5], Clk);
	register32 reg6 (regOut[6], WriteData, decOut[6], Clk);
	register32 reg7 (regOut[7], WriteData, decOut[7], Clk);
	register32 reg8 (regOut[8], WriteData, decOut[8], Clk);
	register32 reg9 (regOut[9], WriteData, decOut[9], Clk);
	register32 reg10 (regOut[10], WriteData, decOut[10], Clk);
	register32 reg11 (regOut[11], WriteData, decOut[11], Clk);
	register32 reg12 (regOut[12], WriteData, decOut[12], Clk);
	register32 reg13 (regOut[13], WriteData, decOut[13], Clk);
	register32 reg14 (regOut[14], WriteData, decOut[14], Clk);
	register32 reg15 (regOut[15], WriteData, decOut[15], Clk);
	register32 reg16 (regOut[16], WriteData, decOut[16], Clk);
	register32 reg17 (regOut[17], WriteData, decOut[17], Clk);
	register32 reg18 (regOut[18], WriteData, decOut[18], Clk);
	register32 reg19 (regOut[19], WriteData, decOut[19], Clk);
	register32 reg20 (regOut[20], WriteData, decOut[20], Clk);
	register32 reg21 (regOut[21], WriteData, decOut[21], Clk);
	register32 reg22 (regOut[22], WriteData, decOut[22], Clk);
	register32 reg23 (regOut[23], WriteData, decOut[23], Clk);
	register32 reg24 (regOut[24], WriteData, decOut[24], Clk);
	register32 reg25 (regOut[25], WriteData, decOut[25], Clk);
	register32 reg26 (regOut[26], WriteData, decOut[26], Clk);
	register32 reg27 (regOut[27], WriteData, decOut[27], Clk);
	register32 reg28 (regOut[28], WriteData, decOut[28], Clk);
	register32 reg29 (regOut[29], WriteData, decOut[29], Clk);
	register32 reg30 (regOut[30], WriteData, decOut[30], Clk);
	register32 reg31 (regOut[31], WriteData, decOut[31], Clk);
	// muxes
	mux32to1by32 mux1 (ReadData1, ReadRegister1,
	    regOut[0],
	    regOut[1],
	    regOut[2],
	    regOut[3],
	    regOut[4],
	    regOut[5],
	    regOut[6],
	    regOut[7],
	    regOut[8],
	    regOut[9],
	    regOut[10],
	    regOut[11],
	    regOut[12],
	    regOut[13],
	    regOut[14],
	    regOut[15],
	    regOut[16],
	    regOut[17],
	    regOut[18],
	    regOut[19],
	    regOut[20],
	    regOut[21],
	    regOut[22],
	    regOut[23],
	    regOut[24],
	    regOut[25],
	    regOut[26],
	    regOut[27],
	    regOut[28],
	    regOut[29],
	    regOut[30],
	    regOut[31]
	);
	mux32to1by32 mux2 (ReadData2, ReadRegister2,
	    regOut[0],
	    regOut[1],
	    regOut[2],
	    regOut[3],
	    regOut[4],
	    regOut[5],
	    regOut[6],
	    regOut[7],
	    regOut[8],
	    regOut[9],
	    regOut[10],
	    regOut[11],
	    regOut[12],
	    regOut[13],
	    regOut[14],
	    regOut[15],
	    regOut[16],
	    regOut[17],
	    regOut[18],
	    regOut[19],
	    regOut[20],
	    regOut[21],
	    regOut[22],
	    regOut[23],
	    regOut[24],
	    regOut[25],
	    regOut[26],
	    regOut[27],
	    regOut[28],
	    regOut[29],
	    regOut[30],
	    regOut[31]
	);
endmodule


module register32
#(parameter width = 32)
(
output reg[width-1:0] q,
input[width-1:0]      d,
input 		 wrenable,
input 		 clk
);
    always @(posedge clk) begin
        if (wrenable) begin
	    q[width-1:0] <= {d[width-1:0]};
	end
    end
endmodule


module register32zero
#(parameter width = 32)
(
output reg[width-1:0] q,
input[width-1:0]      d,
input 		 wrenable,
input 		 clk
);
    always @(posedge clk) begin
        if (wrenable) begin
	    q[width-1:0] <= 32'b0;
	end
    end
endmodule

module mux32to1by1
(
output      out,
input[4:0]  address,
input[31:0] inputs
);
    // Your code
    assign out = inputs[address[4:0]];
endmodule


module mux32to1by32
(
output[31:0]  out,
input[4:0]    address,
input[31:0]   input0, input1, input2, input3, input4, input5, input6, input7, input8,input9, input10, input11, input12, input13, input14, input15, input16, input17, input18, input19, input20, input21, input22, input23, input24, input25, input26, input27, input28, input29, input30, input31
);

  wire[31:0] mux[31:0];			// Create a 2D array of wires
  assign mux[0] = input0;		// Connect the sources of the array
  assign mux[1] = input1;		// Connect the sources of the array
  assign mux[2] = input2;		// Connect the sources of the array
  assign mux[3] = input3;		// Connect the sources of the array
  assign mux[4] = input4;		// Connect the sources of the array
  assign mux[5] = input5;		// Connect the sources of the array
  assign mux[6] = input6;		// Connect the sources of the array
  assign mux[7] = input7;		// Connect the sources of the array
  assign mux[8] = input8;		// Connect the sources of the array
  assign mux[9] = input9;		// Connect the sources of the array
  assign mux[10] = input10;		// Connect the sources of the array
  assign mux[11] = input11;		// Connect the sources of the array
  assign mux[12] = input12;		// Connect the sources of the array
  assign mux[13] = input13;		// Connect the sources of the array
  assign mux[14] = input14;		// Connect the sources of the array
  assign mux[15] = input15;		// Connect the sources of the array
  assign mux[16] = input16;		// Connect the sources of the array
  assign mux[17] = input17;		// Connect the sources of the array
  assign mux[18] = input18;		// Connect the sources of the array
  assign mux[19] = input19;		// Connect the sources of the array
  assign mux[20] = input20;		// Connect the sources of the array
  assign mux[21] = input21;		// Connect the sources of the array
  assign mux[22] = input22;		// Connect the sources of the array
  assign mux[23] = input23;		// Connect the sources of the array
  assign mux[24] = input24;		// Connect the sources of the array
  assign mux[25] = input25;		// Connect the sources of the array
  assign mux[26] = input26;		// Connect the sources of the array
  assign mux[27] = input27;		// Connect the sources of the array
  assign mux[28] = input28;		// Connect the sources of the array
  assign mux[29] = input29;		// Connect the sources of the array
  assign mux[30] = input30;		// Connect the sources of the array
  assign mux[31] = input31;		// Connect the sources of the array
  assign out = mux[address];	// Connect the output of the array
endmodule


module decoder1to32
(
output[31:0]  out,
input         enable,
input[4:0]    address
);
    assign out = enable<<address; 
endmodule
