/************************************************************
                    Universidad de Costa Rica
                 Escuela de Ingenieria Electrica
                            IE0523
                   Circuitos Digitales 2

                        controller_tester.v

Autores: 
        Brenda Romero Solano  brenda.romero@ucr.ac.cr

Fecha: 23/06/2024
    
*********************************************************** */ 


//! @title Tester del controlador MDIO
/**
 * Módulo de prueba del controlador.
 * Este módulo se utiliza para probar el funcionamiento del controlador MDIO.
 * Proporciona señales de entrada y salida para simular la comunicación con un dispositivo MDIO.
 * El módulo genera las señales de control necesarias y verifica las respuestas del controlador.
 */
 
 `timescale 1ns / 1ps

 module controller_tester(
    output reg CLK, 	        // Reloj de sistema
    output reg RESET,           // Señal de RESET
    output reg MDIO_START,      // Señal de inicio de operación MDIO
    output reg MDIO_IN,         // Señal de entrada de datos MDIO
    output reg [31:0] T_DATA,   // Datos de transmisión MDIO
    input wire [15:0] RD_DATA,  // Datos de lectura MDIO
    input wire DATA_RDY,        // Señal de datos listos MDIO
    input wire MDC,             // Señal de reloj MDIO
    input wire MDIO_OE,         // Señal de habilitación de salida MDIO
    input wire MDIO_OUT         // Señal de salida MDIO
 );
    // Variables para construir la trama MDIO
    reg [1:0]operation;
    reg [4:0] phy_addr;
    reg [4:0] reg_addr;
    reg [1:0] ta;
    reg [15:0] data;
    
     // Generar señal de reloj
     initial begin
         CLK = 0;
         forever #5 CLK = ~CLK; // Reloj de 100 MHz
     end
 
     // Inicializar y ejecutar pruebas

     initial begin
 
         // Inicialización
         RESET = 0; MDIO_START = 0; MDIO_IN = 0; T_DATA = 0;
         operation = 2'b00; phy_addr = 5'b00000;
         reg_addr = 5'b00000; ta = 2'b00; data = 16'b0000000000000000;
         #10 RESET = 1;
 
// Prueba 01 - Test de escritura

         phy_addr = 5'b00001;
         reg_addr = 5'b00010;
         data = 16'h3C33;
         operation = 2'b01; // Operación de escritura
         ta = 2'b00;
         MDIO_START = 1'b1;
         T_DATA = {2'b01, operation, phy_addr, reg_addr, ta, data};
 
         #10 MDIO_START = 1'b0; // Iniciar la operación
 
         // Esperar la duración de SEND
         #650  MDIO_START = 2'b0; // 640 ns para la transacción + 20 ns de margen
         #20; // Tiempo antes de iniciar la siguiente transacción

// Prueba 02 - Test de lectura

         phy_addr = 5'b00011;
         reg_addr = 5'b00100;
         data = 16'h0000;
         operation = 2'b10; // Operación de lectura
         ta = 2'b00;
         T_DATA = {2'b01, operation, phy_addr, reg_addr, ta, data};
         MDIO_START = 1'b1;
         #10 MDIO_START = 1'b0;
         
         // Envio de datos de lectura  
         #325 MDIO_IN = 1'b1;
         #40 MDIO_IN = 1'b0;
         #80 MDIO_IN = 1'b1;
         #40 MDIO_IN = 1'b0;
         #40 MDIO_IN = 1'b1;
         #40 MDIO_IN = 1'b0;
         #20 MDIO_IN = 1'b1;
         #50 MDIO_IN = 1'b0;
 
// Prueba 03 - Test reinicio

         #180 RESET= 0; // (640 ns * 2) para SEND + RECEIVE + 10 ns de margen

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
 