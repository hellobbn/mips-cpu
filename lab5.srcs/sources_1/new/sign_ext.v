`timescale 1ns / 1ps

/* extend a 16-bit input to 32-bit */

module sign_ext(
    input       [15:0]      i_dat,
    output      [31:0]      o_dat
    );

    assign o_dat = {16'b0000000000000000, i_dat};
endmodule
