`timescale 1ns / 1ps

/* Four Way MUX */

module four_way_mux(
    input       [31:0]      i_zero_dat,
    input       [31:0]      i_one_dat,
    input       [31:0]      i_two_dat,
    input       [31:0]      i_third_dat,
    input       [1:0]       i_sel,

    output  reg [31:0]      o_dat
    );

    always @(*) begin
        if(i_sel == 0) begin
            o_dat = i_zero_dat;
        end
        else if (i_sel == 1) begin
            o_dat = i_one_dat;
        end
        else if (i_sel == 2) begin
            o_dat = i_two_dat;
        end 
        else begin
            o_dat = i_third_dat;
        end
    end
endmodule
