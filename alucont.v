module alucont(aluop0,aluop1,f3,f2,f1,f0,gout);
input aluop0,aluop1,f3,f2,f1,f0;
output [2:0] gout;
reg [2:0] gout;

always @(aluop0 or aluop1 or f3 or f2 or f1 or f0)
begin
	if(~(aluop0|aluop1))
		gout=3'b010; //add
	if(aluop1)
		gout=3'b110; //sub
	if(aluop0)
	begin
		if(~(f3 | f2 | f1 | f0))
			gout=3'b000; //and
		if (~(f3|f2|f1|f0))
			gout=3'b010; //add
		else if (f2 & ~(f1) & ~(f0))
			gout=3'b110; //sub
		else if (f2 & ~(f1) & f0)
			gout=3'b001; //or
		else if (~(f2) & f1 &  ~(f0))
			gout = 3'b101; //srl
		else if (~(f2) & ~(f1) & f0)
			gout = 3'b100; //sll
		else if (f1 & f0)
			gout = 3'b011; //nor		

	end			

end
endmodule

