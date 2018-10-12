//------------------------------------------------------------------------------
// Test harness validates hw4testbench by connecting it to various functional 
// or broken register files, and verifying that it correctly identifies each
//------------------------------------------------------------------------------

`include "regfile.v"

module hw4testbenchharness();

  wire[31:0]	ReadData1;	// Data from first register read
  wire[31:0]	ReadData2;	// Data from second register read
  wire[31:0]	WriteData;	// Data to write to register
  wire[4:0]	ReadRegister1;	// Address of first register to read
  wire[4:0]	ReadRegister2;	// Address of second register to read
  wire[4:0]	WriteRegister;  // Address of register to write
  wire		RegWrite;	// Enable writing of register when High
  wire		Clk;		// Clock (Positive Edge Triggered)

  reg		begintest;	// Set High to begin testing register file
  wire  	endtest;    	// Set High to signal test completion 
  wire		dutpassed;	// Indicates whether register file passed tests

  // Instantiate the register file being tested.  DUT = Device Under Test
  regfile DUT
  (
    .ReadData1(ReadData1),
    .ReadData2(ReadData2),
    .WriteData(WriteData),
    .ReadRegister1(ReadRegister1),
    .ReadRegister2(ReadRegister2),
    .WriteRegister(WriteRegister),
    .RegWrite(RegWrite),
    .Clk(Clk)
  );

  // Instantiate test bench to test the DUT
  hw4testbench tester
  (
    .begintest(begintest),
    .endtest(endtest), 
    .dutpassed(dutpassed),
    .ReadData1(ReadData1),
    .ReadData2(ReadData2),
    .WriteData(WriteData), 
    .ReadRegister1(ReadRegister1), 
    .ReadRegister2(ReadRegister2),
    .WriteRegister(WriteRegister),
    .RegWrite(RegWrite), 
    .Clk(Clk)
  );

  // Test harness asserts 'begintest' for 1000 time steps, starting at time 10
  initial begin
    begintest=0;
    #10;
    begintest=1;
    #1000;
  end

  // Display test results ('dutpassed' signal) once 'endtest' goes high
  always @(posedge endtest) begin
    $display("DUT passed?: %b", dutpassed);
  end

endmodule


//------------------------------------------------------------------------------
// Your HW4 test bench
//   Generates signals to drive register file and passes them back up one
//   layer to the test harness. This lets us plug in various working and
//   broken register files to test.
//
//   Once 'begintest' is asserted, begin testing the register file.
//   Once your test is conclusive, set 'dutpassed' appropriately and then
//   raise 'endtest'.
//------------------------------------------------------------------------------

module hw4testbench
(
// Test bench driver signal connections
input	   		begintest,	// Triggers start of testing
output reg 		endtest,	// Raise once test completes
output reg 		dutpassed,	// Signal test result

// Register File DUT connections
input[31:0]		ReadData1,
input[31:0]		ReadData2,
output reg[31:0]	WriteData,
output reg[4:0]		ReadRegister1,
output reg[4:0]		ReadRegister2,
output reg[4:0]		WriteRegister,
output reg		RegWrite,
output reg		Clk
);

  // Initialize register driver signals
  initial begin
    WriteData=32'd0;
    ReadRegister1=5'd0;
    ReadRegister2=5'd0;
    WriteRegister=5'd0;
    RegWrite=0;
    Clk=0;
  end

  // Once 'begintest' is asserted, start running test cases
  always @(posedge begintest) begin
    endtest = 0;
    dutpassed = 1;
    #10

  // Test Case 1: 
  //   Write '42' to register 2, verify with Read Ports 1 and 2
  //   (Passes because example register file is hardwired to return 42)
  WriteRegister = 5'd2;
  WriteData = 32'd42;
  RegWrite = 1;
  ReadRegister1 = 5'd2;
  ReadRegister2 = 5'd2;
  #5 Clk=1; #5 Clk=0;	// Generate single clock pulse

  // Verify expectations and report test result
  if((ReadData1 !== 42) || (ReadData2 !== 42)) begin
    dutpassed = 0;	// Set to 'false' on failure
    $display("Test Case 1 Failed");
  end

  // Test Case 2: 
  //   Write '15' to register 2, verify with Read Ports 1 and 2
  //   (Fails with example register file, but should pass with yours)
  WriteRegister = 5'd2;
  WriteData = 32'd15;
  RegWrite = 1;
  ReadRegister1 = 5'd2;
  ReadRegister2 = 5'd2;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 !== 15) || (ReadData2 !== 15)) begin
    dutpassed = 0;
    $display("Test Case 2 Failed");
  end

  // Test Case 3: 
  //   Write '15' to register 0, read with Read Port 1
  //   Verifies that register zero is always 0
  WriteRegister = 5'd0;
  WriteData = 32'd15;
  RegWrite = 1;
  ReadRegister1 = 5'd0;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 !== 0)) begin
    dutpassed = 0;
    $display("Test Case 3 Failed");
  end

  // Test Case 4: 
  //   Write '15' to register 3, then try to write 5 with RegWrite 0, verify with Read Port 1
  //   Verifies that the write ort only writes when RegWrite is 1
  WriteRegister = 5'd3;
  WriteData = 32'd15;
  RegWrite =1;
  ReadRegister1 = 5'd3;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd3;
  WriteData = 32'd5;
  RegWrite =0;
  ReadRegister1 = 5'd3;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 == 5)) begin
    dutpassed = 0;
    $display("Test Case 4 Failed");
  end

  // Test Case 5: 
  //   Write '15' to register 2, verify with Read Ports 1
  //   Write '5' to register 3, verify with Read Ports 2
  //   Verifies that only the correct ports are written to
  WriteRegister = 5'd2;
  WriteData = 32'd15;
  RegWrite = 1;
  ReadRegister1 = 5'd2;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd3;
  WriteData = 32'd5;
  RegWrite = 1;
  ReadRegister2 = 5'd3;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 !== 15) || (ReadData2 !== 5)) begin
    dutpassed = 0;
    $display("Test Case 5 Failed");
  end

  // Test Case 6: 
  //   Write port number to each port, then read from the ports
  //   Verifies that all ports are functional
  WriteRegister = 5'd0;
  WriteData = 32'd0;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd1;
  WriteData = 32'd1;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd2;
  WriteData = 32'd2;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd3;
  WriteData = 32'd3;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd4;
  WriteData = 32'd4;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd5;
  WriteData = 32'd5;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd6;
  WriteData = 32'd6;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd7;
  WriteData = 32'd7;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd8;
  WriteData = 32'd8;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd9;
  WriteData = 32'd9;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd10;
  WriteData = 32'd10;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd11;
  WriteData = 32'd11;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd12;
  WriteData = 32'd12;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd13;
  WriteData = 32'd13;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd14;
  WriteData = 32'd14;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd15;
  WriteData = 32'd15;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd16;
  WriteData = 32'd16;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd17;
  WriteData = 32'd17;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd18;
  WriteData = 32'd18;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd19;
  WriteData = 32'd19;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd20;
  WriteData = 32'd20;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd21;
  WriteData = 32'd21;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd22;
  WriteData = 32'd22;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd23;
  WriteData = 32'd23;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd24;
  WriteData = 32'd24;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd25;
  WriteData = 32'd25;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd26;
  WriteData = 32'd26;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd27;
  WriteData = 32'd27;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd28;
  WriteData = 32'd28;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd29;
  WriteData = 32'd29;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd30;
  WriteData = 32'd30;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd31;
  WriteData = 32'd31;
  RegWrite = 1;
  #5 Clk=1; #5 Clk=0;

  ReadRegister1 = 5'd0;
  ReadRegister2 = 5'd1;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 !== 0) || (ReadData2 !== 1)) begin
    dutpassed = 0;
    $display("Test Case 6 Failed");
  end

  ReadRegister1 = 5'd2;
  ReadRegister2 = 5'd3;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 !== 2) || (ReadData2 !== 3)) begin
    dutpassed = 0;
    $display("Test Case 6 Failed");
  end

  ReadRegister1 = 5'd4;
  ReadRegister2 = 5'd5;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 !== 4) || (ReadData2 !== 5)) begin
    dutpassed = 0;
    $display("Test Case 6 Failed");
  end

  ReadRegister1 = 5'd6;
  ReadRegister2 = 5'd7;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 !== 6) || (ReadData2 !== 7)) begin
    dutpassed = 0;
    $display("Test Case 6 Failed");
  end

  ReadRegister1 = 5'd8;
  ReadRegister2 = 5'd9;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 !== 8) || (ReadData2 !== 9)) begin
    dutpassed = 0;
    $display("Test Case 6 Failed");
  end

  ReadRegister1 = 5'd10;
  ReadRegister2 = 5'd11;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 !== 10) || (ReadData2 !== 11)) begin
    dutpassed = 0;
    $display("Test Case 6 Failed");
  end

  ReadRegister1 = 5'd12;
  ReadRegister2 = 5'd13;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 !== 12) || (ReadData2 !== 13)) begin
    dutpassed = 0;
    $display("Test Case 6 Failed");
  end

  ReadRegister1 = 5'd14;
  ReadRegister2 = 5'd15;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 !== 14) || (ReadData2 !== 15)) begin
    dutpassed = 0;
    $display("Test Case 6 Failed");
  end

  ReadRegister1 = 5'd16;
  ReadRegister2 = 5'd17;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 !== 16) || (ReadData2 !== 17)) begin
    dutpassed = 0;
    $display("Test Case 6 Failed");
  end

  ReadRegister1 = 5'd18;
  ReadRegister2 = 5'd19;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 !== 18) || (ReadData2 !== 19)) begin
    dutpassed = 0;
    $display("Test Case 6 Failed");
  end

  ReadRegister1 = 5'd20;
  ReadRegister2 = 5'd21;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 !== 20) || (ReadData2 !== 21)) begin
    dutpassed = 0;
    $display("Test Case 6 Failed");
  end

  ReadRegister1 = 5'd22;
  ReadRegister2 = 5'd23;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 !== 22) || (ReadData2 !== 23)) begin
    dutpassed = 0;
    $display("Test Case 6 Failed");
  end

  ReadRegister1 = 5'd24;
  ReadRegister2 = 5'd25;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 !== 24) || (ReadData2 !== 25)) begin
    dutpassed = 0;
    $display("Test Case 6 Failed");
  end

  ReadRegister1 = 5'd26;
  ReadRegister2 = 5'd27;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 !== 26) || (ReadData2 !== 27)) begin
    dutpassed = 0;
    $display("Test Case 6 Failed");
  end

  ReadRegister1 = 5'd28;
  ReadRegister2 = 5'd29;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 !== 28) || (ReadData2 !== 29)) begin
    dutpassed = 0;
    $display("Test Case 6 Failed");
  end

  ReadRegister1 = 5'd30;
  ReadRegister2 = 5'd31;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 !== 30) || (ReadData2 !== 31)) begin
    dutpassed = 0;
    $display("Test Case 6 Failed");
  end

  // Test Case 7: 
  //   Write '0xFFFFFFFF' to register 1, read with Read Port 1
  //   Verifies that the registers can handle longer numbers
  WriteRegister = 5'd1;
  WriteData = 32'hFFFFFFFF;
  RegWrite = 1;
  ReadRegister1 = 5'd1;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 !== 32'hFFFFFFFF)) begin
    dutpassed = 0;
    $display("Test Case 7 Failed");
  end

  // All done!  Wait a moment and signal test completion.
  #5
  endtest = 1;

end

endmodule
