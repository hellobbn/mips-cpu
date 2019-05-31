`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/13/2019 07:08:31 PM
// Design Name: 
// Module Name: cpu_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cpu_tb(
    );
    reg clk;
    reg rst;
    reg run;
    
    top CPU(.i_clk(clk), .i_rst(rst), .i_cont(1), .i_step(0),.i_mem(0), .i_inc(0), .i_dec(0));
    
    initial begin
        clk = 0;
        rst = 0;
        run = 1;
    end
    
    always begin
        #1 clk = ~clk;
    end
    
    initial begin
        #3 rst = 1;
        #1 rst = 0;
    end
endmodule
