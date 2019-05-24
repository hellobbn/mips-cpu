`timescale 1ns / 1ps
/* CPU Control Unit
 */


module cpu_control(
    input               i_run,          // Maybe necessary only here
    input   [5:0]       i_op,           // Op in instruction
    input               i_clk,
    input               i_rst,
    output reg          o_reg_dst,
    output reg          o_reg_write,
    output reg  [1:0]   o_alu_op,
    output reg          o_alu_src_a,
    output reg  [1:0]   o_alu_src_b,
    output reg          o_ir_write,
    output reg          o_mem_to_reg,
    output reg          o_mem_write,
    output reg          o_mem_read,
    output reg          o_i_or_d,
    output reg          o_pc_write,
    output reg          o_pc_write_cond,
    output reg  [1:0]   o_pc_source
    );

    /* Run enable register */
    reg r_run_enable;

    /* State reg */
    reg [3:0] state;
    reg [3:0] next_state;

    /* FSM States */
    parameter S_START = 0;              // Start
    parameter S_IN_FETCH = 1;           // Instruction fetch
    parameter S_ID_RF = 2;              // Instruction decode
    parameter S_MEM_ADDR_COM = 3;       // Memory address computation
    parameter S_MEM_ACCESS_R = 4;       // Memory access read
    parameter S_MEM_ACCESS_W = 5;       // Memory access write
    parameter S_MEM_BACK = 6;           // Write-back Step
    parameter S_EXEC = 7;               // R-Type execution
    parameter S_R_COMPLETE = 8;         // R-Type completion
    parameter S_B_COMPLETE = 9;         // Branch completion
    parameter S_J_COMPLETE = 10;        // Jump completion
    parameter S_I_START = 11;           // I-Type
    parameter S_I_COMPLETION = 12;      // I Completion

    /* Step 1 */
    always @(posedge i_clk or posedge i_rst) begin
        if(i_rst) begin
            state <= S_START;
        end
        else begin
            state <= next_state;
        end 
    end

    /* Step 2 */
    always @(*) begin
        o_reg_dst = 0;
        o_reg_write = 0;
        o_alu_op = 0;
        o_alu_src_a = 0;
        o_alu_src_b = 0;
        o_ir_write = 0;
        o_mem_to_reg = 0;
        o_mem_write = 0;
        o_mem_read = 0;
        o_i_or_d = 0;
        o_pc_write = 0;
        o_pc_write_cond = 0;
        o_pc_source = 0;
        if(i_rst) begin
            /* Reset */
        end
        else begin
            case(state)
                S_START: begin
                    o_reg_dst = 0;
                    o_reg_write = 0;
                    o_alu_op = 0;
                    o_alu_src_a = 0;
                    o_alu_src_b = 0;
                    o_ir_write = 0;
                    o_mem_to_reg = 0;
                    o_mem_write = 0;
                    o_mem_read = 0;
                    o_i_or_d = 0;
                    o_pc_write = 0;
                    o_pc_write_cond = 0;
                    o_pc_source = 0;
                end
                S_IN_FETCH: begin
                    o_mem_read = 1;                    // Read Memory
                    o_i_or_d = 0;                      // Read Instruction
                    o_ir_write = 1;                    // IR = instruction
                    o_pc_write = 1;                    // PC = PC + 4
                    o_alu_src_b = 2'b01;               // 4
                    o_alu_src_a = 0;                   // PC
                    o_alu_op = 2'b00;                  // Assuming add
                    o_pc_source = 2'b00;               // PC + 4
                end
                S_ID_RF: begin                          // Decode
                    o_alu_src_a = 0;                   // PC
                    o_alu_src_b = 2'b11;               // sign-extend(IR[15:0] << 2)
                    o_alu_op = 2'b00;                  // +
                end
                S_MEM_ADDR_COM: begin
                    o_alu_src_a = 1;                   // Reg[I[25:21]]
                    o_alu_src_b = 2'b10;               // sign-extend(IR[15:0]
                    o_alu_op = 2'b00;                  // +
                end
                S_MEM_ACCESS_R: begin
                    o_mem_read = 1;                    // Read Memory
                    o_i_or_d = 1;                      // Read Data
                end
                S_MEM_ACCESS_W: begin
                    o_mem_write = 1;                   // Write to memory
                    o_i_or_d = 1;                      // Write data
                end
                S_MEM_BACK: begin
                    o_reg_dst = 0;                     // writereg = I[20:16]
                    o_reg_write = 1;                   // Enable writing
                    o_mem_to_reg = 1;                  // Write mem data to reg
                end
                S_EXEC: begin
                    o_alu_src_a = 1;                   // Reg[I[25:21]]
                    o_alu_src_b = 2'b00;               // Reg[I[20:16]]
                    o_alu_op = 2'b10;                  // ALUOut = A op B
                end
                S_R_COMPLETE: begin
                    o_reg_dst = 1;                     // writereg = I[15:11]
                    o_reg_write = 1;                   // Enable writing
                    o_mem_to_reg = 0;                  // data = ALUOUT
                end
                S_B_COMPLETE: begin
                    o_alu_src_a = 1;                   // Reg[I[25:21]]
                    o_alu_src_b = 2'b00;               // Reg[I[20:16]]
                    o_alu_op = 2'b01;                  // -
                    o_pc_write_cond = 1;               // = 1 if zero=1
                    o_pc_source = 2'b01;               // PC = ALUOut
                end
                S_J_COMPLETE: begin
                    o_pc_write = 1;                    // PC Write
                    o_pc_source = 2'b10;               // PC = j ....
                end
                S_I_START: begin
                    o_alu_src_a = 1;
                    o_alu_src_b = 2'b10;
                    o_alu_op = 2'b11;
                end
                S_I_COMPLETION: begin
                    o_reg_dst = 0;
                    o_reg_write = 1;
                    o_mem_to_reg = 0;
                end
            endcase 
        end
    end

    /* Step 3 */
    always @(*) begin
        next_state = S_START;
        case(state)
            S_START: begin
                if(r_run_enable) begin
                    next_state = S_IN_FETCH;
                end
                else begin
                    next_state = S_START;
                end
            end
            S_IN_FETCH: begin
                next_state = S_ID_RF;
            end
            S_ID_RF: begin
                if(i_op == 6'b100011 | i_op == 6'b101011) begin         // Save / Load
                    next_state = S_MEM_ADDR_COM;
                end
                else if(i_op == 6'b000000) begin                        // R-type
                    next_state = S_EXEC;
                end
                else if(i_op == 6'b000100 | i_op == 6'b000101) begin    // BEQ / BNE
                    next_state = S_B_COMPLETE;
                end
                else if(i_op == 6'b000010) begin                        // J
                   next_state = S_J_COMPLETE;
                end
                else if(i_op == 6'b001000 | i_op == 6'b001100 | i_op == 6'b001110 | i_op == 6'b001101 | i_op == 6'b001010) begin
                    next_state = S_I_START;
                end
                else begin
                    next_state = S_START;
                end
            end
            S_I_START: begin
                next_state = S_I_COMPLETION;
            end
            S_I_COMPLETION: begin
                next_state = S_START;
            end
            S_MEM_ADDR_COM: begin
                if(i_op == 6'b100011) begin
                    next_state = S_MEM_ACCESS_R;
                end
                else begin
                    next_state = S_MEM_ACCESS_W;
                end
            end
            S_MEM_ACCESS_R: begin
                next_state = S_MEM_BACK;
            end
            S_MEM_ACCESS_W: begin
                next_state = S_START;
            end
            S_MEM_BACK: begin
                next_state = S_START;
            end
            S_EXEC: begin
                next_state = S_R_COMPLETE;
            end
            S_R_COMPLETE: begin
                next_state = S_START;
            end
            S_B_COMPLETE: begin
                next_state = S_START;
            end
            S_J_COMPLETE: begin
                next_state = S_START;
            end
            default: begin
                next_state = S_START;
            end
        endcase
    end

    /* Check sun state */
    always @(posedge i_clk) begin
        if(i_run == 1) begin
            r_run_enable <= 1;
        end
        else begin
            /* We need to assure the design has run when we set it to 0 */
            if(state == S_IN_FETCH) begin
                r_run_enable <= 0;
            end
            else begin
                r_run_enable <= r_run_enable;
            end
        end
    end
endmodule
