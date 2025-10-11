`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/22 11:24:47
// Design Name: 
// Module Name: RV32I_TOP
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


module RV32I_TOP(
    input logic clk,
    input logic rst
    );

    logic [31:0] w_iData, w_iAddr;
    logic [3:0] w_ALU_Controls;
    logic w_wr_en;
    logic [31:0] w_dAddr, w_dWdata;
    logic [1:0] w_store_size;
    logic [31:0] w_dRdata;
    logic [1:0] w_load_size; // LW 명령어에 해당하는 load_size 설정
  

    instruction_memory U_IM (
        .iAddr(w_iAddr),
        .iData(w_iData)
    );

    cpu_core U_CPU (
        .clk(clk),
        .rst(rst),
        .iData(w_iData),
        .iAddr(w_iAddr),
        .dRdata(w_dRdata),
        .d_wr_en(w_wr_en),
        .dAddr(w_dAddr),
        .dWdata(w_dWdata),
        .store_size(w_store_size),
        .load_size(w_load_size) // LW 명령어에 해당하는 load_size 설정
    );

    data_memory U_DM (
        .clk(clk),
        .d_wr_en(w_wr_en),
        .dAddr(w_dAddr),
        .dWdata(w_dWdata),
        .store_size(w_store_size),
        .load_size(w_load_size), // LW 명령어에 해당하는 load_size 설정
        .dRdata(w_dRdata)
    );

endmodule
