`timescale 1ns / 1ps

/* Shift left a 26-bit input by 2 */
/* Maybe we need to extend it to 32-bit */

module shift_left_two_26_to_28(
    input       [25:0]      i_dat,
    output      [27:0]      o_dat
    );

    assign o_dat = {i_dat, 2'b00};
endmodule
