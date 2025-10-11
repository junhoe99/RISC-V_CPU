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
    input logic [1:0] RAM2RegWSel, // 0: ALU_Result, 1: dRdata (데이터 메모리에서 읽은 데이터)
    input logic [31:0] dRdata,  // 데이터 메모리에서 읽은 데이터
    input logic branch,
    output logic [31:0] iAddr,
    output logic [31:0] dAddr,
    output logic [31:0] dWdata
);

    logic [31:0] w_reg_file1, w_reg_file2, w_ALU_Result, w_PC_MUX_OUT;
    logic [31:0] w_pc_next;
    logic [31:0] w_imm_Ext;
    logic [31:0] w_alu_b_input;
    logic [31:0] w_mux2reg;
    logic [31:0] w_pc_plus_imm; // AUIPC를 위한 새로운 신호
    logic w_taken; // Branch taken 신호
    logic PC_MUX_SEL;

    // PC는 4씩 증가
    assign dAddr = w_ALU_Result;  // ALU 결과를 데이터 메모리 주소로 사용
    assign dWdata = w_reg_file2;  // 레지스터 파일의 두 번째 출력 데이터를 데이터 메모리 쓰기 데이터로 사용
    assign PC_MUX_SEL = branch & w_taken;
    assign w_pc_plus_imm = iAddr + w_imm_Ext; // AUIPC를 위한 현재 PC + immediate

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
        .pc(iAddr)
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

    mux_4x1 U_RAM2REG (
        .sel(RAM2RegWSel),  // 0: ALU_Result, 1: dRdata (데이터 메모리에서 읽은 데이터)
        .in0(w_ALU_Result),
        .in1(dRdata),  // 데이터 메모리에서 읽은 데이터를 연결해야 함
        .in2(w_imm_Ext), // LUI
        .in3(w_pc_plus_imm), // AUIPC : 현재 PC + immediate
        .out(w_mux2reg)  // 이 출력을 레지스터 파일의 쓰기 데이터로 사용
    );

    mux_2x1 U_PC_MUX(
        .sel(PC_MUX_SEL),
        .in0(32'd4),     // 0 : reg_file2
        .in1(w_imm_Ext), // 1 : imm[31:0]
        .out(w_PC_MUX_OUT) 
    );

    pc_adder U_PC_ADDER(
        .a(iAddr),
        .b(w_PC_MUX_OUT),
        .sum(w_pc_next)
    );

endmodule
