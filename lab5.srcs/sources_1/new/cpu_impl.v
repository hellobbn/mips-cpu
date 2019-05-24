`timescale 1ns / 1ps

/* CPU Top Module */

/* =========== Notes =================
 * Memory address: 8-bit
 * Memory width: 32 bit
 */
module cpu_impl(
    input               i_run,                  // Run signal
    input               i_clk,                  // Clock
    input               i_rst,                  // Reset
    input   [7:0]       i_addr,                 // Read data from memory, also from register_file
    
    output  [7:0]       o_pc_data,              // Output PC data - tmp 8 bit
    output  [31:0]      o_reg_data,             // Output spacific register data
    output  [31:0]      o_mem_data              // Output memory data
    );

    /* Wire from control unit */
    wire            w_reg_dst;
    wire            w_reg_write;
    wire    [1:0]   w_alu_op;
    wire            w_alu_src_a;
    wire    [1:0]   w_alu_src_b;
    wire            w_ir_write;
    wire            w_mem_to_reg;
    wire            w_mem_write;
    wire            w_mem_read;
    wire            w_i_or_d;
    wire            w_pc_write;
    wire            w_pc_write_cond;
    wire     [1:0]  w_pc_source;

    /* Wire from ALU Conteoller */
    wire     [2:0]  w_alu_op_fc;            // Input to ALU, selecting OP

    /* Wire from IR */
    wire    [31:0]  w_instruction;          // IR output

    /* Wire from ALUOut */
    wire    [31:0]  w_alu_out;              // ALUOut Register Output

    /* Wire From PC */
    wire    [31:0]  w_pc;                   // PC output

    /* Wire from MUX */
    wire    [31:0]  w_mux_mem_addr;         // MUX from PC to Memory
    wire    [4:0]   w_mux_ins_ir;           // MUX from IR to Registers
    wire    [31:0]  w_mux_register_wdat;    // MUX deciding data to write to registers
    wire    [31:0]  w_mux_alu_in_a;         // MUX to ALU input A
    wire    [31:0]  w_mux_alu_in_b;         // MUX to ALU input B
    wire    [31:0]  w_mux_pc_wdat;          // MUX deciding data written to PC

    /* Wire from Register */
    wire    [31:0]   w_reg_a;               // A
    wire    [31:0]   w_reg_b;               // B

    /* Wire from Memory */
    wire    [31:0]  w_in_from_mem;          // Instruction/data from memory

    /* Wire from Register File */
    wire    [31:0]  w_reg_file_rdat1;       // Read data 1 from register file
    wire    [31:0]  w_reg_file_rdat2;       // Read data 2 from register file       

    /* Wire from ALU */
    wire    [3:0]   w_alu_out_flag;         // ALU Output - FLAG
    wire    [31:0]  w_alu_out_result;       // ALU Output - result

    /* Wire from Memory Data Register */
    wire    [31:0]  w_mem_dat_reg;          // Memory data register output

    /* Unnamed wire */
    wire            w_pc_write_ctrl;        // Actual PC write control

    /* Wire from Sign Extend */
    wire    [31:0]  w_sign_ext_dat;         // Output from sign extend

    /* Wire from Shift-Left Two */
    wire    [31:0]  w_sl_two_32_bit;        // Output from left-shift(in_32_bit)

    /* Wire from another Shift-Left Two */
    wire    [27:0]  w_sl_two_26_bit;        // Output from left-shift(in_26_bit)

    /* CPU Control */
    cpu_control Control(.i_run(i_run),
                        .i_op(w_instruction[31:26]),
                        .i_clk(i_clk),
                        .i_rst(i_rst),
                        .o_reg_dst(w_reg_dst),
                        .o_reg_write(w_reg_write),
                        .o_alu_op(w_alu_op),
                        .o_alu_src_a(w_alu_src_a),
                        .o_alu_src_b(w_alu_src_b),
                        .o_ir_write(w_ir_write),
                        .o_mem_to_reg(w_mem_to_reg),
                        .o_mem_write(w_mem_write),
                        .o_mem_read(w_mem_read),
                        .o_i_or_d(w_i_or_d),
                        .o_pc_write(w_pc_write),
                        .o_pc_write_cond(w_pc_write_cond),
                        .o_pc_source(w_pc_source));

    /* Memory */
    dist_mem_gen_0 Memory(.a(w_mux_mem_addr[9:2]),
                          .d(w_reg_b),
                          .dpra(i_addr),
                          .clk(i_clk),
                          .we(w_mem_write),
                          .spo(w_in_from_mem),
                          .dpo(o_mem_data));
    
    /* IR */
    register IR(.clk(i_clk),
                .rst(i_rst),
                .i_dat(w_in_from_mem),
                .i_we(w_ir_write),
                .o_dat(w_instruction));

    /* Register File */
    register_file Registers(.i_read_addr_0(w_instruction[25:21]),
                            .i_read_addr_1(w_instruction[20:16]),
                            .i_read_addr_2(i_addr[4:0]),
                            .i_write_addr(w_mux_ins_ir),
                            .i_write_data(w_mux_register_wdat),
                            .i_write_enable(w_reg_write),
                            .i_reset(i_rst),
                            .i_clk(i_clk),
                            .o_read_data_0(w_reg_file_rdat1),
                            .o_read_data_1(w_reg_file_rdat2),
                            .o_read_data_2(o_reg_data));

    /* ALU */
    alu_impl ALU(.in_a(w_mux_alu_in_a),
                 .in_b(w_mux_alu_in_b),
                 .in_select(w_alu_op_fc),
                 .out_flag(w_alu_out_flag),
                 .out_result(w_alu_out_result)
                 );
    
    /* ALU Control */
    alu_control ALU_Control(.i_ins(w_instruction[5:0]),
                            .i_alu_op(w_alu_op),
                            .i_i_tp(w_instruction[31:26]),
                            .o_alu_op(w_alu_op_fc));

    /* Memory data register */
    register Memory_Data_Register(.clk(i_clk),
                                  .rst(i_rst),
                                  .i_dat(w_in_from_mem),
                                  .i_we(1),
                                  .o_dat(w_mem_dat_reg));
    
    /* PC */
    register PC(.clk(i_clk),
                .rst(i_rst),
                .i_dat(w_mux_pc_wdat),
                .i_we(w_pc_write_ctrl),
                .o_dat(w_pc));

    /* Sign Extend */
    sign_ext Sign_Extend(.i_dat(w_instruction[15:0]),
                         .o_dat(w_sign_ext_dat));

    /* Shift Left 2 */
    l_shift_two Shift_Left_Two(.i_dat(w_sign_ext_dat),
                               .o_dat(w_sl_two_32_bit));

    /* Shift Left 2 - in only 26 bits */
    shift_left_two_26_to_28 Shift_Left_Two_26_BIT(.i_dat(w_instruction[25:0]),
                            .o_dat(w_sl_two_26_bit));

    /* MUX 1: Memory address */
    two_way_mux MUX_MEM_ADDR(.i_zero_dat(w_pc),
                             .i_one_dat(w_alu_out),
                             .sel(w_i_or_d),
                             .o_dat(w_mux_mem_addr));

    /* MUX 2: Register file Write register */
    two_way_mux_5_bit MUX_W_REG(.i_zero_dat(w_instruction[20:16]),
                                .i_one_dat(w_instruction[15:11]),
                                .sel(w_reg_dst),
                                .o_dat(w_mux_ins_ir));

    /* MUX 3: Register file write data */
    two_way_mux MUX_REG_FILE_WDAT(.i_zero_dat(w_alu_out),
                                  .i_one_dat(w_mem_dat_reg),
                                  .sel(w_mem_to_reg),
                                  .o_dat(w_mux_register_wdat));

    /* MUX 4: deciding data written to PC */
    four_way_mux MUX_DAT_TO_PC(.i_zero_dat(w_alu_out_result),
                               .i_one_dat(w_alu_out),
                               .i_two_dat({w_pc[31:28], w_sl_two_26_bit}),
                               .i_third_dat(0),
                               .i_sel(w_pc_source),
                               .o_dat(w_mux_pc_wdat));

    /* MUX 5: ALU Input A */
    two_way_mux MUX_ALU_IN_A(.i_zero_dat(w_pc),
                             .i_one_dat(w_reg_a),
                             .sel(w_alu_src_a),
                             .o_dat(w_mux_alu_in_a));

    /* MUX 6: ALU Input B */
    four_way_mux MAX_ALU_IN_B(.i_zero_dat(w_reg_b),
                             .i_one_dat(32'b00000000000000000000000000000100),
                             .i_two_dat(w_sign_ext_dat),
                             .i_third_dat(w_sl_two_32_bit),
                             .i_sel(w_alu_src_b),
                             .o_dat(w_mux_alu_in_b));

    /* Register A */
    register REG_A(.clk(i_clk),
                   .rst(i_rst),
                   .i_dat(w_reg_file_rdat1),
                   .i_we(1),
                   .o_dat(w_reg_a));

    /* Register B */
    register REG_B(.clk(i_clk),
                   .rst(i_rst),
                   .i_dat(w_reg_file_rdat2),
                   .i_we(1),
                   .o_dat(w_reg_b));

    /* ALU Out */
    register ALUOut(.clk(i_clk),
                    .rst(i_rst),
                    .i_dat(w_alu_out_result),
                    .i_we(1),
                    .o_dat(w_alu_out));

    /* PC Write Control */   
    reg r_zero, r_b_pc_write;
    always @(*) begin
       if(w_alu_out_result == 0) begin
            r_zero = 1;
        end
        else begin
           r_zero = 0;
        end
    end
    
    always @(*) begin
        if(w_instruction[31:26] == 6'b000101) begin
            r_b_pc_write = ~r_zero;
        end
        else begin
            r_b_pc_write = r_zero;
        end
    end
    assign w_pc_write_ctrl = w_pc_write | (w_pc_write_cond & r_b_pc_write);

    /* PC Output */
    assign o_pc_data = w_pc[9:2];                   // 8 Bit output
endmodule
