module tb;
     
      // Inputs
reg clk1;
reg clk2;
wire done;


   integer i,k;
// Instantiate the Unit Under Test (UUT)
processor uut (
.clk1(clk1),
.clk2(clk2),
.done(done)

);

initial
 begin
 // Initialize Inputs
 clk1 = 0;
 clk2 = 0;

for(i=0;i<50;i=i+1)
  begin
    #5 clk1=1; #5 clk1=0;
    #5 clk2=1; #5 clk2=0;
  end
  end

initial
begin
for(k=0;k<31;k=k+1)
  uut.Reg[k]=k;
uut.Mem[0] = 32'h28010078;//b00101000000000010000000001111000;
uut.Mem[1] = 32'h0c631800;//b11000110001100011000000000000000;//false value
uut.Mem[2] = 32'h20220000;//b00100000001000100000000000000000;
uut.Mem[3] = 32'h0c631800;//b11000110001100011000000000000000;//false value
uut.Mem[4] = 32'h2842002d; //b00101000010000100000000000101101;
uut.Mem[5] = 32'h0c631800;//b11000110001100011000000000000000;//false value
uut.Mem[6] = 32'h24220001;//b00100100010000010000000000000001;
uut.Mem[7] = 32'hfc000000;//b11111100000000000000000000000000;
uut.Mem[120] = 85;
uut.halted = 0;
uut.pc = 0;
uut.taken_branch = 0;

#280;
$display("Mem[120] : %4d \n Mem[121] : %4d" , uut.Mem[120],uut.Mem[121]);
end
/*#500
for (k=0;k<6;k=k+1)
begin
 $display("Mem[120] : %4d \n Mem[121] : %4d" , uut.Mem[120],uut.Mem[121]);
end*/
endmodule