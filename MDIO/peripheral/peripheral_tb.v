/************************************************************
                    Universidad de Costa Rica
                 Escuela de Ingenieria Electrica
                            IE0523
                   Circuitos Digitales 2

                        peripheral_tb.v

Autores: 
        Brenda Romero Solano  brenda.romero@ucr.ac.cr

Fecha: 30/6/2024
    
*********************************************************** */ 


//! @title Testbench del periférico del MDIO
/**Acá esta el código por si lo necesitas
 * Descripción pendiente.
 */
/*module peripheral_tb;

// Declaración de señales
 // Inputs
    reg RESET;
    reg [15:0] RD_DATA;
    reg MDC;
    reg MDIO_OE;
    reg MDIO_OUT;
    // Outputs
    wire [4:0] ADDR; 
    wire [15:0] WR_DATA;   
    wire MDIO_DONE;
    wire WR_STB;
    wire MDIO_IN;

// Instancia del módulo bajo prueba
peripheral dut (
    .RESET(RESET),
    .RD_DATA(RD_DATA),
    .MDC(MDC),
    .MDIO_OE(MDIO_OE),
    .MDIO_OUT(MDIO_OUT),
    .ADDR(ADDR),
    .WR_DATA(WR_DATA),
    .MDIO_DONE(MDIO_DONE),
    .WR_STB(WR_STB),
    .MDIO_IN(MDIO_IN)
);

// Generador de reloj
always #5 MDC = ~MDC;

// Memoria para almacenar datos
reg [15:0] memoria [0:31];

// Tarea para inicializar las señales y la memoria
task inicializar;
begin
    MDC = 0;
    RESET = 1;
    MDIO_OUT = 0;
    MDIO_OE = 0;
    RD_DATA = 0;
    #10; // Esperar un ciclo de reloj
    RESET = 0;
    #10; // Esperar un ciclo de reloj
    RESET = 1;
    // Inicializar la memoria
    for (integer i = 0; i < 32; i = i + 1) begin
        memoria[i] = 16'h0000;
    end
end
endtask

// Tarea para realizar una transacción de escritura
task prueba_escritura;
    input [4:0] direccion;
    input [15:0] datos;
begin
    MDIO_OUT = 1; // Bit de inicio
    #10; // Esperar un ciclo de reloj
    MDIO_OE = 1;
    MDIO_OUT = 1; // Bit de operación (escritura)
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = direccion[4]; // Dirección
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = direccion[3];
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = direccion[2];
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = direccion[1];
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = direccion[0];
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = datos[15]; // Datos
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = datos[14];
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = datos[13];
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = datos[12];
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = datos[11];
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = datos[10];
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = datos[9];
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = datos[8];
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = datos[7];
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = datos[6];
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = datos[5];
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = datos[4];
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = datos[3];
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = datos[2];
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = datos[1];
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = datos[0];
    #10; // Esperar un ciclo de reloj
    MDIO_OE = 0;
end
endtask

// Tarea para realizar una transacción de lectura
task prueba_lectura;
    input [4:0] direccion;
begin
    MDIO_OUT = 1; // Bit de inicio
    #10; // Esperar un ciclo de reloj
    MDIO_OE = 1;
    MDIO_OUT = 0; // Bit de operación (lectura)
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = direccion[4]; // Dirección
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = direccion[3];
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = direccion[2];
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = direccion[1];
    #10; // Esperar un ciclo de reloj
    MDIO_OUT = direccion[0];
    #10; // Esperar un ciclo de reloj
    MDIO_OE = 0;
end
endtask

// Bloque inicial
initial begin
    $dumpfile("sim.vcd");
    $dumpvars(0, peripheral_tb);
    inicializar();

    // Prueba de transacción de escritura
    memoria[16'h10] = 16'h1234;
    prueba_escritura(5'h10, 16'habcd);
    #1; // Esperar un ciclo de reloj adicional para que se complete la escritura

    // Prueba de transacción de lectura
    RD_DATA = memoria[5'h10];
    prueba_lectura(5'h10);

    // Prueba de transacción de escritura con dirección inválida
    prueba_escritura(5'h20, 16'hfeed);
    if (memoria[5'h20] !== 16'h0000) begin
        $display("Error: La escritura en una dirección inválida modificó la memoria");
    end

    // Prueba de transacción de lectura con dirección inválida
    prueba_lectura(5'h1f);
    if (MDIO_IN !== 16'h0000) begin
        $display("Error: La lectura desde una dirección inválida no devolvió cero");
    end

    // Prueba de transacción de escritura con datos inválidos
    prueba_escritura(5'h11, 16'hxxxx);
    if (memoria[5'h11] !== 16'h0000) begin
        $display("Error: La escritura con datos inválidos modificó la memoria");
    end

    // Otras pruebas...

    $finish; // Terminar la simulación
end

// Bloque always para monitorear la salida RD_DATA
always @(posedge MDC) begin
    if (MDIO_DONE && !WR_STB) begin
        #2; // Delay de 2 ciclos de reloj
        if (RD_DATA !== memoria[ADDR]) begin
            $display("Error: Dato leído incorrecto. Dirección: %h, Esperado: %h, Obtenido: %h", ADDR, memoria[ADDR], RD_DATA);
        end else begin
            $display("Lectura exitosa. Dirección: %h, Dato: %h", ADDR, RD_DATA);
        end
    end
end

endmodule
*/

 `include "peripheral/peripheral.v"
 `include "peripheral/peripheral_tester.v"

/**
 * @title Testbench del periférico del MDIO
 * 
 * Este es el testbench del periférico del MDIO. El MDIO (Management Data Input/Output)
 * es un estándar de comunicación utilizado en sistemas de comunicación de alta velocidad
 * para la configuración y supervisión de dispositivos de red. Este testbench se utiliza 
 * para probar el funcionamiento del periférico MDIO.
 * El testbench instancia el periférico MDIO  y el tester del periférico para realizar las pruebas.
 * 
 * El testbench también incluye una inicialización para generar un archivo VCD 
 * (Value Change Dump) y guardar las variables del testbench en ese archivo.
 */
 module peripheral_tb;
 
     // Inputs del periférico MDIO
    wire RESET,MDC,MDIO_OE,MDIO_OUT;          
    wire [15:0] RD_DATA; 
    wire [4:0] ADDR;      
    wire [15:0] WR_DATA; 
    wire MDIO_DONE,WR_STB,MDIO_IN;     
 
     // Instancia del periférico MDIO
    peripheral dut (
         .RESET(RESET),
         .RD_DATA(RD_DATA),
         .MDC(MDC),
         .MDIO_OE(MDIO_OE),
         .MDIO_OUT(MDIO_OUT),
         .ADDR(ADDR),
         .WR_DATA(WR_DATA),
         .MDIO_DONE(MDIO_DONE),
         .WR_STB(WR_STB),
         .MDIO_IN(MDIO_IN)
     );
      
     // Instancia del tester del periférico MDIO
     peripheral_tester tester (
         .RESET(RESET),
         .RD_DATA(RD_DATA),
         .MDC(MDC),
         .MDIO_OE(MDIO_OE),
         .MDIO_OUT(MDIO_OUT),
         .ADDR(ADDR),
         .WR_DATA(WR_DATA),
         .MDIO_DONE(MDIO_DONE),
         .WR_STB(WR_STB),
         .MDIO_IN(MDIO_IN)
     );
     
     // Inicializar y ejecutar pruebas
     initial begin
         $dumpfile("sim.vcd");
         $dumpvars(0, peripheral_tb);
     end
 
 endmodule
 