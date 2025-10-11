`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/19 13:49:27
// Design Name: 
// Module Name: control_unit
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
`include "define.sv"

module control_unit (
    input logic [31:0] iData,
    output logic [3:0] ALU_Controls,
    output logic reg_wr_en,
    output logic ALUSrcMuxSel,
    output logic d_wr_en,
    output logic [1:0] RAM2RegWSel, // 0: ALU_Result, 1: dRdata (데이터 메모리에서 읽은 데이터)
    output logic [1:0] store_size,  // 00: sb(8bit), 01: sh(16bit), 10: sw(32bit),
    output logic [1:0] load_size,  // 00: lb(8bit), 01: lh(16bit), 10: lw(32bit)
    output logic branch
);


    // controls 
    // 3-bit control signal for ALU operation
    wire  [6:0] funct7 = iData[31:25];
    wire  [2:0] funct3 = iData[14:12];
    wire  [6:0] opcode = iData[6:0];


    logic [5:0] controls;
    assign {RAM2RegWSel, ALUSrcMuxSel, reg_wr_en, d_wr_en, branch} = controls;


    always_comb begin
        case (opcode)
            `OP_R_TYPE:
            controls = 6'b000100;  // R-type: write enable (RAM2RegWSel=2'b00, ALUSrcMuxSel=0, reg_wr_en=1, d_wr_en=0, branch = 0)
            `OP_S_TYPE:
            controls = 6'b001010;  // S-type: no write (RAM2RegWSel=2'b00, ALUSrcMuxSel=1, reg_wr_en=0, d_wr_en=1, branch = 0)
            `OP_IL_TYPE:
            controls = 6'b011100;  // IL-type Load: write enable (RAM2RegWSel=2'b01, ALUSrcMuxSel=1, reg_wr_en=1, d_wr_en=0, branch = 0)
            `OP_I_TYPE:
            controls = 6'b001100;  // I-type ALU: write enable (RAM2RegWSel=2'b00, ALUSrcMuxSel=1, reg_wr_en=1, d_wr_en=0, branch = 0). I-type의 명령어들은 register의 값들을 변경시키고 메모리와의 상호작용은 따로 없음. 따라서 RAM2RegWSel=0, ALUSrcMuxSel=1, reg_wr_en=1, d_wr_en=0
            `OP_B_TYPE:
            controls = 6'b000001;       // B-type ALU: write enable (RAM2RegWSel=2'b00, ALUSrcMuxSel=0(0으로 해야 ALU에 rs2가 입력되고, comparator로 비교 가능), reg_wr_en=0, d_wr_en=0, branch = 1).
            `OP_U_LUI_TYPE:
            controls = 6'b101100;  // U-type LUI: write enable (RAM2RegWSel=2'b10, ALUSrcMuxSel=1(imm선택), reg_wr_en=1, d_wr_en=0, branch = 0)
            `OP_U_AUIPC_TYPE:
            controls = 6'b111100;  // U-type AUIPC: write enable (RAM2RegWSel=2'b11, ALUSrcMuxSel=1(imm 선택), reg_wr_en=1, d_wr_en=0, branch = 0)
        default: controls = 6'b000000;
        endcase
    end

    // Write size control for S-type instructions based on funct3
    always_comb begin
        if (opcode == `OP_S_TYPE) begin
            case (funct3)
                3'b000:  store_size = 2'b00;  // sb (8-bit)
                3'b001:  store_size = 2'b01;  // sh (16-bit)
                3'b010:  store_size = 2'b10;  // sw (32-bit)
                default: store_size = 2'b10;  // default to sw
            endcase
        end else begin
            store_size = 2'b10;  // default to 32-bit for non S-type
        end
    end

    // Load size control for I-type Load instructions only
    always_comb begin
        if (opcode == `OP_IL_TYPE) begin
            case (funct3)
                3'b000:  load_size = 2'b00;  // lb (8-bit)
                3'b001:  load_size = 2'b01;  // lh (16-bit)
                3'b010:  load_size = 2'b10;  // lw (32-bit)
                default: load_size = 2'b10;  // default to lw
            endcase
        end else begin
            load_size = 2'b10;  // default to lw for non-load instructions
        end
    end


    // ALU control signal generation
    always_comb begin
        case (opcode)
            //funct7[5], funct3[2:0]
            `OP_R_TYPE: ALU_Controls = {funct7[5], funct3};  // R-type. 
            `OP_S_TYPE: ALU_Controls = `ADD;  // S-type (always ADD)
            `OP_IL_TYPE: ALU_Controls = `ADD;  // IL-type Load (always ADD)
            `OP_I_TYPE: begin  // SLLI, SRLI, SRA은 구분이 필요. 
                if ({funct7[5], funct3} == 4'b1101) begin  // SRAI
                    ALU_Controls = {1'b1, funct3};  // SRAI
                end else  // SRLI, SLLI
                    ALU_Controls = {
                        1'b0, funct3
                    };  // I-type ALU (other than shifts)
            end
            `OP_B_TYPE:
            ALU_Controls = {
                1'b0, funct3
            };  //funct3만 나가면 되고, 0은 그냥 ALU_controls가 4비트라서 채운거
            `OP_U_LUI_TYPE: ALU_Controls = `ADD;  // LUI (ALU does not matter, just pass imm)
            `OP_U_AUIPC_TYPE: ALU_Controls = `ADD;  // AUIPC (ALU adds PC + imm)
            default: ALU_Controls = 4'bx;  // Default to ADD
        endcase
    end


endmodule
