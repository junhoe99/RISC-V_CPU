`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/19 14:34:03
// Design Name: 
// Module Name: tb_cpu_core
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

    
module tb ();

    logic clk = 0, rst = 1;

    RV32I_TOP U_CPU_TOP (
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;

    initial begin
        #10;
        rst = 0;

        
        // 각 클럭마다 instruction과 메모리 연산 결과 출력        
        repeat (30) begin
            @(posedge clk); 
        end
        $display("=== U-type Instruction Test End ===");
        $stop;
    end
endmodule
