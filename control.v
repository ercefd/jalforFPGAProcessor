module control(in, regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop1, aluop2, jump,jalfor);

input [7:0] in;
output regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop1, aluop2, jump, jalfor;

wire rtype, lw, sw, beq, bne, addi, j, jf;

assign rtype = (~in[7]) & (~in[6]) & in[5] & (~in[4]) & in[3] & (~in[2]) & (~in[1]) & in[0]; 		 // 00101001 = 041
assign lw    = (~in[7]) & (~in[6]) & in[5] & (~in[4]) & in[3] & (~in[2]) & in[1] & (~in[0]);         // 00101010 = 042
assign sw    = (~in[7]) & (~in[6]) & in[5] & (~in[4]) & in[3] & (~in[2]) & in[1] & in[0];            // 00101011 = 043
assign beq   = (~in[7]) & (~in[6]) & in[5] & (~in[4]) & in[3] & in[2] & (~in[1]) & (~in[0]);         // 00101100 = 044
assign bne   = (~in[7]) & (~in[6]) & in[5] & (~in[4]) & in[3] & in[2] & (~in[1]) & in[0];            // 00101101 = 045
assign addi  = (~in[7]) & (~in[6]) & in[5] & (~in[4]) & in[3] & in[2] & in[1] & (~in[0]);            // 00101110 = 046
assign j     = (~in[7]) & (~in[6]) & in[5] & (~in[4]) & in[3] & in[2] & in[1] & in[0];               // 00101111 = 047
assign jf    = (~in[7]) & (~in[6]) & in[5] & in[4] & (~in[3]) & (~in[2]) & (~in[1]) & (~in[0]);      // 00110000 = 048

assign regdest = rtype;
assign alusrc = (lw | sw | addi);
assign memtoreg = lw;
assign regwrite = (rtype | lw | addi | jf);
assign memread = lw;
assign memwrite = sw;
assign branch = (beq | bne);
assign aluop1 = rtype;
assign aluop2 = (beq | bne);
assign jump = j | jf;
assign jalfor = jf;

endmodule