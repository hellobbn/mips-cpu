`timescale 1ns / 1ps

/* CPU Top Module */

/* =========== Notes =================
 * Memory address: 8-bit
 * Memory width: 32 bit
 * Control Hazard: When `beq, bne` occur, stop the pipeline
 *
 * =========== Control Signal ============
 * EX: reg_dst, alu_op, alu_src
 * M: branch, mem_read, mem_write
 * WB: reg_write, mem_to_reg
 *
 * =========== Instructions ===========
 * j: PC = nPC; nPC = (PC & 0xf0000000) | (target << 2);
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

    /* ==========================================
     *            Wires, Regs Here
     * ==========================================
     */

    /* Wire from control unit */
    wire            w_id_reg_dst;
    wire            w_id_reg_write;             
    wire     [1:0]  w_id_alu_op;
    wire            w_id_alu_src_b;
    wire            w_id_mem_to_reg;
    wire            w_id_mem_write;                
    wire            w_id_mem_read;
    wire            w_id_branch;
    wire            w_id_pc_j_write;
    wire            w_id_in_is_i;                   // Flag marking if it is an I-Type Instruction

    /* Wire from ALU Conteoller */
    wire     [2:0]  w_ex_alu_op_fc;         // Input to ALU, selecting OP

    /* Wire From PC */
    wire    [31:0]  w_if_pc;                   // PC output;

    /* Wire from MUX */
    wire    [4:0]   w_ex_mux_ins_ir;        // MUX from IR to Registers
    wire    [31:0]  w_wb_mux_register_wdat; // MUX deciding data to write to registers
    wire    [31:0]  w_ex_mux_alu_in_b;      // MUX to ALU input B
    wire    [31:0]  w_if_mux_pc_wdat;       // MUX deciding data written to PC
    wire    [31:0]  w_ex_mux_alu_in_a;      // MUX deciding data input to ALU A (data forwarding)
    wire    [31:0]  w_ex_mux_alu_in_b_queue;        // MUX deciding data input to MUX to ALU B (data forwarding)
    wire    [8:0]   w_id_mux_hazard_id_ex;          // MUX Controlling data to ID/EX - 0 if stalled

    /* Wire from Memory */
    wire    [31:0]  w_if_in_from_mem;          // Instruction/data from memory

    /* Wire from Register File */
    wire    [31:0]  w_id_reg_file_rdat1;    // Read data 1 from register file
    wire    [31:0]  w_id_reg_file_rdat2;    // Read data 2 from register file       

    /* Wire from ALU */
    wire    [3:0]   w_ex_alu_out_flag;      // ALU Output - FLAG
    wire    [31:0]  w_ex_alu_out_result;    // ALU Output - result

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
    wire    [170:0] w_id_ex;                // ID/EX output
    wire            w_ex_in_is_i;
    wire    [31:0]  w_ex_instruction;       // EX Instruction
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
    wire    [1:0]   w_ex_alu_op;            // EX ALU Op to ALU Control
    wire            w_ex_alu_src_b;         // EX ALU B Src
    wire            w_ex_branch;            // EX Branch
    wire            w_ex_mem_write;         // EX MEM Write
    wire            w_ex_reg_write;         // EX reg write
    wire    [5:0]   w_ex_in;                // EX For zero branch test
    wire            w_ex_pc_j_write;

    /* Wire from EX/MEM */
    wire    [145:0] w_ex_mem;
    wire            w_mem_in_is_i;
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
    wire    [31:0]  w_mem_read_data;
    wire    [4:0]   w_mem_rd;               // rd field in EX/MEM
    wire            w_mem_pc_j_write;

    /* Wire from MEM/WB */
    wire    [76:0]  w_mem_wb;
    wire            w_wb_in_is_i;
    wire            w_wb_reg_write;
    wire            w_wb_mem_to_reg;
    wire    [31:0]  w_wb_mem_read_data;
    wire    [31:0]  w_wb_alu_out_result;
    wire    [4:0]   w_wb_reg_addr;
    wire    [4:0]   w_wb_rd;                // rd field in MEM/WB

    /* Wire for Forwarding */
    wire    [1:0]   w_forward_a;            // Forward A
    wire    [1:0]   w_forward_b;            // Forward B

    /* Wire for PC + 4 */
    wire    [31:0]  w_if_pc_plus_four;  

    /* Wire for the add in EX */
    wire    [31:0]  w_ex_b_addr;                // bne/beq address

    /* Wire from Hazard Unit */
    wire            w_hazard_pc_write;          // Prevent PC increment if stalled
    wire            w_hazard_if_id_write;       // Prevent IF/ID write if stalled
    wire            w_hazard_mux_id_ex;         // Control the control_signal to ID/EX
    wire            w_hazard_if_id_flush;       // will flush IF/ID when branch

    /* Wire for J Address Calculation */
    wire    [31:0]  w_ex_j_address;             // Jump Address
    wire    [31:0]  w_mem_j_address;            // Actual jump takes place in MEM

    /* PC Write Control */   
    reg r_ex_zero, r_ex_b_pc_write;

    /* PC Src Control */
    reg     [1:0]   w_mem_pc_src;

    /* CPU Control */
    cpu_control Control(//.i_run(i_run),
                        //.i_op(w_id_ins[31:26]),
                        //.i_clk(i_clk),
                        //.i_rst(i_rst),
                        .i_ins(w_id_ins),
                        .o_reg_dst(w_id_reg_dst),
                        .o_reg_write(w_id_reg_write),
                        .o_alu_op(w_id_alu_op),
                        .o_alu_src_b(w_id_alu_src_b),
                        .o_mem_to_reg(w_id_mem_to_reg),
                        .o_mem_write(w_id_mem_write),
                        .o_mem_read(w_id_mem_read),
                        .o_branch(w_id_branch),
                        .o_pc_j_write(w_id_pc_j_write),
                        .o_is_i(w_id_in_is_i));

    /* Instruction Memory */
    dist_mem_gen_0 Memory(.a(w_if_pc[9:2]),
                          .d(w_mem_reg_file_rdat2),
                          //.dpra(i_addr),
                          .clk(i_clk),
                          .we(0),                       // never write
                          .spo(w_if_in_from_mem));

    /* Register File */
    register_file Registers(.i_read_addr_0(w_id_ins[25:21]),
                            .i_read_addr_1(w_id_ins[20:16]),
                            .i_read_addr_2(i_addr[4:0]),
                            .i_write_addr(w_wb_reg_addr),
                            .i_write_data(w_wb_mux_register_wdat),
                            .i_write_enable(w_wb_reg_write),
                            .i_reset(i_rst),
                            .i_clk(i_clk),
                            .o_read_data_0(w_id_reg_file_rdat1),
                            .o_read_data_1(w_id_reg_file_rdat2),
                            .o_read_data_2(o_reg_data));

    /* ALU */
    alu_impl ALU(.in_a(w_ex_mux_alu_in_a),
                 .in_b(w_ex_mux_alu_in_b),
                 .in_select(w_ex_alu_op_fc),
                 .out_flag(w_ex_alu_out_flag),
                 .out_result(w_ex_alu_out_result));
    
    /* ALU Control */
    alu_control ALU_Control(.i_ins(w_ex_alu_ctrl_in),
                            .i_alu_op(w_ex_alu_op),
                            .i_i_tp(w_ex_instruction[31:26]),
                            .o_alu_op(w_ex_alu_op_fc));
    
    /* PC */
    pc_register PC(.clk(i_clk),
                .rst(i_rst),
                .i_dat(w_if_mux_pc_wdat),
                .i_we(w_hazard_pc_write),
                .o_dat(w_if_pc));

    /* Sign Extend */
    sign_ext Sign_Extend(.i_dat(w_id_ins[15:0]),
                         .o_dat(w_id_sign_ext_dat));

    /* Shift Left 2 */
    l_shift_two Shift_Left_Two(.i_dat(w_ex_sign_ext),
                               .o_dat(w_ex_sl_two_32_bit));

    /* MUX: Register file Write register */
    two_way_mux_5_bit MUX_W_REG(.i_zero_dat(w_ex_insa),
                                .i_one_dat(w_ex_insb),
                                .i_sel(w_ex_reg_dst),
                                .o_dat(w_ex_mux_ins_ir));

    /* MUX: Register file write data */
    two_way_mux MUX_REG_FILE_WDAT(.i_zero_dat(w_wb_alu_out_result),
                                  .i_one_dat(w_wb_mem_read_data),
                                  .i_sel(w_wb_mem_to_reg),
                                  .o_dat(w_wb_mux_register_wdat));

    /* MUX: deciding data written to PC */
    four_way_mux MUX_DAT_TO_PC(.i_zero_dat(w_if_pc_plus_four),
                               .i_one_dat(w_mem_b_addr),
                               .i_two_dat(w_mem_j_address),
                               .i_third_dat(0),
                               .i_sel(w_mem_pc_src),
                               .o_dat(w_if_mux_pc_wdat));

    /* MUX: ALU Input B */
    two_way_mux MAX_ALU_IN_B(.i_zero_dat(w_ex_mux_alu_in_b_queue),
                             .i_one_dat(w_ex_sign_ext),
                             .i_sel(w_ex_alu_src_b),
                             .o_dat(w_ex_mux_alu_in_b));

    /* MUX: Forward A */
    four_way_mux MUX_FORWARD_A(.i_zero_dat(w_ex_reg_file_rdat1),
                               .i_one_dat(w_wb_mux_register_wdat),
                               .i_two_dat(w_mem_alu_out_result),
                               .i_third_dat(0),
                               .i_sel(w_forward_a),
                               .o_dat(w_ex_mux_alu_in_a));

    /* MUX: Forward B */
    four_way_mux MUX_FORWARD_B(.i_zero_dat(w_ex_reg_file_rdat2),
                               .i_one_dat(w_wb_mux_register_wdat),
                               .i_two_dat(w_mem_alu_out_result),
                               .i_third_dat(0),
                               .i_sel(w_forward_b),
                               .o_dat(w_ex_mux_alu_in_b_queue));

    /* MUX: Data to ID/EX */
    two_way_mux_9_bit MUX_DAT_ID_EX(.i_zero_dat({w_id_reg_write, w_id_mem_write, w_id_branch, w_id_alu_src_b, w_id_alu_op, w_id_reg_dst, w_id_mem_read, w_id_mem_to_reg}),                      // 9-bit Control Signal
                                    .i_one_dat(9'b000000000),
                                    .i_sel(w_hazard_mux_id_ex),
                                    .o_dat(w_id_mux_hazard_id_ex));
    
    /* Data memory */
    dist_mem_gen_1 Data_Memory(.a(w_mem_alu_out_result[9:2]),
                               .d(w_mem_reg_file_rdat2),
                               .dpra(i_addr),
                               .clk(i_clk),
                               .we(w_mem_mem_write),
                               .spo(w_mem_read_data),
                               .dpo(o_mem_data));

    /* Hazard Unit */
    hazard_detection_unit Hazard_Unit(.i_id_ex_mem_read(w_ex_mem_read),
                                      .i_if_id_reg_rs(w_id_ins[25:21]),
                                      .i_id_ex_reg_rt(w_ex_instruction[20:16]),
                                      .i_if_id_reg_rt(w_id_ins[20:16]),
                                      .i_in_op_code(w_id_ins[31:26]),
                                      .o_if_id_reg_write(w_hazard_if_id_write),
                                      .o_pc_write(w_hazard_pc_write),
                                      .o_mux_id_ex(w_hazard_mux_id_ex),
                                      .o_if_id_flush(w_hazard_if_id_flush));

    /* IF/ID Register - 64 bit*/
    register_if_id IF_ID(.clk(i_clk),
                         .rst(i_rst),
                         .i_dat({w_if_pc_plus_four, w_if_in_from_mem}),
                         .i_we(w_hazard_if_id_write),
                         .i_flush(w_hazard_if_id_flush),
                         .o_dat(w_if_id));

    assign w_id_ins = w_if_id[31:0];
    assign w_id_pc_plus_four = w_if_id[63:32];

    /* ID/EX Register - 171 bit */
    register_id_ex ID_EX(.clk(i_clk),
                         .rst(i_rst),
                         .i_dat({w_id_in_is_i, w_id_pc_j_write, w_id_ins, w_id_mux_hazard_id_ex, w_id_pc_plus_four, w_id_reg_file_rdat1, w_id_reg_file_rdat2, w_id_sign_ext_dat}),
                         .i_we(1),
                         .o_dat(w_id_ex));

    assign w_ex_in_is_i     =       w_id_ex[170];
    assign w_ex_pc_j_write  =       w_id_ex[169];
    assign w_ex_instruction =       w_id_ex[168:137];
    assign w_ex_in          =       w_ex_instruction[31:26];        // [31:26]
    assign w_ex_reg_write   =       w_id_ex[136];
    assign w_ex_mem_write   =       w_id_ex[135];
    assign w_ex_branch      =       w_id_ex[134];
    assign w_ex_alu_src_b   =       w_id_ex[133];
    assign w_ex_alu_op      =       w_id_ex[132:131];
    assign w_ex_alu_ctrl_in =       w_ex_instruction[5:0];          // [5:0]
    assign w_ex_reg_dst     =       w_id_ex[130];
    assign w_ex_mem_read    =       w_id_ex[129];
    assign w_ex_mem_to_reg  =       w_id_ex[128];
    assign w_ex_pc_plus_four =      w_id_ex[127:96];                // pc + 4
    assign w_ex_reg_file_rdat1 =    w_id_ex[95:64];
    assign w_ex_reg_file_rdat2 =    w_id_ex[63:32];
    assign w_ex_sign_ext    =       w_id_ex[31:0];
    assign w_ex_insa        =       w_ex_instruction[20:16];        // [20:16]
    assign w_ex_insb        =       w_ex_instruction[15:11];        // [15:10]

    /* EX/MEM Register - 146 bit*/
    register_ex_mem EX_MEM(.clk(i_clk),
                           .rst(i_rst),
                           .i_dat({w_ex_in_is_i, w_ex_pc_j_write, w_ex_instruction[15:11], w_ex_j_address, w_ex_reg_write, w_ex_mem_to_reg, w_ex_branch, w_ex_mem_read, w_ex_mem_write, w_ex_b_addr, r_ex_b_pc_write, w_ex_alu_out_result, w_ex_reg_file_rdat2, w_ex_mux_ins_ir}),
                           .i_we(1),
                           .o_dat(w_ex_mem));

    assign w_mem_in_is_i =          w_ex_mem[145];
    assign w_mem_pc_j_write =       w_ex_mem[144];
    assign w_mem_rd =               w_ex_mem[143:139];
    assign w_mem_j_address =        w_ex_mem[138:107];
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

    
    /* MEM/WB Register - 77 bit*/
    register_mem_wb MEM_WB(.clk(i_clk),
                           .rst(i_rst),
                           .i_dat({w_mem_in_is_i, w_mem_rd, w_mem_mux_ins_ir, w_mem_reg_write, w_mem_mem_to_reg, w_mem_read_data, w_mem_alu_out_result}),
                           .i_we(1),
                           .o_dat(w_mem_wb));

    assign w_wb_in_is_i = w_mem_wb[76];
    assign w_wb_rd = w_mem_wb[75:71];
    assign w_wb_reg_addr = w_mem_wb[70:66];
    assign w_wb_reg_write = w_mem_wb[65];
    assign w_wb_mem_to_reg = w_mem_wb[64];
    assign w_wb_mem_read_data = w_mem_wb[63:32];
    assign w_wb_alu_out_result = w_mem_wb[31:0];
    
    /* Forwarding Unit */
    forwarding_unit ForwardinngUnit(.i_ex_mem_reg_write(w_mem_reg_write),
                                    .i_ex_mem_reg_rd(w_mem_rd),
                                    .i_id_ex_reg_rs(w_ex_instruction[25:21]),
                                    .i_id_ex_reg_rt(w_ex_instruction[20:16]),
                                    .i_mem_wb_reg_write(w_wb_reg_write),
                                    .i_mem_wb_reg_rd(w_wb_rd),
                                    .i_ex_mem_reg_rt(w_mem_mux_ins_ir),         // Write back address
                                    .i_mem_wb_reg_rt(w_wb_reg_addr),            // Write back address
                                    .i_ex_mem_is_i(w_mem_in_is_i),
                                    .i_mem_wb_is_i(w_wb_in_is_i),
                                    .o_forward_a(w_forward_a),
                                    .o_forward_b(w_forward_b));

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
    assign w_if_pc_plus_four = w_if_pc + 4;

    /* EX B Addr */
    assign w_ex_b_addr = w_ex_pc_plus_four + w_ex_sl_two_32_bit;

    /* MEM PC Src */
    always @(*) begin
        if(w_mem_branch & w_mem_b_pc_write) begin
            w_mem_pc_src = 2'b01;
        end
        else if(w_mem_pc_j_write) begin
            w_mem_pc_src = 2'b10;
        end
        else begin
            w_mem_pc_src = 2'b00;
        end
    end

    /* J-Type Address */
    assign w_ex_j_address = {w_ex_pc_plus_four[31:28], w_ex_instruction[25:0], 2'b00};
endmodule
