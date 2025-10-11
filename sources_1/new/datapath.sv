`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/19 11:36:02
// Design Name: 
// Module Name: datapath
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


module datapath (
    input logic clk,
    input logic rst,

    //Instruction
    input logic [31:0] iData,
    //Control signals
    input logic [3:0] ALU_Controls,
    input logic reg_wr_en,
    input logic ALUSrcMuxSel,
    input logic [2:0] RAM2RegWSel, // 0: ALU_Result, 1: dRdata, 2: imm_Ext, 3: pc_plus_imm, 4: pc_plus_4
    input logic [31:0] dRdata,  // 데이터 메모리에서 읽은 데이터
    input logic branch,
    input logic JAL,  // JAL 제어 신호
    input logic JALR, // JALR 제어 신호
    output logic [31:0] iAddr,
    output logic [31:0] dAddr,
    output logic [31:0] dWdata,
    output logic [2:0] funct3     // funct3 출력 추가
);

    logic [31:0] w_reg_file1, w_reg_file2, w_ALU_Result;
    logic [31:0] w_pc_next;
    logic [31:0] w_imm_Ext;
    logic [31:0] w_alu_b_input;
    logic [31:0] w_mux2reg;
    logic [31:0] w_pc_plus_4;   // PC + 4 계산
    logic [31:0] w_pc_plus_imm; // PC + immediate (AUIPC, JAL용)
    logic [31:0] w_rs1_plus_imm; // rs1 + immediate (JALR용)
    logic w_taken; // Branch taken 신호
    logic PC_MUX_SEL;
    logic [31:0] w_pc;
    logic [31:0] w_pc_adder_out; // PC + 4 결과를 저장하는 신호
    logic [31:0] w_JALR_MUX_OUT; // JALR MUX 출력 신호

    // PC는 4씩 증가
    assign dAddr = w_ALU_Result;  // ALU 결과를 데이터 메모리 주소로 사용
    assign dWdata = w_reg_file2;  // 레지스터 파일의 두 번째 출력 데이터를 데이터 메모리 쓰기 데이터로 사용
    assign funct3 = iData[14:12]; // funct3 출력 (LBU/LHU 구분용)
    assign PC_MUX_SEL = (JAL) | (JALR) | (branch & w_taken);  // JALR 필요함 (점프 주소 선택을 위해)
    assign w_pc_plus_4 = iAddr + 32'd4; // PC + 4
    //assign w_pc_plus_imm = iAddr + w_imm_Ext; // PC + immediate (AUIPC, JAL용)
    //assign w_rs1_plus_imm = w_reg_file1 + w_imm_Ext; // rs1 + immediate (JALR용)
    assign iAddr  = w_pc;


    register_file U_REG_FILE (
        .clk(clk),
        .rst(rst),  // reset 신호 추가
        //Inputs
        .rRA1(iData[19:15]),   //Read address 1. 5bit인 이유? 32개의 레지스터를 5bit로 표현 가능, RA1= 
        .rRA2(iData[24:20]),  //Read address 2
        .rWA(iData[11:7]),  //Write address
        .reg_wr_en(reg_wr_en),  //Write enable
        .rWData(w_mux2reg),  //Write data
        //Outputs
        .rRD1(w_reg_file1),  //Read data 1
        .rRD2(w_reg_file2)  //Read data 2
    );

    ALU U_ALU (
        .A(w_reg_file1),
        .B(w_alu_b_input),
        .ALU_Controls(ALU_Controls),
        .ALU_Result(w_ALU_Result),
        .taken(w_taken)  // 분기 조건 신호 추가
    );

    program_counter U_PC (
        .clk(clk),
        .rst(rst),
        .pc_next(w_pc_next),
        .pc(w_pc)
    );

    extend U_EXT (
        .iData(iData),
        .imm_Ext(w_imm_Ext)
    );

    mux_2x1 U_Reg2ALU (
        .sel(ALUSrcMuxSel),  // 0: reg_file2, 1: imm_Ext
        .in0(w_reg_file2),
        .in1(w_imm_Ext),
        .out(w_alu_b_input)
    );

    mux_5x1 U_RAM2REG (
        .sel(RAM2RegWSel),  // 0: ALU_Result, 1: dRdata, 2: imm_Ext, 3: pc_plus_imm, 4: pc_plus_4
        .in0(w_ALU_Result),
        .in1(dRdata),  // 데이터 메모리에서 읽은 데이터
        .in2(w_imm_Ext), // LUI
        .in3(w_pc_plus_imm), // AUIPC: PC + imm
        .in4(w_pc_adder_out), // JAL/JALR: PC + 4
        .out(w_mux2reg)  // 이 출력을 레지스터 파일의 쓰기 데이터로 사용
    );

    mux_2x1 U_JALR_MUX (
        .sel(JALR),  // 0: reg_file2, 1: imm_Ext
        .in0(w_pc),
        .in1(w_reg_file1),
        .out(w_JALR_MUX_OUT)
    );

    mux_2x1 U_PC_MUX(
        .sel(PC_MUX_SEL),
        .in0(w_pc_adder_out),     // 0 : PC + 4
        .in1(w_pc_plus_imm), // 1 : JAL, JALR
        .out(w_pc_next)
    );

    adder U_PC_ADDER(
        .a(32'd4),
        .b(w_pc),
        .sum(w_pc_adder_out)
    );

    adder U_JAL_ADDER(
        .a(w_imm_Ext),
        .b(w_JALR_MUX_OUT),
        .sum(w_pc_plus_imm)
    );

    

endmodule
