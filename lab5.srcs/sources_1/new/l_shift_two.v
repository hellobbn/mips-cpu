`timescale 1ns / 1ps

/* Shift the input by two 
 * Input: 32-bit
 */

module l_shift_two(
    input       [31:0]      i_dat,
    output      [31:0]      o_dat
    );

    assign o_dat = {i_dat[29:0], 2'b00};
endmodule
