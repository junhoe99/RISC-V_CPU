`timescale 1ns / 1ps

module data_memory (
    input logic clk,
    input logic d_wr_en,
    input logic [31:0] dAddr,
    input logic [31:0] dWdata,
    input logic [1:0] store_size,
    input logic [1:0] load_size,  // 00: lb(8bit), 01: lh(16bit), 10: lw(32bit), 11: unsigned
    input logic [2:0] funct3,     // funct3으로 lbu/lhu 구분
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


    // Store Operation (Register -> Memory) - Byte-addressable with offset support
    // byte offset을 고려한 저장 위치 결정
    logic [1:0] byte_offset;
    assign byte_offset = dAddr[1:0];  // 하위 2비트로 word 내 byte 위치 결정
    logic [31:0] word_addr;
    assign word_addr = {dAddr[31:2], 2'b00};  // word-aligned address
    
    always_ff @(posedge clk) begin
        if (d_wr_en) begin
            case (store_size)
                2'b00: begin  // sb (8-bit store) - offset에 따라 특정 byte에 저장
                    case (byte_offset)
                        2'b00: data_mem[word_addr + 0] = dWdata[7:0];  // Byte 0 (LSB)
                        2'b01: data_mem[word_addr + 1] = dWdata[7:0];  // Byte 1
                        2'b10: data_mem[word_addr + 2] = dWdata[7:0];  // Byte 2
                        2'b11: data_mem[word_addr + 3] = dWdata[7:0];  // Byte 3 (MSB)
                    endcase
                end
                2'b01: begin  // sh (16-bit store) - offset에 따라 halfword 위치 결정
                    case (byte_offset[1])  // 하위 1비트로 halfword 위치 결정
                        1'b0: begin  // Lower halfword (bytes 1:0)
                            data_mem[word_addr + 0] = dWdata[7:0];   // byte 0 (LSB)
                            data_mem[word_addr + 1] = dWdata[15:8];  // byte 1
                        end
                        1'b1: begin  // Upper halfword (bytes 3:2)
                            data_mem[word_addr + 2] = dWdata[7:0];   // byte 2
                            data_mem[word_addr + 3] = dWdata[15:8];  // byte 3 (MSB)
                        end
                    endcase
                end
                2'b10: begin  // sw (32-bit store) - 전체 word 저장
                    data_mem[word_addr + 0] = dWdata[7:0];   // byte 0 (LSB)
                    data_mem[word_addr + 1] = dWdata[15:8];  // byte 1
                    data_mem[word_addr + 2] = dWdata[23:16]; // byte 2
                    data_mem[word_addr + 3] = dWdata[31:24]; // byte 3 (MSB)
                end
                default: begin
                    // 32-bit store as default
                    data_mem[word_addr + 0] = dWdata[7:0];
                    data_mem[word_addr + 1] = dWdata[15:8];
                    data_mem[word_addr + 2] = dWdata[23:16];
                    data_mem[word_addr + 3] = dWdata[31:24];
                end
            endcase
        end
    end


    // Load Operation (Memory -> Register) - Byte-addressable with offset support
    // byte offset을 고려한 로드 위치 결정
    always_comb begin
        case (load_size)
            2'b00: begin  // lb (8-bit signed load) - offset에 따라 특정 byte에서 로드
                case (byte_offset)
                    2'b00: dRdata = {{24{data_mem[word_addr + 0][7]}}, data_mem[word_addr + 0]};
                    2'b01: dRdata = {{24{data_mem[word_addr + 1][7]}}, data_mem[word_addr + 1]};
                    2'b10: dRdata = {{24{data_mem[word_addr + 2][7]}}, data_mem[word_addr + 2]};
                    2'b11: dRdata = {{24{data_mem[word_addr + 3][7]}}, data_mem[word_addr + 3]};
                endcase
            end
            2'b01: begin  // lh (16-bit signed load) - offset에 따라 halfword에서 로드
                case (byte_offset[1])  // 하위 1비트로 halfword 위치 결정
                    1'b0: begin  // Lower halfword (bytes 1:0)
                        dRdata = {
                            {16{data_mem[word_addr + 1][7]}},  // 부호 확장
                            data_mem[word_addr + 1],           // byte 1
                            data_mem[word_addr + 0]            // byte 0 (LSB)
                        };
                    end
                    1'b1: begin  // Upper halfword (bytes 3:2)
                        dRdata = {
                            {16{data_mem[word_addr + 3][7]}},  // 부호 확장
                            data_mem[word_addr + 3],           // byte 3 (MSB)
                            data_mem[word_addr + 2]            // byte 2
                        };
                    end
                endcase
            end
            2'b10: begin  // lw (32-bit load) - 전체 word 로드
                dRdata = {
                    data_mem[word_addr + 3],  // byte 3 (MSB)
                    data_mem[word_addr + 2],  // byte 2
                    data_mem[word_addr + 1],  // byte 1
                    data_mem[word_addr + 0]   // byte 0 (LSB)
                };
            end
            2'b11: begin  // unsigned load (lbu/lhu) - funct3으로 구분
                if (funct3 == 3'b100) begin  // lbu (8-bit unsigned)
                    case (byte_offset)
                        2'b00: dRdata = {24'h000000, data_mem[word_addr + 0]};
                        2'b01: dRdata = {24'h000000, data_mem[word_addr + 1]};
                        2'b10: dRdata = {24'h000000, data_mem[word_addr + 2]};
                        2'b11: dRdata = {24'h000000, data_mem[word_addr + 3]};
                    endcase
                end else if (funct3 == 3'b101) begin  // lhu (16-bit unsigned)
                    case (byte_offset[1])
                        1'b0: begin  // Lower halfword (bytes 1:0)
                            dRdata = {
                                16'h0000,                     // zero 확장
                                data_mem[word_addr + 1],      // byte 1
                                data_mem[word_addr + 0]       // byte 0 (LSB)
                            };
                        end
                        1'b1: begin  // Upper halfword (bytes 3:2)
                            dRdata = {
                                16'h0000,                     // zero 확장
                                data_mem[word_addr + 3],      // byte 3 (MSB)
                                data_mem[word_addr + 2]       // byte 2
                            };
                        end
                    endcase
                end else begin
                    // 기본값: 32-bit load
                    dRdata = {
                        data_mem[word_addr + 3],
                        data_mem[word_addr + 2],
                        data_mem[word_addr + 1],
                        data_mem[word_addr + 0]
                    };
                end
            end
            default: begin
                dRdata = {
                    data_mem[word_addr + 3],
                    data_mem[word_addr + 2],
                    data_mem[word_addr + 1],
                    data_mem[word_addr + 0]
                };
            end
        endcase
    end

endmodule
