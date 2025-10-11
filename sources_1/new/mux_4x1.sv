`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/25 16:29:49
// Design Name: 
// Module Name: mux_4x1
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


module mux_4x1(
    input logic [1:0] sel,
    input logic [31:0] in0,
    input logic [31:0] in1,
    input logic [31:0] in2,
    input logic [31:0] in3,
    output logic [31:0] out
    );

    always_comb begin
        case (sel)
            2'b00: out = in0;
            2'b01: out = in1;
            2'b10: out = in2;
            2'b11: out = in3;
            default: out = 32'b0; // 기본값 설정
        endcase
    end

endmodule