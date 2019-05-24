`timescale 1ns / 1ps

/* Two way MUX */

module two_way_mux(
    input       [31:0]      i_zero_dat,
    input       [31:0]      i_one_dat,
    input                   sel,
    output      [31:0]      o_dat
);

    assign o_dat = (sel == 1'b0) ? i_zero_dat : i_one_dat;

endmodule