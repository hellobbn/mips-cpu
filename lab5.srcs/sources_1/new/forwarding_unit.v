`timescale 1ns / 1ps
/* MIPS Pipelined CPU
 * Fording Unit 
 * TODO: the situation where ID/EX is I-type has not been considered yet
 * TODO: the register destination can cover all rd / rt field in EX/MEM MEM/WB
 */


module forwarding_unit(
    /* R-Type */
    input               i_ex_mem_reg_write,         // RegWrite in EX/MEM
    input       [4:0]   i_ex_mem_reg_rd,            // Rd field in EX/MEM
    input       [4:0]   i_id_ex_reg_rs,             // Rs field in ID/EX
    input       [4:0]   i_id_ex_reg_rt,             // Rt field in ID/EX

    /* I-Type */
    input       [4:0]   i_ex_mem_reg_rt,
    input       [4:0]   i_mem_wb_reg_rt,

    /* Generic */
    input               i_mem_wb_reg_write,         // RegWrite in MEM/WB
    input       [4:0]   i_mem_wb_reg_rd,            // Rd field in MEM/WB
    input               i_mem_wb_is_i,
    input               i_ex_mem_is_i,

    output  reg [1:0]   o_forward_a,
    output  reg [1:0]   o_forward_b
    );

    always @(*) begin
        o_forward_a = 2'b00;
        o_forward_b = 2'b00;
        if(~i_ex_mem_is_i) begin
            if(i_ex_mem_reg_write & (i_ex_mem_reg_rd != 5'h0) & (i_ex_mem_reg_rt == i_id_ex_reg_rs)) begin
                o_forward_a = 2'b10;
            end
            if(i_ex_mem_reg_write & (i_ex_mem_reg_rd != 5'h0) & (i_ex_mem_reg_rt == i_id_ex_reg_rt)) begin
                o_forward_b = 2'b10;
            end
        end
        else begin
            if(i_ex_mem_reg_write & (i_ex_mem_reg_rt != 5'h0) & (i_ex_mem_reg_rt == i_id_ex_reg_rs)) begin
                o_forward_a = 2'b10;
            end
            if(i_ex_mem_reg_write & (i_ex_mem_reg_rt != 5'h0) & (i_ex_mem_reg_rt == i_id_ex_reg_rt)) begin
                o_forward_b = 2'b10;
            end            
        end

        if(~i_mem_wb_is_i) begin
            if(i_mem_wb_reg_write & (i_mem_wb_reg_rt != 5'h0) & (i_mem_wb_reg_rt == i_id_ex_reg_rs)
                & ~(i_ex_mem_reg_write & (i_ex_mem_reg_rt != 0) & (i_ex_mem_reg_rt == i_id_ex_reg_rs))) begin
                o_forward_a = 2'b01;
            end
            if(i_mem_wb_reg_write & (i_mem_wb_reg_rt != 5'h0) & (i_mem_wb_reg_rt == i_id_ex_reg_rt)
                & ~(i_ex_mem_reg_write & (i_ex_mem_reg_rt != 0) & (i_ex_mem_reg_rt == i_id_ex_reg_rt))) begin
                o_forward_b = 2'b01;
            end            
        end
        else begin
            if(i_mem_wb_reg_write & (i_mem_wb_reg_rt != 5'h0) 
            & (i_mem_wb_reg_rt == i_id_ex_reg_rs) 
            & ~(i_ex_mem_reg_write & (i_ex_mem_reg_rt != 0) & (i_ex_mem_reg_rt == i_id_ex_reg_rs))) begin
                o_forward_a = 2'b01;
            end
            if(i_mem_wb_reg_write & (i_mem_wb_reg_rt != 5'h0)
            & (i_mem_wb_reg_rt == i_id_ex_reg_rt)
            & ~(i_ex_mem_reg_write & (i_ex_mem_reg_rt != 0) & (i_ex_mem_reg_rt == i_id_ex_reg_rt))) begin
                o_forward_b = 2'b01;
            end            
        end
    end
endmodule
