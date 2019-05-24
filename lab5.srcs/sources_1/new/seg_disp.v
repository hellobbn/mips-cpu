`timescale 1ns / 1ps

module seg_disp(
    input               i_clk,              // 100 MHz Clock
    input               i_rst,
    input       [31:0]  i_seg_data,         // Data to be displayed in segment

    output  reg [7:0]   o_an,
    output  reg [7:0]   o_seg
    );

    /* 5 MHz Clock Here */
    wire            w_clk_5_mhz;

    /* Counter */
    reg     [20:0]  r_clk_cnt;
    
    /* A slower clock */
    reg             r_slower_clk;

    /* Anode selection */
    reg     [2:0]   r_an_sel;

    /* Data */
    reg     [3:0]   r_disp_dat;

    /* ===== Make the clock slower ===== */

    /* Clocking Wizard */
    clk_wiz_0 COV_CLOCK(.clk_5_mhz(w_clk_5_mhz),
                        .reset(i_rst),
                        .clk_100_mhz(i_clk));

    /* Slower clock */
    always @(posedge w_clk_5_mhz or posedge i_rst) begin
        if(i_rst) begin
            r_clk_cnt <= 0;
            r_slower_clk <= 0;
        end
        else begin
            r_clk_cnt <= r_clk_cnt + 1;
            if(r_clk_cnt == 2500) begin
                r_slower_clk <= ~r_slower_clk;
                r_clk_cnt <= 0;
            end
        end
    end

    /* ===== Display Start HERE ===== */

    /* Anode selection */
    always @(posedge r_slower_clk or posedge i_rst) begin
        if(i_rst) begin
            r_an_sel <= 0;
        end
        else begin
            r_an_sel <= r_an_sel + 1;
        end
    end

    /* Anode */
    always @(*) begin
        o_an = 8'b00000000;
        case (r_an_sel)
            3'b000: o_an = 8'b11111110;
            3'b001: o_an = 8'b11111101;
            3'b010: o_an = 8'b11111011;
            3'b011: o_an = 8'b11110111;
            3'b100: o_an = 8'b11101111;
            3'b101: o_an = 8'b11011111;
            3'b110: o_an = 8'b10111111;
            3'b111: o_an = 8'b01111111;
        endcase
    end

    /* Data Selection */
    always @(*) begin
        r_disp_dat = 4'b0000;
        case(r_an_sel)
            3'b000: r_disp_dat = i_seg_data[3:0];
            3'b001: r_disp_dat = i_seg_data[7:4];
            3'b010: r_disp_dat = i_seg_data[11:8];
            3'b011: r_disp_dat = i_seg_data[15:12];
            3'b100: r_disp_dat = i_seg_data[19:16];
            3'b101: r_disp_dat = i_seg_data[23:20];
            3'b110: r_disp_dat = i_seg_data[27:24];
            3'b111: r_disp_dat = i_seg_data[31:28];
        endcase
    end

    /* Display data */
    always @(*) begin
        case(r_disp_dat)
            4'b0000: o_seg = 8'b10000001;           // 0
            4'b0001: o_seg = 8'b11001111;           // 1
            4'b0010: o_seg = 8'b10010010;           // 2
            4'b0011: o_seg = 8'b10000110;           // 3
            4'b0100: o_seg = 8'b11001100;           // 4
            4'b0101: o_seg = 8'b10100100;           // 5
            4'b0110: o_seg = 8'b10100000;           // 6
            4'b0111: o_seg = 8'b10001111;           // 7
            4'b1000: o_seg = 8'b10000000;           // 8
            4'b1001: o_seg = 8'b10000100;           // 9
            4'b1010: o_seg = 8'b10001000;           // A
            4'b1011: o_seg = 8'b11100000;           // B - b
            4'b1100: o_seg = 8'b10110001;           // C
            4'b1101: o_seg = 8'b11000010;           // D - d
            4'b1110: o_seg = 8'b10110000;           // E
            4'b1111: o_seg = 8'b10111000;           // F
        endcase
    end

endmodule
