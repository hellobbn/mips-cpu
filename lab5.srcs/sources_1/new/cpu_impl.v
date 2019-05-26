`timescale 1ns / 1ps

/* CPU Top Module */

/* =========== Notes =================
 * Memory address: 8-bit
 * Memory width: 32 bit
 *
 * =========== Control Signal ============
 * EX: reg_dst, alu_op, alu_src
 * M: branch, mem_read, mem_write
 * WB: reg_write, mem_to_reg
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
    wire            w_id_reg_dst;
    wire            w_id_reg_write;             // TODO: Where to write?
    wire            w_id_alu_op;
    wire            w_alu_src_a;                // TODO: No longer needed
    wire            w_id_alu_src_b;
    wire            w_ir_write;                 // TODO: No longer needed
    wire            w_id_mem_to_reg;
    wire            w_id_mem_write;                
    wire            w_id_mem_read;
    wire            w_i_or_d;                   // TODO: No longer needed
    wire            w_pc_write;                 // TODO: No longer needed
    wire            w_pc_write_cond;            // TODO: No longer needed
    wire     [1:0]  w_id_pc_source;
    wire            w_id_branch;                         

    /* Wire from ALU Conteoller */
    wire     [2:0]  w_ex_alu_op_fc;         // Input to ALU, selecting OP

    /* Wire from IR */
    wire    [31:0]  w_instruction;          // IR output; TODO: Not needed

    /* Wire from ALUOut */
    wire    [31:0]  w_alu_out;              // ALUOut Register Output; TODO: Not Needed

    /* Wire From PC */
    wire    [31:0]  w_if_pc;                   // PC output; TODO: not needed

    /* Wire from MUX */
    wire    [31:0]  w_mux_mem_addr;         // MUX from PC to Memory
    wire    [4:0]   w_ex_mux_ins_ir;        // MUX from IR to Registers
    wire    [31:0]  w_mux_register_wdat;    // MUX deciding data to write to registers
    wire    [31:0]  w_ex_mux_alu_in_b;      // MUX to ALU input B
    wire    [31:0]  w_if_mux_pc_wdat;       // MUX deciding data written to PC

    /* Wire from Register */
    wire    [31:0]   w_reg_a;               // A
    wire    [31:0]   w_reg_b;               // B

    /* Wire from Memory */
    wire    [31:0]  w_if_in_from_mem;          // Instruction/data from memory

    /* Wire from Register File */
    wire    [31:0]  w_id_reg_file_rdat1;    // Read data 1 from register file
    wire    [31:0]  w_id_reg_file_rdat2;    // Read data 2 from register file       

    /* Wire from ALU */
    wire    [3:0]   w_ex_alu_out_flag;      // ALU Output - FLAG
    wire    [31:0]  w_ex_alu_out_result;    // ALU Output - result

    /* Wire from Memory Data Register */
    wire    [31:0]  w_mem_dat_reg;          // Memory data register output

    /* Unnamed wire */
    wire            w_pc_write_ctrl;        // Actual PC write control

    /* Wire from Sign Extend */
    wire    [31:0]  w_id_sign_ext_dat;      // Output from sign extend

    /* Wire from Shift-Left Two */
    wire    [31:0]  w_ex_sl_two_32_bit;     // Output from left-shift(in_32_bit)

    /* Wire from another Shift-Left Two */
    wire    [27:0]  w_sl_two_26_bit;        // Output from left-shift(in_26_bit)

    /* Wire from IF/ID */
    wire    [63:0]  w_if_id;                // IF/ID output
    wire    [31:0]  w_id_ins;               // Instruction in ID
    wire    [31:0]  w_id_pc_plus_four;      // PC + 4 in ID

    /* Wire from ID/EX */
    wire    [157:0] w_id_ex;                // ID/EX output
    wire            w_ex_reg_dst;           // EX reg dst
    wire            w_ex_mem_read;          // EX mem_read
    wire            w_ex_mem_to_reg;        // EX mem_to_reg
    wire    [31:0]  w_ex_pc_plus_four;      // EX PC + 4
    wire    [31:0]  w_ex_reg_file_rdat1;    // EX regA
    wire    [31:0]  w_ex_reg_file_rdat2;    // EX regB
    wire    [31:0]  w_ex_sign_ext;          // EX sign ext
    wire    [4:0]   w_ex_insa;              // EX in[20:16]
    wire    [4:0]   w_ex_insb;              // EX in[15:11]
    wire    [5:0]   w_ex_alu_ctrl_in;       // EX for ALU Control reference
    wire            w_ex_alu_op;            // EX ALU Op to ALU Control
    wire            w_ex_alu_src_b;         // EX ALU B Src
    wire            w_ex_branch;            // EX Branch
    wire            w_ex_mem_write;         // EX MEM Write
    wire            w_ex_reg_write;         // EX reg write
    wire    [5:0]   w_ex_in;                // EX For zero branch test

    /* Wire from EX/MEM */
    wire    [106:0] w_ex_mem;
    wire            w_mem_reg_write;
    wire            w_mem_mem_to_reg;
    wire            w_mem_branch;
    wire            w_mem_mem_read;
    wire            w_mem_mem_write;
    wire    [31:0]  w_mem_b_addr;
    wire            w_mem_b_pc_write;
    wire    [31:0]  w_mem_alu_out_result;
    wire    [31:0]  w_mem_reg_file_rdat2;
    wire    [4:0]   w_mem_mux_ins_ir;
    wire            w_mem_pc_src;           // TODO: Add j

    /* Wire for PC + 4 */
    wire    [31:0]  w_if_pc_plus_four;  

    /* Wire for the add in EX */
    wire    [31:0]  w_ex_b_addr;                // bne/beq address

    /* PC Write Control */   
    reg r_ex_zero, r_ex_b_pc_write;

    /* CPU Control */
    // TODO: Change
    cpu_control Control(.i_run(i_run),
                        .i_op(w_instruction[31:26]),
                        .i_clk(i_clk),
                        .i_rst(i_rst),
                        .o_reg_dst(w_id_reg_dst),
                        .o_reg_write(w_reg_write),
                        .o_alu_op(w_id_alu_op),
                        .o_alu_src_a(w_alu_src_a),
                        .o_alu_src_b(w_id_alu_src_b),
                        .o_ir_write(w_ir_write),
                        .o_mem_to_reg(w_id_mem_to_reg),
                        .o_mem_write(w_mem_write),
                        .o_mem_read(w_id_mem_read),
                        .o_i_or_d(w_i_or_d),
                        .o_pc_write(w_pc_write),
                        .o_pc_write_cond(w_pc_write_cond),
                        .o_pc_source(w_pc_source));

    /* Instruction Memory */
    // TODO: Del Write 
    dist_mem_gen_0 Memory(.a(w_mux_mem_addr[9:2]),
                          .d(w_mem_reg_file_rdat2),
                          .dpra(i_addr),
                          .clk(i_clk),
                          .we(w_mem_mem_write),
                          .spo(w_if_in_from_mem),
                          .dpo(o_mem_data));
    
    /* IR */
    register IR(.clk(i_clk),
                .rst(i_rst),
                .i_dat(w_if_in_from_mem),
                .i_we(w_ir_write),
                .o_dat(w_instruction));

    /* Register File */
    register_file Registers(.i_read_addr_0(w_id_ins[25:21]),
                            .i_read_addr_1(w_id_ins[20:16]),
                            .i_read_addr_2(i_addr[4:0]),
                            .i_write_addr(w_mux_ins_ir),
                            .i_write_data(w_mux_register_wdat),
                            .i_write_enable(w_reg_write),
                            .i_reset(i_rst),
                            .i_clk(i_clk),
                            .o_read_data_0(w_id_reg_file_rdat1),
                            .o_read_data_1(w_id_reg_file_rdat2),
                            .o_read_data_2(o_reg_data));

    /* ALU */
    alu_impl ALU(.in_a(w_ex_reg_file_rdat1),
                 .in_b(w_ex_mux_alu_in_b),
                 .in_select(w_ex_alu_op_fc),
                 .out_flag(w_ex_alu_out_flag),
                 .out_result(w_ex_alu_out_result)
                 );
    
    /* ALU Control */
    alu_control ALU_Control(.i_ins(w_ex_alu_ctrl_in),
                            .i_alu_op(w_ex_alu_op),
                            .i_i_tp(w_instruction[31:26]),      // TODO: No longer needed
                            .o_alu_op(w_ex_alu_op_fc));

    /* Memory data register */
    // TODO: No longer needed
    register Memory_Data_Register(.clk(i_clk),
                                  .rst(i_rst),
                                  .i_dat(w_if_in_from_mem),
                                  .i_we(1),
                                  .o_dat(w_mem_dat_reg));
    
    /* PC */
    register PC(.clk(i_clk),
                .rst(i_rst),
                .i_dat(w_mux_pc_wdat),
                .i_we(w_if_pc_write_ctrl),
                .o_dat(w_if_pc));

    /* Sign Extend */
    sign_ext Sign_Extend(.i_dat(w_id_ins[15:0]),
                         .o_dat(w_id_sign_ext_dat));

    /* Shift Left 2 */
    l_shift_two Shift_Left_Two(.i_dat(w_ex_sign_ext),
                               .o_dat(w_ex_sl_two_32_bit));

    /* Shift Left 2 - in only 26 bits */
    shift_left_two_26_to_28 Shift_Left_Two_26_BIT(.i_dat(w_instruction[25:0]),
                            .o_dat(w_sl_two_26_bit));

    /* MUX 1: Memory address */
    two_way_mux MUX_MEM_ADDR(.i_zero_dat(w_pc),
                             .i_one_dat(w_alu_out),
                             .sel(w_i_or_d),
                             .o_dat(w_mux_mem_addr));

    /* MUX 2: Register file Write register */
    two_way_mux_5_bit MUX_W_REG(.i_zero_dat(w_ex_insa),
                                .i_one_dat(w_ex_insb),
                                .sel(w_ex_reg_dst),
                                .o_dat(w_ex_mux_ins_ir));

    /* MUX 3: Register file write data */
    two_way_mux MUX_REG_FILE_WDAT(.i_zero_dat(w_alu_out),
                                  .i_one_dat(w_mem_dat_reg),
                                  .sel(w_mem_to_reg),
                                  .o_dat(w_mux_register_wdat));

    /* MUX 4: deciding data written to PC */
    // TODO: PC SRC
    four_way_mux MUX_DAT_TO_PC(.i_zero_dat(w_if_pc_plus_four),
                               .i_one_dat(w_mem_b_addr),
                               .i_two_dat({w_if_pc[31:28], w_sl_two_26_bit}),       // TODO: THIS NEEDS TO BE CHAMGED
                               .i_third_dat(0),
                               .i_sel(w_mem_pc_src),
                               .o_dat(w_if_mux_pc_wdat));

    /* MUX 6: ALU Input B */
    two_way_mux MAX_ALU_IN_B(.i_zero_dat(w_ex_reg_file_rdat2),
                             .i_third_dat(w_ex_sl_two_32_bit),
                             .i_sel(w_ex_alu_src_b),
                             .o_dat(w_ex_mux_alu_in_b));

    /* Register A */
    // TODO: No longer needed
    register REG_A(.clk(i_clk),
                   .rst(i_rst),
                   .i_dat(w_reg_file_rdat1),
                   .i_we(1),
                   .o_dat(w_reg_a));

    /* Register B */
    // TODO: No longer needed
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
    
    /* TODO: Data memory */

    /* IF/ID Register - 64 bit*/
    register_if_id IF_ID(.clk(i_clk),
                         .rst(i_rst),
                         .i_dat({w_if_pc_plus_four, w_if_in_from_mem}),
                         .i_we(1),
                         .o_dat(w_if_id));

    assign w_id_ins = w_if_id[31:0];
    assign w_id_pc_plus_four = w_if_id[63:32];

    /* ID/EX Register - 158 bit */
    register_id_ex ID_EX(.clk(i_clk),
                         .rst(i_rst),
                         .i_dat({w_id_ins[31:26], w_id_reg_write, w_id_mem_write, w_id_branch, w_id_alu_src_b, w_id_alu_op, w_id_ins[5:0], w_id_reg_dst, w_id_mem_read, w_id_mem_to_reg, w_id_pc_plus_four, w_id_reg_file_rdat1, w_id_reg_file_rdat2, w_id_sign_ext_dat, w_id_ins[20:16], w_id_ins[15:11]}),
                         .i_we(1),
                         .o_dat(w_id_ex));

    assign w_ex_in          =       w_id_ex[157:152];
    assign w_ex_reg_write   =       w_id_ex[151];
    assign w_ex_mem_write   =       w_id_ex[150];
    assign w_ex_branch      =       w_id_ex[149];
    assign w_ex_alu_src_b   =       w_id_ex[148];
    assign w_ex_alu_op      =       w_id_ex[147];
    assign w_ex_alu_ctrl_in =       w_id_ex[146:141];
    assign w_ex_reg_dst     =       w_id_ex[140];
    assign w_ex_mem_read    =       w_id_ex[139];
    assign w_ex_mem_to_reg  =       w_id_ex[138];
    assign w_ex_pc_plus_four =      w_id_ex[137:106];
    assign w_ex_reg_file_rdat1 =    w_id_ex[105:74];
    assign w_ex_reg_file_rdat2 =    w_id_ex[73:42];
    assign w_ex_sign_ext    =       w_id_ex[41:10];
    assign w_ex_insa        =       w_id_ex[9:5];           // [20:16]
    assign w_ex_insb        =       w_id_ex[4:0];           // [15:10]

    /* EX/MEM Register - 107 bit*/
    register_ex_mem EX_MEM(.clk(i_clk),
                           .rst(i_rst),
                           .i_dat({w_ex_reg_write, w_ex_mem_to_reg, w_ex_branch, w_ex_mem_read, w_ex_mem_write, w_ex_b_addr, r_ex_b_pc_write, w_ex_alu_out_result, w_ex_reg_file_rdat2, w_ex_mux_ins_ir}),
                           .i_we(1),
                           .o_dat(w_ex_mem));

    assign w_mem_reg_write =        w_ex_mem[106];
    assign w_mem_mem_to_reg =       w_ex_mem[105];
    assign w_mem_branch =           w_ex_mem[104];
    assign w_mem_mem_read =         w_ex_mem[103];
    assign w_mem_mem_write =        w_ex_mem[102];
    assign w_mem_b_addr =           w_ex_mem[101:70];
    assign w_mem_b_pc_write =       w_ex_mem[69];
    assign w_mem_alu_out_result =   w_ex_mem[68:37];
    assign w_mem_reg_file_rdat2 =   w_ex_mem[36:5];
    assign w_mem_mux_ins_ir =       w_ex_mem[4:0];
    
    /* MEM/WB Register */

    /* Zero Branch Check */
    always @(*) begin
       if(w_ex_alu_out_result == 0) begin
            r_ex_zero = 1;
        end
        else begin
           r_ex_zero = 0;
        end
    end
    
    always @(*) begin
        if(w_ex_in == 6'b000101) begin
            r_ex_b_pc_write = ~r_ex_zero;
        end
        else begin
            r_ex_b_pc_write = r_ex_zero;
        end
    end

    /* PC Output */
    assign o_pc_data = w_if_pc[9:2];                   // 8 Bit output

    /* PC + 4 */
    assign w_if_pc_plus_four = w_pc + 4;

    /* EX B Addr */
    assign w_ex_b_addr = w_ex_pc_plus_four + w_ex_sl_two_32_bit;

    /* MEM PC Src */
    assign w_mem_pc_src = w_mem_branch & w_mem_b_pc_write;
endmodule