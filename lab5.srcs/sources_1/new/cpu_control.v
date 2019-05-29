`timescale 1ns / 1ps
/* CPU Control Unit
 * For Pipelined CPU
 * =================
 */


module cpu_control(
    input       [31:0]  i_ins,
    output reg          o_reg_dst,
    output reg          o_reg_write,
    output reg  [1:0]   o_alu_op,
    output reg          o_alu_src_b,
    output reg          o_mem_to_reg,
    output reg          o_mem_write,
    output reg          o_mem_read,
    output reg          o_branch,
    output reg          o_pc_j_write        // write pc on j
    );

    /* triger control based on instrction */
    always @(*) begin
        o_pc_j_write = 0;
        case (i_ins[31:26])         // Check the first 6 bit
            6'b000000: begin
                /* R-Type */
                o_reg_dst = 1;
                o_alu_op = 2'b10;           // For R-Type
                o_alu_src_b = 0;
                o_branch = 0;
                o_mem_read = 0;
                o_mem_write = 0;
                o_reg_write = 1;
                o_mem_to_reg = 0;
            end 
            6'b100011: begin
                /* lw */
                o_reg_dst = 0;
                o_alu_op = 2'b00;
                o_alu_src_b = 1;
                o_branch = 0;
                o_mem_read = 1;
                o_mem_write = 0;
                o_reg_write = 1;
                o_mem_to_reg = 1;
            end
            6'b101011: begin
                /* sw */
                o_reg_dst = 0;
                o_alu_op = 2'b00;
                o_alu_src_b = 1;
                o_branch = 0;
                o_mem_read = 0;
                o_mem_write = 1;
                o_reg_write = 0;
                o_mem_to_reg = 0;
            end 
            6'b000100: begin
                /* beq */
                o_reg_dst = 0;
                o_alu_op = 2'b01;
                o_alu_src_b = 0;
                o_branch = 1;
                o_mem_read = 0;
                o_mem_write = 0;
                o_reg_write = 0;
                o_mem_to_reg = 0;
            end
            6'b000101: begin
                /* bne */
                o_reg_dst = 0;
                o_alu_op = 2'b01;
                o_alu_src_b = 0;
                o_branch = 1;
                o_mem_read = 0;
                o_mem_write = 0;
                o_reg_write = 0;
                o_mem_to_reg = 0;
            end
            6'b001000, 6'b001100, 6'b001101, 6'b001110, 6'b001010: begin
                /* I-Type: addi, andi, ori, xori, slti */
                o_reg_dst = 0;
                o_alu_op = 2'b11;               // For I-Type
                o_alu_src_b = 1;                // Immediate
                o_branch = 0;
                o_mem_read = 0;
                o_mem_write = 0;
                o_reg_write = 1;
                o_mem_to_reg = 0;
            end
            6'b000010: begin
                /* j-Type */
                o_pc_j_write = 1;
                o_reg_dst = 0;
                o_alu_op = 2'b00;
                o_alu_src_b = 0;
                o_branch = 0;
                o_mem_read = 0;
                o_mem_write = 0;
                o_reg_write = 1;
                o_mem_to_reg = 0;
            end
            default: begin
                /* default */
                o_reg_dst = 0;
                o_alu_op = 2'b00;
                o_alu_src_b = 0;
                o_branch = 0;
                o_mem_read = 0;
                o_mem_write = 0;
                o_reg_write = 0;
                o_mem_to_reg = 0;
            end
        endcase
    end
endmodule
