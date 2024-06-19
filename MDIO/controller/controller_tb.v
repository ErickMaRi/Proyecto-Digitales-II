/************************************************************
                    Universidad de Costa Rica
                 Escuela de Ingenieria Electrica
                            IE0523
                   Circuitos Digitales 2

                        controller_tb.v

Autores: 
        Brenda Romero Solano  brenda.romero@ucr.ac.cr

Fecha: [fecha de modificación] 
    
*********************************************************** */ 


//! @title Testbench dell controlador del MDIO
/**
 * Descripción pendiente.
 */

`timescale 1ns / 1ps
`include "controller/controller.v"

module controller_tb;

    // Inputs
    reg CLK;
    reg RESET;
    reg MDIO_START;
    reg MDIO_IN;
    reg [31:0] T_DATA;

    // Construcción de la trama MDIO
    reg [1:0]operation;
    reg [4:0] phy_addr;
    reg [4:0] reg_addr;
    reg [1:0] ta;
    reg [15:0] data;

    // Outputs
    wire [15:0] RD_DATA;
    wire DATA_RDY;
    wire MDC;
    wire MDIO_OE;
    wire MDIO_OUT;

    // Instancia del controlador MDIO
    mdio_controller dut (
        .CLK(CLK),
        .RESET(RESET),
        .MDIO_START(MDIO_START),
        .T_DATA(T_DATA),
        .MDIO_IN(MDIO_IN),
        .RD_DATA(RD_DATA),
        .DATA_RDY(DATA_RDY),
        .MDC(MDC),
        .MDIO_OE(MDIO_OE),
        .MDIO_OUT(MDIO_OUT)
    );

    // Generar señal de reloj
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK; // Reloj de 100 MHz
    end

    // Inicializar y ejecutar pruebas
    initial begin
        $dumpfile("sim.vcd");
        $dumpvars(0, controller_tb);

        // Inicialización
        RESET = 1; MDIO_START = 0; MDIO_IN = 0; T_DATA = 0;
        operation = 2'b00; phy_addr = 5'b00000;
        reg_addr = 5'b00000; ta = 2'b00; data = 16'b0000000000000000;
        #10 RESET = 0;

        // Test de escritura
        phy_addr = 5'b00001;
        reg_addr = 5'b00010;
        data = 16'hABCD;
        operation = 2'b01; // Operación de escritura
        ta = 2'b00;
        MDIO_START = 1'b1;
        T_DATA = {2'b01, operation, phy_addr, reg_addr, ta, data};

        #10 MDIO_START = 1'b0; // Iniciar la operación

        // Esperar la duración de SEND
        #650  MDIO_START = 2'b0; // 640 ns para la transacción + 10 ns de margen

        // Test de lectura
        #20; // Tiempo antes de iniciar la siguiente transacción
        phy_addr = 5'b00011;
        reg_addr = 5'b00100;
        data = 16'h0000;
        operation = 2'b10; // Operación de lectura
        ta = 2'b00;
        T_DATA = {2'b01, operation, phy_addr, reg_addr, ta, data};
        MDIO_START = 1'b1;
        #10 MDIO_START = 1'b0;
        #160 MDIO_IN = 1'b1;
        #40 MDIO_IN = 1'b0;
        #80 MDIO_IN = 1'b1;
        #40 MDIO_IN = 1'b0;

        // Esperar la duración de SEND + RECEIVE
        #1290; // (640 ns * 2) para SEND + RECEIVE + 10 ns de margen

        // Conclusión
        #50; // Tiempo adicional antes de finalizar la simulación
        $display("Simulación completada.");
        $finish; 

        /*/ Monitoreo de señales para depuración
            initial begin
                $monitor("Time = %t, Operation = %b, Busy = %b, Read Data = %h",
                        $time, operation, DATA_RDY, RD_DATA);
            end
        */
    end

    

endmodule
