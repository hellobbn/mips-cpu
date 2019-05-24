`timescale 1ns / 1ps

/* Top module */

module top(
    input               i_clk,
    input               i_rst,
    input               i_cont,
    input               i_step,
    input               i_mem,
    input               i_inc,
    input               i_dec,

    output wire [15:0]  o_led,
    output wire [7:0]   o_an,
    output wire [7:0]   o_seg
    );

    /* Wires from DDU */
    wire                w_ddu_run;
    wire        [7:0]   w_ddu_addr;

    /* Wire From CPU */
    wire        [7:0]   w_cpu_pc;
    wire        [31:0]  w_cpu_mem_data;
    wire        [31:0]  w_cpu_reg_data;

    /* Data to display */
    reg        [31:0]  w_dat_to_disp;

    /* DDU */
    ddu DDU(.i_clk(i_clk),
            .i_rst(i_rst),
            .i_cont(i_cont),
            .i_step(i_step),
            .i_inc(i_inc),
            .i_dec(i_dec),
            .o_run(w_ddu_run),
            .o_addr(w_ddu_addr));

    /* CPU */
    cpu_impl CPU(.i_run(w_ddu_run),
                 .i_clk(i_clk),
                 .i_rst(i_rst),
                 .i_addr(w_ddu_addr),
                 .o_pc_data(w_cpu_pc),
                 .o_reg_data(w_cpu_reg_data),
                 .o_mem_data(w_cpu_mem_data));

    /* LED */
    assign o_led[7:0] = w_cpu_pc;
    assign o_led[15:8] = w_ddu_addr;

    /* Display Unit */
    seg_disp Display(.i_clk(i_clk),
                     .i_rst(i_rst),
                     .i_seg_data(w_dat_to_disp),
                     .o_an(o_an),
                     .o_seg(o_seg));

    /* Choose data to display */
    always @(*) begin
        if(i_mem == 1) begin
            w_dat_to_disp = w_cpu_mem_data;
        end
        else begin
            w_dat_to_disp = w_cpu_reg_data;
        end
    end
endmodule
