`timescale 1ns / 1ps

/* Hazard Detection Unit for Pipelined CPU */
/* Also, trigger stall when a `beq` or `bne` is detected */

module hazard_detection_unit(
    input               i_id_ex_mem_read,
    input       [4:0]   i_if_id_reg_rs,
    input       [4:0]   i_id_ex_reg_rt,
    input       [4:0]   i_if_id_reg_rt,
    input       [5:0]   i_in_op_code,           // `bne`, `beq` detection

    /* Stall Signal */
    output  reg         o_if_id_reg_write,
    output  reg         o_pc_write,
    output  reg         o_mux_id_ex,                // Controlling the ID/EX register - if stalled, choose 0
    output  reg         o_if_id_flush           // clean the register
    );

    always @(*) begin
        /* Default here */
        o_if_id_reg_write = 1;
        o_pc_write = 1;
        o_mux_id_ex = 0;                    // Control Signal
        o_if_id_flush = 0;
        if(i_id_ex_mem_read & ((i_id_ex_reg_rt == i_if_id_reg_rs) | (i_id_ex_reg_rt == i_if_id_reg_rt))) begin
            /* Stall HERE */
            o_if_id_reg_write = 0;
            o_pc_write = 0;
            o_mux_id_ex = 1;
        end

        if(i_in_op_code == 6'b000100 | i_in_op_code == 6'b000101) begin
            /* stall for two cycles */
            o_if_id_flush = 1;
            o_pc_write = 0;
            o_if_id_reg_write = 0;
        end
    end
endmodule
