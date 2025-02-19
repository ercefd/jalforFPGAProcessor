module processor;

reg clk;

reg [31:0] pc;

reg [7:0] datmem[0:63], mem[0:31];

wire [31:0] dataa,datab;

wire [31:0] out2,out3,out4,out6,out7; 

wire [31:0] sum, extad, adder1out, adder2out, sextad, readdata,jump_address;
wire [23:0] jadress;
wire [7:0] inst31_24;
wire [3:0] inst23_20, inst19_16, inst15_12, out1;
wire [15:0] inst15_0;
wire [31:0] instruc,dpack;
wire [2:0] gout;
wire [5:0] funct;
wire [5:0] shamt;
wire [27:0] jump_ext;

wire cout,zout,pcsrc,regdest,alusrc,memtoreg,regwrite,memread,
memwrite,branch,aluop1,aluop2,jump,jal,jalfor;


reg [31:0] registerfile [0:31];
integer i, c;
reg [31:0] t_mem; 

reg [31:0] jalforreg [0:5];  
// jalforreg[0] -> 1 if loop active, 0 otherwise
// jalforreg[1] -> nr
// jalforreg[2] -> necl
// jalforreg[3] -> neclleft
// jalforreg[4] -> jump address
// jalforreg[5] -> return address



// datamemory connections
always @(posedge clk)
begin
	if(memwrite)
	begin 
		datmem[sum[5:0]+3] <= datab[7:0];
		datmem[sum[5:0]+2] <= datab[15:8];
		datmem[sum[5:0]+1] <= datab[23:16];
		datmem[sum[5:0]] <= datab[31:24];
	end
end

//instruction memory
assign instruc = {mem[pc[4:0]],
		  mem[pc[4:0]+1],
                  mem[pc[4:0]+2],
 		  mem[pc[4:0]+3]};

assign inst31_24 = instruc[31:24];
assign inst23_20 = instruc[23:20];
assign inst19_16 = instruc[19:16];
assign inst15_12 = instruc[15:12];
assign inst15_0 = instruc[15:0];
assign jadress = instruc[23:0]; //jal address
assign shamt = instruc[11:6];
assign funct = instruc[5:0];

// registers
assign dataa = registerfile[inst23_20];
assign datab = registerfile[inst19_16];

//multiplexers
assign dpack={datmem[sum[5:0]],
	      datmem[sum[5:0]+1],
	      datmem[sum[5:0]+2],
              datmem[sum[5:0]+3]};


assign jump_address = jalfor ? {16'b0, instruc[15:0]} : {8'b0, jadress};

mult2_to_1_1  mult0(out0, zout, zoutbne, instruc[24]);
mult2_to_1_5  mult1(out1, instruc[19:16],instruc[15:12],regdest);
mult2_to_1_32 mult2(out2, datab, extad, alusrc);
mult2_to_1_32 mult3(out3, sum, dpack, memtoreg);
mult2_to_1_32 mult4(out4, adder1out,adder2out,pcsrc);
mult2_to_1_32 mult6(out6, out4,jump_address,jump);

always @(posedge clk)
begin
	registerfile[out1]= regwrite ? out3 : registerfile[out1];
end


always @(posedge clk)
begin
	registerfile[out1] = regwrite ? out3 : registerfile[out1];
	if (jalfor) begin
		jalforreg[5] <= adder1out;
		jalforreg[4] <= jump_address;

		jalforreg[1] <= instruc[23:20]; 
		jalforreg[2] <= instruc[19:16];
		jalforreg[3] <= instruc[19:16];

		jalforreg[0] <= 1;
	end
end

always @(posedge clk)
begin
	if (jalforreg[0] == 1) begin
		jalforreg[3] <= jalforreg[3] - 1;
		pc <= out6;
		if (jalforreg[3] == 1) begin
			jalforreg[1] <= jalforreg[1] - 1;
			jalforreg[3] <= jalforreg[2];

			if (jalforreg[1] == 1) begin
				pc <= jalforreg[5]; 
				jalforreg[0] <= 0;  
			end
			else begin
				pc <= jalforreg[4];
			end
		end
	end 
	else begin
	
		pc <= out6;
	end
end



alu32 alu1(sum, dataa, out2, zout, gout, shamt);
adder add1(pc,32'h4,adder1out);
adder add2(adder1out,sextad,adder2out);
/*
control(in, regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop1, aluop2);
*/
control cont(inst31_24,regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,
             aluop1,aluop2,jump,
             jalfor); 

signext sext(inst15_0,extad);

alucont acont(aluop1,aluop2,funct[3],funct[2], funct[1], funct[0],gout);

shift shift2(sextad,extad);

assign zoutbne = (~zout);
assign pcsrc = branch && out0;


initial
begin
	$readmemh("C:/Users/berce/OneDrive/Desktop/290201041_P3/initDataMemory.dat",datmem);
	$readmemh("C:/Users/berce/OneDrive/Desktop/290201041_P3/initIM2.dat",mem);
	$readmemh("C:/Users/berce/OneDrive/Desktop/290201041_P3/initRegisterMemory.dat",registerfile);

	for(i=0; i<31; i=i+1)
		$display("Instruction Memory[%0d]= %h  ",i,mem[i],
		         "Data Memory[%0d]= 0x%h   ",i,datmem[i], 
		         "Register[%0d]= 0x%h ",i,registerfile[i]);
    	c = 0;
    	t_mem = 0;

    	for (i = 0; i < 31; i = i + 1) begin
      		t_mem = {t_mem[23:0], mem[i]}; 
      		c = c + 1;
	      	if (c == 4) begin
			c = 0;
			$display("Instruction Memory[%0d]= 0x%h [%b %b %b %b %b %b]", 
		          i - 3, t_mem,
		          t_mem[31:24], t_mem[23:20], 
		          t_mem[19:16], t_mem[15:12], 
		          t_mem[11:6], t_mem[5:0]);
			t_mem = 0; 
	      	end
    	end
end

initial
begin
	pc=0;
	#500 $finish;
end

initial
begin
	clk=0;
	forever #20  clk=~clk;
end

initial 
begin
	$monitor($time," PC %h [%d]",pc,pc,"  SUM %h",sum,
	         "   INST %h [%b %b %b %b %b %b]",
	         instruc[31:0], inst31_24,inst23_20,inst19_16,inst15_12,
	         shamt, funct,
	         "   REGISTER %h %h %h %h %p DATA MEMORY %p",
	         registerfile[4],registerfile[5], registerfile[6],registerfile[1], 
	         registerfile,datmem );
end

endmodule