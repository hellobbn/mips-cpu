`timescale 1ns / 1ps

/* Basic ALU Implemention */
/* 32 BIT */

/* Operation Selection:
 * s == 0 -> Add    a + b             
 * s == 1 -> sub    a - b
 * s == 2 -> and    a & b
 * s == 3 -> or     a | b
 * s == 4 -> not    ~a
 * s == 5 -> xor    a ^ b
 * s == 6 -> nor    ~(a | b)
 * s == 7 -> slt    a << b
 */

module alu_impl(
    input       [31:0]      in_a,                  // Input A
    input       [31:0]      in_b,                  // Input B
    input       [2:0]       in_select,             // Select Operation
    output  reg [3:0]       out_flag,              // Output flag
    output  reg [31:0]      out_result             // Output flag
    );
    
    wire [31:0] add_result, sub_result;
    wire [3:0] add_flag, sub_flag;
    add_task add_inst(in_a, in_b, add_flag, add_result);
    
    wire [31:0] tmp;
    assign tmp = (~in_b) + 1;
    add_task sub_inst(in_a, tmp, sub_flag, sub_result); 
    
    always @(*) begin
        if (in_select == 0) begin           // add
            out_result = add_result;
        end 
        else if (in_select == 1) begin      // sub
            out_result = sub_result;
        end
        else if (in_select == 2) begin      // and
            out_result = in_a & in_b;
        end
        else if (in_select == 3) begin      // or
            out_result = in_a | in_b;
        end
        else if(in_select == 4) begin       // not
            out_result = ~in_a;
        end
        else if(in_select == 5) begin       // xor
            out_result = in_a ^ in_b;
        end
        else if(in_select == 6) begin       // nor
            out_result = ~(in_a | in_b);
        end
        else begin                          // slt  - signed
            if(in_a[31] != in_b[31]) begin
                if(in_a[31] == 1'b1) begin
                    out_result = 1;
                end
                else begin
                    out_result = 0;
                end
            end
            else begin
                if(in_a < in_b) begin
                    out_result = 1;
                end
                else begin
                    out_result = 0;
                end
            end
        end
    end
    
    always @(*) begin 
        if (in_select == 0) begin
            out_flag = add_flag;
        end
        else if (in_select == 1) begin
            out_flag[3:1] = sub_flag[3:1];
            out_flag[0] = ~sub_flag[0];
        end 
        else if (in_select == 2 | in_select == 3 | in_select == 4 | in_select == 5) begin
            out_flag[2:0] = 3'b000;
            out_flag[3] = ~(|out_result);
        end
        else begin
            out_flag = 4'b1111;
        end
    end
endmodule
