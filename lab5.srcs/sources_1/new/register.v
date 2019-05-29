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

/* Special Purposed Registers here */
module register_if_id(
    input                   clk,
    input                   rst,
    input       [63:0]      i_dat,
    input                   i_we,
    input                   i_flush,        // Flush the register
    output reg  [63:0]      o_dat
);
    reg cnt;
    always @(posedge clk or posedge rst) begin
        cnt <= 0;
        if(rst) begin
            o_dat <= 0;
        end
        else if(i_flush & (cnt == 0)) begin
            o_dat <= 0;
            cnt <= 1;
        end
        else if(cnt) begin
            o_dat <= 0;
            cnt <= 0;
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

module register_id_ex(
    input                   clk,
    input                   rst,
    input       [167:0]     i_dat,
    input                   i_we,
    output reg  [167:0]     o_dat
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

module register_ex_mem(
    input                   clk,
    input                   rst,
    input       [138:0]     i_dat,
    input                   i_we,
    output reg  [138:0]     o_dat
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

module register_mem_wb(
    input                   clk,
    input                   rst,
    input       [69:0]      i_dat,
    input                   i_we,
    output reg  [69:0]      o_dat
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