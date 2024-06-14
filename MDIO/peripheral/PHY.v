// PHY.v
module PHY (
    input wire clk,
    input wire reset,
    input wire [4:0] ADDR,
    input wire [15:0] WR_DATA,
    input wire WR_STB,
    output reg [15:0] RD_DATA
);

    // Memoria interna del PHY
    reg [15:0] memory [0:31];

    // Reinicio de la memoria
    always @(posedge reset) begin
        integer i;
        for (i = 0; i < 32; i = i + 1) begin
            memory[i] <= 16'h0000;
        end
    end

    // Escritura en la memoria
    always @(posedge clk) begin
        if (WR_STB) begin
            memory[ADDR] <= WR_DATA;
        end
    end

    // Lectura de la memoria
    always @(posedge clk) begin
        RD_DATA <= memory[ADDR];
    end

endmodule
