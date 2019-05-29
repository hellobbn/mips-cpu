`timescale 1ns / 1ps

/* Five Bit 2 way MUX */


module two_way_mux_5_bit(
    input       [4:0]      i_zero_dat,
    input       [4:0]      i_one_dat,
    input                  i_sel,
    output      [4:0]      o_dat
    );

    assign o_dat = (i_sel == 1'b0) ? i_zero_dat : i_one_dat;
endmodule
