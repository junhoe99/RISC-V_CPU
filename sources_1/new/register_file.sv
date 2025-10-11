`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/19 11:40:05
// Design Name: 
// Module Name: register_file
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


module register_file (
    input logic clk,
    input logic rst,  // reset 신호 추가
    //Inputs
    input logic [4:0] rRA1,   //Read address가 5bit인 이유? 32개의 레지스터를 5bit로 표현 가능
    input logic [4:0] rRA2,
    input logic [4:0] rWA,
    input logic       reg_wr_en,
    input logic [31:0] rWData,
    //Outputs
    output logic [31:0] rRD1,
    output logic [31:0] rRD2
);

    logic [31:0] reg_file[0:31];  //32개의 32bit 레지스터. RISC-V는 일반적으로 32개의 32비트 레지스터를 가짐

    //Write operation과 Reset 로직 결합
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset 시 레지스터 초기화 (S-type 비트 절단 효과 확인용)
            reg_file[0] <= 32'h00000000;  // x0: 항상 0
            reg_file[1] <= 32'h00000001;  
            reg_file[2] <= 32'h00000002; 
            reg_file[3] <= 32'h00000003; 
            reg_file[4] <= 32'h00000004; 
            reg_file[5] <= 32'h00000005; 
            reg_file[6] <= 32'h12345678;  // x6: 모든 S-type 명령어가 사용할 공통 데이터
            reg_file[7] <= 32'h00000007;  
            reg_file[8] <= 32'h00000008;  
            reg_file[9] <= 32'h00000009; 
            reg_file[10] <= 32'h0000000A;  
            reg_file[11] <= 32'h0000000B;
            reg_file[12] <= 32'h0000000C;
            reg_file[13] <= 32'h0000000D;
            reg_file[14] <= 32'h0000000E;
            reg_file[15] <= 32'h0000000F;
            reg_file[16] <= 32'h00000010;
            reg_file[17] <= 32'h00000011;
            reg_file[18] <= 32'h00000012;
            reg_file[19] <= 32'h00000013;
            reg_file[20] <= 32'h00000014;
            reg_file[21] <= 32'h00000015;
            reg_file[22] <= 32'h00000016;
            reg_file[23] <= 32'h00000017;
            reg_file[24] <= 32'h00000018;
            // 나머지 레지스터들은 0으로 초기화
            for (int i = 25; i < 32; i++) begin
                reg_file[i] <= 32'd0;
            end
        end else begin
            // 정상 동작 시 write operation
            if(reg_wr_en && rWA != 5'b00000) begin  // x0 레지스터에는 쓰기 금지
                reg_file[rWA] <= rWData;
            end
        end
    end


    //Read operation - x0는 항상 0 반환
    assign rRD1 = (rRA1 == 5'b00000) ? 32'h00000000 : reg_file[rRA1];
    assign rRD2 = (rRA2 == 5'b00000) ? 32'h00000000 : reg_file[rRA2];
endmodule
