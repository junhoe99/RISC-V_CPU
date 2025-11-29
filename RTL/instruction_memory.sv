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
        // J-type 테스트용 명령어들 (정확한 RISC-V 인코딩)
        //rom[0] = 32'h00000593;  // ADDI a1, zero, 0      ; a1 = 0
        //rom[1] = 32'h004000ef;  // JAL ra, 4             ; Jump to address PC+4, save PC+4 in ra (x1)
        //rom[2] = 32'h00000613;  // ADDI a2, zero, 0      ; a2 = 0 (이 명령어는 건너뛰어짐)
        //rom[3] = 32'h00100693;  // ADDI a3, zero, 1      ; a3 = 1 (JAL의 목적지)
        //rom[4] = 32'h00008067;  // JALR zero, ra, 0      ; Jump to address in ra+0, no save
        //rom[5] = 32'h00200713;  // ADDI a4, zero, 2      ; a4 = 2



        // === I-type Instructions (즉시값 연산) ===
        rom[0] = 32'h00500513;  // addi a0, x0, 5      ; a0 = 0 + 5 = 5
        rom[1] = 32'h00750593;  // addi a1, a0, 7      ; a1 = 5 + 7 = 12
        rom[2] = 32'h00252513;  // slti a0, a0, 2      ; a0 = (5 < 2) = 0
        rom[3] = 32'h0ff5b593;  // sltiu a1, a1, 255   ; a1 = (12 < 255) = 1
        rom[4] = 32'h00A54513;  // xori a0, a0, 10     ; a0 = 0 ^ 10 = 10
        rom[5] = 32'h00F5E593;  // ori a1, a1, 15      ; a1 = 1 | 15 = 15
        rom[6] = 32'h00757513;  // andi a0, a0, 7      ; a0 = 10 & 7 = 2
        rom[7] = 32'h00259593;  // slli a1, a1, 2      ; a1 = 15 << 2 = 60
        rom[8] = 32'h0025D513;  // srli a0, a1, 2      ; a0 = 3C >> 2 = 0F
        rom[9] = 32'h4035D593;  // srai a1, a1, 3      ; a1 = 0F >>> 3 = 0x1

        // === R-type Instructions (레지스터 연산) ===
        rom[10] = 32'h00B50633;  // add a2, a0, a1      ; a2 = 15(F) + 7 = 16()
        rom[11] = 32'h41060633;  // sub a2, a2, a6      ; a2 = 16 - 10 = 6
        rom[12] = 32'h00181533;  // sll a0, a6, x1      ; a0 = F << (1) = F << 1 = 20
        rom[13] = 32'h00A5A633;  // slt a2, a1, a0      ; a2 = (0 < 15) = 1

        // SLT vs SLTU 비교 테스트를 위한 음수값 설정
        rom[14] = 32'hFFF00493;  // addi x9, x0, -1     ; x9 = -1 (0xFFFFFFFF)
        rom[15] = 32'h00952633;  // slt a2, x9, a0      ; slt a2, a0, x9 / a2 = ( 15 < -1 signed) ? 1 : 0 = 0 (양수 < 음수는 거짓)
        rom[16] = 32'h00953633;  // sltu a2, x9, a0     ; a2 = (-1 < 15 unsigned) = (0xFFFFFFFF < 15) = 0 / a2 = (15 < FFFFFFFF) ? 1 : 0 = 1 (15 < 4294967295는 참)

        rom[17] = 32'h00A5C633;  // xor a2, a1, a0      ; a2 = 07 ^ 20 = 15(F)
        rom[18] = 32'h00155533;  // srl a0, a0, x1      ; a0 = 32 >> 1 = 16
        rom[19] = 32'h40255533;  // sra a0, a0, x2      ; a0 = 32 >>> (2) = 32 >>> 2 = 8
        rom[20] = 32'h00A5E633;  // or a2, a1, a0       ; a2 = 07 | 04 = 0F
        rom[21] = 32'h00A5F633;  // and a2, a1, a0      ; a2 = 07 & 08 = 00

        // === U-type Instructions (상위 즉시값 로드) ===
        rom[22] = 32'h12345537;  // lui a0, 0x12345     ; a0 = 0x12345000 = 305397760
        rom[23] = 32'h00006597;  // auipc a1, 6         ; a1 = PC + (64 + 12) = 88 + 24576 = 24664

        // === Load/Store Instructions ===
        // Store 테스트용 데이터 준비
        rom[24] = 32'h12345537;  // lui a0, 0x12345     ; a0 = 0x12345000
        rom[25] = 32'h67850513;  // addi a0, a0, 0x678  ; a0 = 0x12345678
        rom[26] = 32'h00000593;  // addi a1, x0, 0      ; a1 = 0 (메모리 주소)

        // S-type Instructions (Store) - BRAM WRITE_FIRST 모드 타이밍 테스트
        rom[27] = 32'h00A5A023;  // sw a0, 0(a1)        ; a1 = 0. 따라서 mem[0] 번지에 a0(0x12345678) 저장
        rom[28] = 32'h00000013;  // nop                  ; BRAM dout 타이밍 확인을 위한 1 cycle 대기
        rom[29] = 32'h0005A683;  // lw a3, 0(a1)        ; a1 = 0. 따라서 mem[0]에 저장되어있는 값을 a3 reg에 로드

        // 추가 Store/Load 테스트 (다른 주소에서)
        rom[30] = 32'h00A59223;  // sh a0, 4(a1)        ; a1 = 0. BRAM IP는 Word-align. 따라서 mem[1]에 a0(0x5678) 저장
        rom[31] = 32'h00000013;  // nop                  ; BRAM dout 타이밍 확인을 위한 1 cycle 대기
        rom[32] = 32'h0045D703;  // lhu a4, 4(a1)       ; a1=  0. BRAM IP는 Word-align. 따라서 mem[1]에 저장된 값을 a4 reg에 로드

        rom[33] = 32'h00A58423;  // sb a0, 8(a1)        ; a1 = 0. 따라서 mem[8]에 a0(0x78) 저장
        rom[34] = 32'h00000013;  // nop                  ; BRAM dout 타이밍 확인을 위한 1 cycle 대기
        rom[35] = 32'h00858803;  // lbu a6, 8(a1)       ; a6 = mem[8] = 0x78 (BRAM 타이밍 테스트!)
        rom[36] = 32'h00000013;  // nop                  ; BRAM dout 타이밍 확인을 위한 1 cycle 대기
        rom[37] = 32'h00858883;  // lb a7, 8(a1)        ; a7 = mem[8] = 0x78 (BRAM 타이밍 테스트!)        // === Branch Instructions ===
        // Branch 테스트용 데이터 준비
        rom[38] = 32'h00500513;  // addi a0, x0, 5      ; a0 = 5
        rom[39] = 32'h00500593;  // addi a1, x0, 5      ; a1 = 5
        rom[40] = 32'h00300613;  // addi a2, x0, 3      ; a2 = 3

        // B-type Instructions
        rom[41] = 32'h00B50463;  // beq a0, a1, +8      ; if(5==5) jump to rom[43] (skip rom[42])
        rom[42] = 32'h00100693;  // addi a3, x0, 1      ; a3 = 1 (이 명령은 건너뛰어짐)
        rom[43] = 32'h00C51463;  // bne a0, a2, +8      ; if(5!=3) jump to rom[45] (skip rom[44])
        rom[44] = 32'h00200693;  // addi a3, x0, 2      ; a3 = 2 (이 명령은 건너뛰어짐)
        rom[45] = 32'h00C54463;  // blt a0, a2, +8      ; if(5<3) jump (거짓이므로 점프 안하고 PC값은 +4, ROM[46]으로 이동)
        rom[46] = 32'h00C55463;  // bge a0, a2, +8      ; if(5>=3) jump to rom[48] (skip rom[47])
        rom[47] = 32'h00300693;  // addi a3, x0, 3      ; a3 = 3 (이 명령은 건너뛰어짐)
        rom[48] = 32'h00C56463;  // bltu a0, a2, +8     ; if(5<3 unsigned) jump (거짓이므로 점프 안함)
        rom[49] = 32'h00C57463;  // bgeu a0, a2, +8     ; if(5>=3 unsigned) jump to rom[51] (skip rom[50])
        rom[50] = 32'h00400693;  // addi a3, x0, 4      ; a3 = 4 (이 명령은 건너뛰어짐)

        // === J-type Instructions (Jump) ===
        // JAL rd, imm  : Jump : [현재 PC + imm]값으로 jump할 주소를 지정  , Link : rd에 [현재 PC+4]로 복귀주소 저장   
        //rom[51] = 32'h008000EF;  // jal x1, +8          ; Jump : 204 + 8 = 212로 jump. Link : x1에 [현재 PC + 4] = 204 + 4 = 208로 복귀주소 저장
        //rom[52] = 32'h00500693;  // addi a3, x0, 5      ; a3 = 5 (이 명령은 건너뛰어짐)
        //rom[53] = 32'h00008067;  // jalr x0, 0(x1)      ; Jump : rs(x1) + imm(0) = 208 + 0 = 208로 점프, Link : JALR에서 rd가 x0이면, link기능을 사용하지 않겠다는 뜻.
        //rom[54] = 32'h00600693;  // addi a3, x0, 6      ; a3 = 6

        // === J-type Instructions (Jump / Function Call Simulation) ===
        rom[51] = 32'h008000EF;  // jal x1, +8          
                                 // [Jump]   PC + 8 = 204 + 8 = 212 -> jump to rom[53]
                                 // [Link]   x1 = 208 (복귀주소 저장)
                                 // 즉, 함수 호출과 같은 동작 수행 (caller)

        rom[52] = 32'h00500693;  // addi a3, x0, 5      
                                 // a3 = 5 (메인 코드의 다음 명령, 건너뛰어짐)

        rom[53] = 32'h00008167;  // jalr x2, 0(x1)
                                 // [Jump]   target = x1 + 0 = 208 -> jump to rom[52]
                                 // [Link]   x2 = PC + 4 = 216 (rom[54] 주소 저장)
                                 // 즉, 함수 호출과 같은 동작 수행 (callee)

        rom[54] = 32'h00010067;  // jalr x0, 0(x2)
                                 // [Jump]   target = x2 + 0 = 216 -> jump to rom[54]
                                 // [Link]   x0 = PC + 4 (버림)
                                 // 즉, x2에 저장된 복귀주소로 복귀 (return)

        rom[55] = 32'h00600693;  // addi a3, x0, 6      
                                 // a3 = 6 (복귀 후 실행되는 메인 코드)



        // Initialize remaining ROM locations
        for (int i = 56; i < 64; i = i + 1) begin
            rom[i] = 32'h00000013;  // nop
        end
    end

    assign iData = rom[iAddr[31:2]]; // ROM은 word align 형태이므로, 주소의 하위 2비트는 무시하고 사용
endmodule







