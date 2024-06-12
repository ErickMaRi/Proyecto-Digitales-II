`include "peripheral/peripheral.v"
`timescale 1ns / 1ps

module peripheral_tb;

// Declaración de señales del periférico
reg clk, reset;
// Otras señales del periférico...

// Instancia del módulo periférico
peripheral peripheral_inst (
    .clk(clk),
    .reset(reset)
    // Otras señales del periférico...
);

// Inicialización de señales
initial begin
    $dumpfile("sim.vcd");
    $dumpvars(0, peripheral_tb);

    clk = 0;
    reset = 1;
    // Inicialización de otras señales...

    // Generación de estímulos para el periférico...
    #40;
    $finish;
end

// Generación de reloj
always #5 clk = ~clk;



endmodule