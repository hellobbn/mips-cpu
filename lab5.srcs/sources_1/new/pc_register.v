`timescale 1ns / 1ps

/* PC Register */

module pc_register(
    input               clk,
    input               rst,
    input       [31:0]  i_dat,
    input               i_we,
    output  reg [31:0]  o_dat
    );
    reg count;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            o_dat <= 0;
            count <= 0;
        end
        else begin
            if(i_we) begin
                if(count) begin
                    count <= 0;
                    o_dat <= o_dat;
                end
                else begin
                    o_dat <= i_dat;
                end
            end
            else begin
                o_dat <= o_dat;
                count <= 1;
            end
        end
    end
endmodule
