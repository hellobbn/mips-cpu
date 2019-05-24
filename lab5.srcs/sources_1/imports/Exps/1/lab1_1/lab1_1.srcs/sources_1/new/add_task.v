`timescale 1ns / 1ps

// Task for an 6-bit adder

module add_task(
    input [31:0] opr_a,
    input [31:0] opr_b,
    output [3:0] flag,
    output [31:0] result
    );
    wire [31:0] p, g;
    wire [31:0] c;
    
    assign p = opr_a ^ opr_b;
    assign g = opr_a & opr_b;
    
    assign c[0] = g[0];
    assign c[1] = (p[1] & c[0]) | g[1];
    assign c[2] = (p[2] & c[1]) | g[2];
    assign c[3] = (p[3] & c[2]) | g[3];
    assign c[4] = (p[4] & c[3]) | g[4];
    assign c[5] = (p[5] & c[4]) | g[5];
    assign c[6] = (p[6] & c[5]) | g[6];
    assign c[7] = (p[7] & c[6]) | g[7];
    assign c[8] = (p[8] & c[7]) | g[8];
    assign c[9] = (p[9] & c[8]) | g[9];
    assign c[10] = (p[10] & c[9]) | g[10];
    assign c[11] = (p[11] & c[10]) | g[11];
    assign c[12] = (p[12] & c[11]) | g[12];
    assign c[13] = (p[13] & c[12]) | g[13];
    assign c[14] = (p[14] & c[13]) | g[14];
    assign c[15] = (p[15] & c[14]) | g[15];
    assign c[16] = (p[16] & c[15]) | g[16];
    assign c[17] = (p[17] & c[16]) | g[17];
    assign c[18] = (p[18] & c[17]) | g[18];
    assign c[19] = (p[19] & c[18]) | g[19];
    assign c[20] = (p[20] & c[19]) | g[20];
    assign c[21] = (p[21] & c[20]) | g[21];
    assign c[22] = (p[22] & c[21]) | g[22];
    assign c[23] = (p[23] & c[22]) | g[23];
    assign c[24] = (p[24] & c[23]) | g[24];
    assign c[25] = (p[25] & c[24]) | g[25];
    assign c[26] = (p[26] & c[25]) | g[26];
    assign c[27] = (p[27] & c[26]) | g[27];
    assign c[28] = (p[28] & c[27]) | g[28];
    assign c[29] = (p[29] & c[28]) | g[29];
    assign c[30] = (p[30] & c[29]) | g[30];
    assign c[31] = (p[31] & c[30]) | g[31];
    
    assign result[0] = p[0] ^ 0;
    assign result[1] = p[1] ^ c[0];
    assign result[2] = p[2] ^ c[1];
    assign result[3] = p[3] ^ c[2];
    assign result[4] = p[4] ^ c[3];
    assign result[5] = p[5] ^ c[4];
    assign result[6] = p[6] ^ c[5];
    assign result[7] = p[7] ^ c[6];
    assign result[8] = p[8] ^ c[7];
    assign result[9] = p[9] ^ c[8];
    assign result[10] = p[10] ^ c[9];
    assign result[11] = p[11] ^ c[10];
    assign result[12] = p[12] ^ c[11];
    assign result[13] = p[13] ^ c[12];
    assign result[14] = p[14] ^ c[13];
    assign result[15] = p[15] ^ c[14];
    assign result[16] = p[16] ^ c[15];
    assign result[17] = p[17] ^ c[16];
    assign result[18] = p[18] ^ c[17];
    assign result[19] = p[19] ^ c[18];
    assign result[20] = p[20] ^ c[19];
    assign result[21] = p[21] ^ c[20];
    assign result[22] = p[22] ^ c[21];
    assign result[23] = p[23] ^ c[22];
    assign result[24] = p[24] ^ c[23];
    assign result[25] = p[25] ^ c[24];
    assign result[26] = p[26] ^ c[25];
    assign result[27] = p[27] ^ c[26];
    assign result[28] = p[28] ^ c[27];
    assign result[29] = p[29] ^ c[28];
    assign result[30] = p[30] ^ c[29];
    assign result[31] = p[31] ^ c[30];


    assign flag[2] = c[30] ^ c[31];                 // V Position
    assign flag[1] = result[31];                    // S Position
    assign flag[0] = c[31];                         // CF Position
    assign flag[3] = ~(|result);                    // Z Position
    
endmodule
