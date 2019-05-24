`timescale 1ns / 1ps

/* DDU - Debug and Display Unit */

module ddu(
    input               i_clk,
    input               i_rst,
    input               i_cont,                 // cont = 1 => run = 1; cont = 0 => run = 0
    input               i_step,                 // for one clock cycle, run = 1
    input               i_inc,                  // increase reading address
    input               i_dec,                  // decrease reading address

    output  reg         o_run,
    output  reg [7:0]   o_addr
);
    reg                 r_operated_inc;
    reg                 r_operated_dec;    
    reg                 r_run_enable;      

    /* Set output address based on i_inc and i_dec */
    always @(posedge i_clk or posedge i_rst) begin
        if(i_rst) begin
            /* Reset here */
            o_addr <= 0;
            r_operated_inc <= 0;
            r_operated_dec <= 0;
        end
        else begin
            /* Incrse address only by 1 ! */
            if(i_inc == 1) begin
                if(r_operated_inc == 0) begin
                    o_addr <= o_addr + 1;
                    r_operated_inc <= 1;
                end
                else begin
                    o_addr <= o_addr;
                end
            end
            else begin
                r_operated_inc <= 0;
            end

            if(i_dec == 1) begin
                if(r_operated_dec == 0) begin
                    o_addr <= o_addr - 1;
                    r_operated_dec <= 1;
                end
                else begin
                    o_addr <= o_addr;
                end
            end
            else begin
                r_operated_dec <= 0;
            end
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if(i_rst) begin
            r_run_enable <= 0;
            o_run <= 0;
        end
        else if(i_cont == 1) begin
            o_run <= 1;
        end
        else begin
            if(i_step == 1) begin
                if(r_run_enable == 0) begin
                    /* Start a pluse of run here */
                    o_run <= 1;
                    r_run_enable <= 1;
                end
                else begin
                    /* Pluse ends here - don't change run_enable cause already run */
                    o_run <= 0;
                end
            end
            else begin
                o_run <= 0;
                r_run_enable <= 0;
            end
        end
    end
endmodule
