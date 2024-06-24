/************************************************************
                    Universidad de Costa Rica
                 Escuela de Ingenieria Electrica
                            IE0523
                   Circuitos Digitales 2

                        controller_tb.v

Autores: 
        Brenda Romero Solano  brenda.romero@ucr.ac.cr

Fecha: 23/06/2024  
*********************************************************** */ 
/**
 * @title Testbench del controlador del MDIO
 * 
 * Este es el testbench del controlador del MDIO. El MDIO (Management Data Input/Output)
 * es un estándar de comunicación utilizado en sistemas de comunicación de alta velocidad
 * para la configuración y supervisión de dispositivos de red. Este testbench se utiliza 
 * para probar el funcionamiento del controlador MDIO.
 * El testbench instancia el controlador MDIO (mdio_controller) y el tester del controlador
 * (controller_tester) para realizar las pruebas.
 * 
 * El testbench también incluye una inicialización para generar un archivo VCD 
 * (Value Change Dump) y guardar las variables del testbench en ese archivo.
 */

`include "controller/controller.v"
`include "controller/controller_tester.v"

module controller_tb;

    // Inputs del controlador MDIO
    wire CLK, RESET, MDIO_START, MDIO_IN;
    wire [31:0] T_DATA;

    // Outputs del controlador MDIO
    wire [15:0] RD_DATA;
    wire DATA_RDY, MDC, MDIO_OE, MDIO_OUT;

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
     
    // Instancia del tester del controlador MDIO
    controller_tester tester (
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
    
    // Inicializar y ejecutar pruebas
    initial begin
        $dumpfile("sim.vcd");
        $dumpvars(0, controller_tb);
    end

endmodule
