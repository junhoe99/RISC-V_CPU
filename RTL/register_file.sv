module register_file (
    input logic clk,
    input logic rst,
    input logic [4:0] rRA1,
    input logic [4:0] rRA2,
    input logic [4:0] rWA,
    input logic reg_wr_en,
    input logic [31:0] rWData,
    output logic [31:0] rRD1,
    output logic [31:0] rRD2
);

    logic [31:0] reg_file[0:31];

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < 32; i++) begin
                reg_file[i] <= 32'd0;
            end
        end else begin
            if(reg_wr_en && rWA != 5'b00000) begin
                reg_file[rWA] <= rWData;
            end
        end
    end

    assign rRD1 = (rRA1 == 5'b00000) ? 32'h00000000 : reg_file[rRA1];
    assign rRD2 = (rRA2 == 5'b00000) ? 32'h00000000 : reg_file[rRA2];
endmodule
