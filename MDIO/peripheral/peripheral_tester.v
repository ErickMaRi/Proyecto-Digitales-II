/************************************************************
                    Universidad de Costa Rica
                 Escuela de Ingenieria Electrica
                            IE0523
                   Circuitos Digitales 2

                        peripheral_tester.v

Autores: 
        Brenda Romero Solano  brenda.romero@ucr.ac.cr

Fecha: 30/6/2024
    
*********************************************************** */ 


//! @title Tester del controlador MDIO
/**
 * El módulo peripheral_tester es un componente diseñado para probar y verificar
 * el funcionamiento del controlador MDIO en un sistema digital. Este módulo simula
 * las operaciones de escritura y lectura en el bus MDIO, generando las señales
 * necesarias para comunicarse con un dispositivo periférico. Además, permite
 * reiniciar el controlador y monitorear las señales relevantes para depurar y
 * analizar el comportamiento del sistema.
 */
 
 `timescale 1ns / 1ps

 module peripheral_tester(
    output reg RESET,           // Señal de RESET
    output reg [15:0] RD_DATA,  // Datos MDIO leídos
    output reg MDC,             // Señal de reloj del protocolo MDIO
    output reg MDIO_OE,         // Señal de habilitación de salida MDIO_OUT
    output reg MDIO_OUT,        // Señal de datos MDIO enviados
    input wire [4:0] ADDR,      // Dirección
    input wire [15:0] WR_DATA,  // Datos de escritura
    input wire MDIO_DONE,      // Señal de finalización de transacción MDIO
    input wire WR_STB,         // Señal de escritura
    input wire MDIO_IN          // Datos MDIO recibidos
 );    
     // Generar señal de reloj
     initial begin
         MDC = 0;
         forever #5 MDC = ~MDC; // Reloj de 100 MHz
     end
 
     // Inicializar y ejecutar pruebas

     initial begin
 
         // Inicialización
        RESET = 0; 
        RD_DATA = 16'b0; 
        MDIO_OE = 0;  
        MDIO_OUT = 0;
        #15 RESET = 1;
 
// Prueba 01 - Test de escritura ¿cuando envio la info de ADDR?
         MDIO_OE = 1'b1;
         //Bits de inicio
         MDIO_OUT = 0;
         #10 MDIO_OUT = 1'b1; // Iniciar la trama
         #10 MDIO_OUT = 1'b0;
         #10 MDIO_OUT = 1'b1;
         #10 MDIO_OUT = 1'b0;
         #60 MDIO_OUT = 1'b1;
         #20 MDIO_OUT = 1'b0;
         #30 MDIO_OUT = 1'b1;
         #80 MDIO_OUT = 1'b0;
         #50 MDIO_OUT = 1'b1;
         #40 MDIO_OE = 1'b0;
         MDIO_OUT = 1'b0;
         #70; // Tiempo antes de iniciar la siguiente transacción

// Prueba 02 - Test de lectura

         MDIO_OE = 1'b1;
         MDIO_OUT = 0;
         #10 MDIO_OUT = 1'b1; // Iniciar la trama
         #10 MDIO_OUT = 1'b1;
         #10 MDIO_OUT = 1'b0;
         #10 MDIO_OUT = 1'b0;
         #60 MDIO_OUT = 1'b1;
         #20 MDIO_OUT = 1'b0;
         #20 MDIO_OUT = 1'b1;
         #10 MDIO_OUT = 1'b0;
         RD_DATA = 16'b1010101010101011;
         MDIO_OE = 1'b0;
         #180; // Tiempo antes de iniciar la siguiente transacción
 
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