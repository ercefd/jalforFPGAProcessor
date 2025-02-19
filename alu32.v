module alu32(alu_out, a, b, zout, alu_control, shamt);
output reg [31:0] alu_out;
input [31:0] a,b;
input [5:0] shamt;
input [2:0] alu_control;

//reg [31:0] less;
output zout;
reg zout;

always @(a or b or alu_control)
begin
	case(alu_control)
	3'b000: alu_out = a & b; // and

	3'b001: alu_out = a | b; // or

	3'b010: alu_out = a + b; // add

	3'b011: alu_out = ~(a | b); // nor

	3'b100: alu_out = b << shamt; //sll

	3'b101: alu_out = b >> shamt; //srl

	3'b110: alu_out = a-b; //sub
		
	default: alu_out=31'bx;
	endcase
zout=~(|alu_out);
end
endmodule