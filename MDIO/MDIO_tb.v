/************************************************************
                    Universidad de Costa Rica
                 Escuela de Ingenieria Electrica
                            IE0523
                   Circuitos Digitales 2

                        MDIO_tb.v

Autores: 
        Brenda Romero Solano  brenda.romero@ucr.ac.cr

Fecha: [fecha de modificación] 
    
*********************************************************** */ 


//! @title Testbench dell controlador del MDIO
/**
 * Descripción pendiente.
 */
 
`include "controller/controller.v"
`include "peripheral/peripheral.v"
`timescale 1ns / 1ps

module MDIO_tb;

// Declaración de señales del MDIO
// Inputs
reg CLK;
reg RESET;
reg MDIO_START;
reg [31:0] T_DATA;

// Outputs
wire [15:0] RD_DATA;
wire DATA_RDY;
wire MDC;
wire MDIO_OE;
wire MDIO_OUT;

wire [4:0] ADDR; 
wire [15:0] WR_DATA;   
wire MDIO_DONE;
wire WR_STB;
wire MDIO_IN_PERIPHERAL;


// Instancias de los módulos controlador y periférico
mdio_controller controller_inst (
        .CLK(CLK),
        .RESET(RESET),
        .MDIO_START(MDIO_START),
        .T_DATA(T_DATA),
        .MDIO_IN(MDIO_IN_PERIPHERAL),
        .RD_DATA(RD_DATA),
        .DATA_RDY(DATA_RDY),
        .MDC(MDC),
        .MDIO_OE(MDIO_OE),
        .MDIO_OUT(MDIO_OUT)
);

peripheral peripheral_inst (
    .RESET(RESET),
    .RD_DATA(RD_DATA),
    .MDC(MDC),
    .MDIO_OE(MDIO_OE),
    .MDIO_OUT(MDIO_OUT),
    .ADDR(ADDR),
    .WR_DATA(WR_DATA),
    .MDIO_DONE(MDIO_DONE),
    .WR_STB(WR_STB),
    .MDIO_IN(MDIO_IN_PERIPHERAL)
);

// Inicialización de señales
initial begin
    $dumpfile("sim.vcd");
    $dumpvars(0, MDIO_tb);

    CLK = 0;
    RESET = 1;
    // Inicialización de otras señales...

    // Generación de estímulos para el MDIO...
    #40;
    $finish;
end

// Generación de reloj
always #5 CLK = ~CLK;

endmodule