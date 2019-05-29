`timescale 1ns / 1ps

/* Hazard Detection Unit for Pipelined CPU */

module hazard_detection_unit(
    input               i_id_ex_mem_read,
    input       [4:0]   i_if_id_reg_rs,
    input       [4:0]   i_id_ex_reg_rt,
    input       [4:0]   i_if_id_reg_rt,

    /* Stall Signal */
    output  reg         o_if_id_reg_write,
    output  reg         o_pc_write,
    output  reg         o_mux_id_ex                 // Controlling the ID/EX register - if stalled, choose 0
    );

    always @(*) begin
        /* Default here */
        o_if_id_reg_write = 1;
        o_pc_write = 1;
        o_mux_id_ex = 0;                    // Control Signal
        if(i_id_ex_mem_read & ((i_id_ex_reg_rt == i_if_id_reg_rs) | (i_id_ex_reg_rt == i_if_id_reg_rt))) begin
            /* Stall HERE */
            o_if_id_reg_write = 0;
            o_pc_write = 0;
            o_mux_id_ex = 1;
        end
    end
endmodule
