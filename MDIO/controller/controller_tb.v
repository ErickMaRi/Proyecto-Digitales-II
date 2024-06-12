`timescale 1ns / 1ps
`include "controller/controller.v"

module controller_tb;

    // Inputs
    reg clk;
    reg reset;
    reg mdio_in;
    reg [4:0] phy_addr;
    reg [4:0] reg_addr;
    reg [15:0] write_data;
    reg start;
    reg operation;

    // Outputs
    wire mdio_out;
    wire mdio_oe;
    wire mdc;
    wire [15:0] read_data;
    wire busy;

    // Instancia del controlador MDIO
    mdio_controller uut (
        .clk(clk),
        .reset(reset),
        .mdio_in(mdio_in),
        .mdio_out(mdio_out),
        .mdio_oe(mdio_oe),
        .mdc(mdc),
        .phy_addr(phy_addr),
        .reg_addr(reg_addr),
        .write_data(write_data),
        .read_data(read_data),
        .start(start),
        .operation(operation),
        .busy(busy)
    );

    // Generar señal de reloj
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Reloj de 100 MHz
    end

    // Inicializar y ejecutar pruebas
    initial begin
        $dumpfile("sim.vcd");
        $dumpvars(0, controller_tb);

        // Inicialización
        reset = 1; mdio_in = 0; start = 0; operation = 0;
        phy_addr = 0; reg_addr = 0; write_data = 0;
        #10 reset = 0;

        // Test de escritura
        phy_addr = 5'b00001;
        reg_addr = 5'b00010;
        write_data = 16'hABCD;
        operation = 0; // Operación de escritura
        start = 1;
        #10; start = 0; // Iniciar la operación

        // Esperar la duración de SEND
        #650; // 640 ns para la transacción + 10 ns de margen

        // Test de lectura
        #20; // Tiempo antes de iniciar la siguiente transacción
        phy_addr = 5'b00011;
        reg_addr = 5'b00100;
        operation = 1; // Operación de lectura
        start = 1;
        #10; start = 0;

        // Esperar la duración de SEND + RECEIVE
        #1290; // (640 ns * 2) para SEND + RECEIVE + 10 ns de margen

        // Conclusión
        #50; // Tiempo adicional antes de finalizar la simulación
        $display("Simulación completada.");
        $finish;
    end

    // Monitoreo de señales para depuración
    initial begin
        $monitor("Time = %t, Operation = %b, Busy = %b, Read Data = %h",
                 $time, operation, busy, read_data);
    end

endmodule
