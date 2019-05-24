`timescale 1ns / 1ps
/* Register file
 * In MIPS: 32 registers, each 5 bit
 */


module register_file(
    input [4:0] i_read_addr_0,
    input [4:0] i_read_addr_1,
    input [4:0] i_read_addr_2,
    input [4:0] i_write_addr,
    input [31:0] i_write_data,
    input i_write_enable,
    input i_reset,
    input i_clk,
    
    output [31:0] o_read_data_0,
    output [31:0] o_read_data_1,
    output [31:0] o_read_data_2
    );
    
    reg [31:0] reg_file [31:0];       
    
    assign o_read_data_0 = reg_file[i_read_addr_0];
    assign o_read_data_1 = reg_file[i_read_addr_1];
    assign o_read_data_2 = reg_file[i_read_addr_2];

    integer i;
    always @(posedge i_clk) begin
        if(i_write_enable == 1) begin
            reg_file[i_write_addr] = i_write_data;
        end
        else if(i_reset == 1) begin
            // reset
            for(i = 0; i < 32; i = i + 1) begin
                reg_file[i] = 0;
            end
        end
    end
endmodule
