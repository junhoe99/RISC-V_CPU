`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/19 11:55:51
// Design Name: 
// Module Name: instruction
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

// Instruction Memory, 즉 ROM을 설계
module instruction_memory (
    input  logic [31:0] iAddr,
    output logic [31:0] iData
);

    logic [31:0] rom[0:63];  // 64개의 32bit 명령어 저장 가능

    initial begin
        // ALU 테스트용 명령어들 (정확한 RISC-V 인코딩)
       // U-type Instruction
       //rom[0] = 32'h123450b7; // LUI x1, 0x12345
       //rom[1] = 32'h12345117; // AUIPC x2, 0x12345
       rom[0] = 32'h00000593;  // ADDI a1, zero, 0      ; a1 = 0
       rom[1] = 32'h00A5A023;  // sw a0, 0(a1)        ; a1 = 0. 따라서 mem[0] 번지에 a0(0x12345678) 저장
       rom[2] = 32'h0005A683;  // lw a3, 0(a1)        ; a1 = 0. 따라서 mem[0]에 저장되어있는 값을 a3 reg에 로드
       rom[3] = 32'h00A59223;  // sh a0, 4(a1)        ; a1 = 0. BRAM IP는 Word-align. 따라서 mem[1]에 a0(0x5678) 저장
       rom[4] = 32'h0045D703;  // lhu a4, 4(a1)       ; a1=  0. BRAM IP는 Word-align. 따라서 mem[1]에 저장된 값을 a4 reg에 로드

       // Initiialize
       for (int i = 2; i < 64; i = i + 1) begin
           rom[i] = 32'b0;
       end
    end

    assign iData = rom[iAddr[31:2]]; // ROM은 word align 형태이므로, 주소의 하위 2비트는 무시하고 사용
endmodule







