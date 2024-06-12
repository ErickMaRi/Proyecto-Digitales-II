`include "controller/controller.v"
`include "peripheral/peripheral.v"
`timescale 1ns / 1ps

module MDIO_tb;

// Declaración de señales del MDIO
reg clk, reset;
// Otras señales del MDIO...

// Instancias de los módulos controlador y periférico
controller controller_inst (
    .clk(clk),
    .reset(reset)
    // Otras señales del controlador...
);

peripheral peripheral_inst (
    .clk(clk),
    .reset(reset)
    // Otras señales del periférico...
);

// Inicialización de señales
initial begin
    $dumpfile("sim.vcd");
    $dumpvars(0, MDIO_tb);

    clk = 0;
    reset = 1;
    // Inicialización de otras señales...

    // Generación de estímulos para el MDIO...
    #40;
    $finish;
end

// Generación de reloj
always #5 clk = ~clk;

endmodule