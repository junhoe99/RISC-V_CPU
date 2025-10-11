`timescale 1ns / 1ps

module data_memory (
    input logic clk,
    input logic d_wr_en,
    input logic [31:0] dAddr,
    input logic [31:0] dWdata,
    input logic [1:0] store_size,
    input logic [1:0] load_size,  // 00: sb(8bit), 01: sh(16bit), 10: sw(32bit)
    output logic [31:0] dRdata
);

    logic [7:0] data_mem[0:127];  // 128 bytes (byte-addressable)

    // 메모리 초기화 - Little Endian 방식으로 32비트 워드를 4개 바이트로 분할 저장
    initial begin
        for (int i = 0; i < 32; i++) begin
            automatic logic [31:0] word_data = i + 32'h8765_4321;
            // Little Endian: LSB가 낮은 주소에 저장
            data_mem[i*4+0] = word_data[7:0];  // byte 0 (LSB)
            data_mem[i*4+1] = word_data[15:8];  // byte 1
            data_mem[i*4+2] = word_data[23:16];  // byte 2  
            data_mem[i*4+3] = word_data[31:24];  // byte 3 (MSB)
        end
    end


    // Store Operation (Register -> Memory) - Byte-addressable
    always_ff @(posedge clk) begin
        if (d_wr_en) begin
            case (store_size)
                2'b00: begin  // sb (8-bit store)
                    data_mem[dAddr] = dWdata[7:0];
                end
                2'b01: begin  // sh (16-bit store)
                    // Little Endian: LSB를 낮은 주소에 저장
                    data_mem[dAddr]   = dWdata[7:0];  // byte 0 (LSB)
                    data_mem[dAddr+1] = dWdata[15:8];  // byte 1 (MSB)
                end
                2'b10: begin  // sw (32-bit store)
                    // Little Endian: LSB를 낮은 주소에 저장
                    data_mem[dAddr]   = dWdata[7:0];  // byte 0 (LSB)
                    data_mem[dAddr+1] = dWdata[15:8];  // byte 1
                    data_mem[dAddr+2] = dWdata[23:16];  // byte 2  
                    data_mem[dAddr+3] = dWdata[31:24];  // byte 3 (MSB)
                end
                default: begin
                    // 32-bit store as default
                    data_mem[dAddr]   = dWdata[7:0];
                    data_mem[dAddr+1] = dWdata[15:8];
                    data_mem[dAddr+2] = dWdata[23:16];
                    data_mem[dAddr+3] = dWdata[31:24];
                end
            endcase
        end
    end


    // Load Operation (Memory -> Register) - Byte-addressable
    // Little Endian: 4개 바이트를 32비트 워드로 재구성

    // LB, LH, LW에 따른 데이터 로드 및 extension 처리
    always_comb begin
        case (load_size)
            2'b00: begin  // lb (8-bit load)
                // 부호 확장
                dRdata = {{24{data_mem[dAddr][7]}}, data_mem[dAddr]};
            end
            2'b01: begin  // lh (16-bit load)
                // 부호 확장
                dRdata = {
                    {16{data_mem[dAddr+1][7]}},
                    data_mem[dAddr+1],
                    data_mem[dAddr]
                };
            end
            2'b10: begin  // lw (32-bit load)
                dRdata = {
                    data_mem[dAddr+3],
                    data_mem[dAddr+2],
                    data_mem[dAddr+1],
                    data_mem[dAddr]
                };
            end
            default: begin
                dRdata = {
                    data_mem[dAddr+3],
                    data_mem[dAddr+2],
                    data_mem[dAddr+1],
                    data_mem[dAddr]
                };
            end
        endcase
    end

endmodule
