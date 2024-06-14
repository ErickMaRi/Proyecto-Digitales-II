// PHY_tb.v
// ¡¡¡ REQUIERE SYSTEM VERILOG !!!
// POR LO QUE SE USA EL FLAG -g2012
// iverilog -g2012 -o sim  PHY.v PHY_tb.v

`timescale 1ns/1ps

module PHY_tb;
    reg clk;
    reg reset;
    reg [4:0] ADDR;
    reg [15:0] WR_DATA;
    reg WR_STB;
    wire [15:0] RD_DATA;

    // Instancia del módulo PHY
    PHY dut (
        .clk(clk),
        .reset(reset),
        .ADDR(ADDR),
        .WR_DATA(WR_DATA),
        .WR_STB(WR_STB),
        .RD_DATA(RD_DATA)
    );

    // Generación de reloj
    always #5 clk = ~clk;

    // Inicialización de variables
    initial begin
        $dumpfile("sim.vcd");
        $dumpvars(0, PHY_tb);

        clk = 0;
        reset = 1;
        ADDR = 0;
        WR_DATA = 0;
        WR_STB = 0;

        #10 reset = 0;  // Desactivar reset

        // Prueba de escritura en todas las direcciones
        for (integer i = 0; i < 32; i = i + 1) begin
            @(posedge clk) ADDR = i; WR_DATA = i * 256; WR_STB = 1;
            @(posedge clk) WR_STB = 0;
        end

        // Prueba de lectura de todas las direcciones
        for (integer i = 0; i < 32; i = i + 1) begin
            @(posedge clk) ADDR = i;
            @(posedge clk) $display("Lectura de la dirección %d: %h", ADDR, RD_DATA);
        end

        // Fin de la simulación
        #10 $finish;
    end
endmodule