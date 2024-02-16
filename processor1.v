module processor(clk1,clk2,done );
   input clk1,clk2;
   output reg done;

   reg [31:0]pc,if_id_ir,if_id_npc;
   reg [31:0]id_ex_ir,id_ex_npc,id_ex_a,id_ex_b,id_ex_imm;
   reg [2:0]id_ex_type,ex_mem_type,mem_wb_type;
reg [31:0] ex_mem_ir,ex_mem_aluout,ex_mem_b;
reg  ex_mem_cond;
reg [31:0]mem_wb_ir,mem_wb_aluout,mem_wb_lmd;

reg [31:0]Reg [0:31];
reg [31:0]Mem [0:1023];

parameter ADD=6'b000000,SUB=6'b000001,AND=6'b000010,OR=6'b000011,SLT=6'b000100,MUL=6'b000101,HLT=6'b111111,LW=6'b001000;
parameter SW=6'b001001,ADDI=6'b001010,SUBI=6'b001010,SLTI=6'b001100,BENQ=6'b001110,BEQZ=6'b001110;

parameter RR_alu=3'b000,Rm_alu=3'b001,load=3'b010,store=3'b011,branch=3'b100,halt=3'b101;

reg halted,taken_branch;

always @(posedge clk1)begin
if(halted==0)

 begin
   if(((ex_mem_ir[31:26]==BEQZ)&&(ex_mem_cond ==1))||((ex_mem_ir[31:26]==BENQ)&&(ex_mem_cond==0)))
  begin
 if_id_ir     <= #2 Mem[ex_mem_aluout];
 taken_branch <= #2 1'b1;
 if_id_npc    <= #2 ex_mem_aluout+1;
 pc           <= #2 ex_mem_aluout+1;
end
else
        begin
           if_id_ir  <= #2 Mem[pc];
           if_id_npc <= #2 pc+1;
 pc        <= #2 pc+1;
end end
else begin
done<=1;
end
 
 end
 
always @(posedge clk2)begin

if(halted == 0)
begin
if(if_id_ir[25:21] == 5'b00000)
 begin
   id_ex_a <= 0;
 end
else
 begin
  id_ex_a <= #2 Reg[if_id_ir[25:21]];   //rs
 end
 
if(if_id_ir[20:16] == 5'b00000)
   begin
     id_ex_b <= 0;
end
       else
          begin
             id_ex_b <= #2 Reg [if_id_ir [20:16]];   //rt
end
id_ex_npc <= #2 if_id_npc;
id_ex_ir  <= #2 if_id_ir;
id_ex_imm <= #2 {{16{if_id_ir[15]}},{if_id_ir[15:0]}};

case(if_id_ir[31:26])

 ADD,SUB,AND,OR,SLT,MUL : id_ex_type <= #2 RR_alu;
 ADDI,SUBI,SLTI         : id_ex_type <= #2 Rm_alu;
 LW                     : id_ex_type <= #2 load;
 SW                     : id_ex_type <= #2 store;
 BENQ,BEQZ             : id_ex_type <= #2 branch;
 HLT                    : id_ex_type <= #2 halt;
 default                : id_ex_type <= #2 halt;
 
  endcase end
  else begin
done<=1;
end
end

  always@(posedge clk1)begin
     if(halted == 0)
       begin
         ex_mem_type  <= #2 id_ex_type;
         ex_mem_ir    <= #2 id_ex_ir;
taken_branch <= #2 0;

case (id_ex_type)
RR_alu: begin
          case (id_ex_ir[31:26])
ADD : ex_mem_aluout <= #2 id_ex_a + id_ex_b;
SUB : ex_mem_aluout <= #2 id_ex_a - id_ex_b;
AND : ex_mem_aluout <= #2 id_ex_a & id_ex_b;
OR  : ex_mem_aluout <= #2 id_ex_a | id_ex_b;
SLT : ex_mem_aluout <= #2 id_ex_a < id_ex_b;
MUL : ex_mem_aluout <= #2 id_ex_a * id_ex_b;
default : ex_mem_aluout <= #2 32'hxxxx;
 endcase
  end
  Rm_alu: begin
           case (id_ex_ir[31:26])
  ADDI : ex_mem_aluout    <= #2 id_ex_a + id_ex_imm;
SUBI : ex_mem_aluout    <= #2 id_ex_a - id_ex_imm;
SLTI : ex_mem_aluout    <= #2 id_ex_a < id_ex_imm;
default : ex_mem_aluout <= #2 32'hxxxxxxx;
endcase
end
load, store: begin
               ex_mem_aluout <= #2 id_ex_a + id_ex_imm;
ex_mem_b      <= #2 id_ex_b;
end

branch: begin
                    ex_mem_aluout <= #2 id_ex_npc + id_ex_imm;
 ex_mem_cond   <= #2 (id_ex_a == 0);  
 end
 endcase
 
  end
  else begin
done<=1;
end
end

always @(posedge clk2)begin
if(halted == 0)
  begin
 mem_wb_type <= ex_mem_type;
 mem_wb_ir <= #2 ex_mem_ir;
 
 case(ex_mem_type)
   RR_alu,Rm_alu : mem_wb_aluout <= #2 ex_mem_aluout;

load : mem_wb_lmd  <= #2 Mem[ex_mem_aluout];

store : if(taken_branch==0)
            Mem[ex_mem_aluout] <= #2 ex_mem_b;

endcase
 end
 else begin
done<=1;
end
 end
 
always @(posedge clk1)
    begin
  if(taken_branch==0)
 case(mem_wb_type)
                   RR_alu: Reg[mem_wb_ir[15:11]] <= #2 mem_wb_aluout;

Rm_alu: Reg[mem_wb_ir[20:16]] <= #2 mem_wb_aluout;

   load : Reg[mem_wb_ir[20:16]] <= #2 mem_wb_lmd;

halt : halted <= #2 1'b1;
endcase
end
endmodule
