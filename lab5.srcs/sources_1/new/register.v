`timescale 1ns / 1ps

/* Register Impl */

module register(
    input                   clk,            // Clock
    input                   rst,            // Reset
    input       [31:0]      i_dat,          // In data
    input                   i_we,           // Write enable
    output  reg [31:0]      o_dat           // Out data
    );

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            o_dat <= 0;
        end
        else begin
            if(i_we) begin
                o_dat <= i_dat;
            end
            else begin
                o_dat <= o_dat;
            end
        end
    end
    
endmodule
