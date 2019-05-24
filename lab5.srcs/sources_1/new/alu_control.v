`timescale 1ns / 1ps

/* ALU Control Unit */

module alu_control(
    input       [5:0]   i_ins,
    input       [1:0]   i_alu_op,
    input       [5:0]   i_i_tp,     // FOr I Type
    output  reg [2:0]   o_alu_op 
    );

    always @(*) begin
        o_alu_op = 3'b000;
        if(i_alu_op == 2'b00) begin
            o_alu_op = 3'b000;
        end
        else if(i_alu_op == 2'b01) begin
            o_alu_op = 3'b001;
        end
        else if(i_alu_op == 2'b10) begin
            /* Check i_ins */
            if(i_ins == 6'b100000) begin            // add
                o_alu_op = 3'b000;
            end
            else if(i_ins == 6'b100010) begin       // sub
                o_alu_op = 3'b001;
            end
            else if(i_ins == 6'b100100) begin       // and
                o_alu_op = 3'b010;
            end
            else if(i_ins == 6'b100101) begin       // or
                o_alu_op = 3'b011;
            end
            else if(i_ins == 6'b100110) begin       // xor
                o_alu_op = 3'b101;
            end
            else if(i_ins == 6'b100111) begin       // nor
                o_alu_op = 3'b110;
            end
            else if(i_ins == 6'b101010) begin       // slt
                o_alu_op = 3'b111;
            end
        end
        else begin
            if(i_i_tp == 6'b001000) begin
                o_alu_op = 3'b000;                  // addi
            end
            else if(i_i_tp == 6'b001100) begin
                o_alu_op = 3'b010;                  // andi
            end
            else if(i_i_tp == 6'b001101) begin
                o_alu_op = 3'b011;                  // ori
            end
            else if(i_i_tp == 6'b001110) begin
                o_alu_op = 3'b101;                  // xori
            end
            else if(i_i_tp == 6'b001010) begin
                o_alu_op = 3'b111;                  // slti
            end
        end
    end
endmodule
