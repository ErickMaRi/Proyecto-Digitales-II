`timescale 1ns / 1ps
`include "controller/controller.v"

module controller_tb;
    // Entradas del controlador
    reg clk, reset;
    reg mdio_out, mdio_oe;
    reg [15:0] rd_data;

    // Salidas del controlador
    wire mdio_done;
    wire [15:0] mdio_in;
    wire [4:0] addr;
    wire [15:0] wr_data;
    wire wr_stb;

    // Instancia del módulo controlador
    controller controller_inst(
        .clk(clk),
        .reset(reset),
        .mdio_out(mdio_out),
        .mdio_oe(mdio_oe),
        .mdio_done(mdio_done),
        .mdio_in(mdio_in),
        .addr(addr),
        .wr_data(wr_data),
        .rd_data(rd_data),
        .wr_stb(wr_stb)
    );

    // Inicialización de señales
    initial begin
        $dumpfile("sim.vcd");
        $dumpvars(0, controller_tb);
    end

    // Generación de reloj
    always #5 clk = ~clk;

    // Tarea para imprimir el estado de las señales
    task print_signals;
        begin
            $display("Time: %0t", $time);
            $display("State: %b, mdio_done: %b, mdio_in: %h, addr: %d, wr_data: %h, wr_stb: %b",
                     controller_inst.state, mdio_done, mdio_in, addr, wr_data, wr_stb);
        end
    endtask

    // Pruebas según el protocolo MDIO cláusula 22 (IEEE 802.3)
    initial begin
        clk = 0;
        reset = 1;
        mdio_out = 0;
        mdio_oe = 0;
        rd_data = 0;
        // Prueba 1: Inicialización y reset
        print_signals;

        // Esperar un tiempo para permitir que el controlador se reinicie
        #50;
        #10 reset = 0;
        // Prueba 2: Transacción de Escritura válida
        mdio_oe = 1;
        mdio_out = 1; // Código de operación = 01 (Escritura)
        #10;
        mdio_out = 0; // Reservado
        repeat (5) #10 mdio_out = 0; // Reservado
        mdio_out = 4'b0001; // Dirección del PHY = 1
        #10;
        mdio_out = 5'b00101; // Dirección del Registro = 5
        #10;
        mdio_out = 16'habcd; // Datos de Escritura
        repeat (16) #10 mdio_out = ~mdio_out;
        #100; // Esperar un tiempo para que la transacción se complete
        print_signals;

        // Prueba 3: Transacción de Lectura válida
        mdio_oe = 1;
        mdio_out = 0; // Código de operación = 00 (Lectura)
        #10;
        mdio_out = 0; // Reservado
        repeat (5) #10 mdio_out = 0; // Reservado
        mdio_out = 4'b0010; // Dirección del PHY = 2
        #10;
        mdio_out = 5'b01000; // Dirección del Registro = 8
        #10;
        mdio_out = 16'h0000; // Sin usar para Lectura
        repeat (16) #10 mdio_out = ~mdio_out;
        rd_data = 16'hfeed; // Datos de Lectura
        #100; // Esperar un tiempo para que la transacción se complete
        print_signals;

        // Prueba 4: Transacción de Escritura inválida (dirección de registro fuera de rango)
        mdio_oe = 1;
        mdio_out = 1; // Código de operación = 01 (Escritura)
        #10;
        mdio_out = 0; // Reservado
        repeat (5) #10 mdio_out = 0; // Reservado
        mdio_out = 4'b0011; // Dirección del PHY = 3
        #10;
        mdio_out = 5'b11111; // Dirección del Registro = 31 (fuera de rango)
        #10;
        mdio_out = 16'hffff; // Datos de Escritura
        repeat (16) #10 mdio_out = ~mdio_out;
        #100; // Esperar un tiempo para que la transacción se complete
        print_signals;

        // Prueba 5: Transacción de Lectura inválida (dirección de PHY fuera de rango)
        mdio_oe = 1;
        mdio_out = 0; // Código de operación = 00 (Lectura)
        #10;
        mdio_out = 0; // Reservado
        repeat (5) #10 mdio_out = 0; // Reservado
        mdio_out = 4'b1111; // Dirección del PHY = 15 (fuera de rango)
        #10;
        mdio_out = 5'b00111; // Dirección del Registro = 7
        #10;
        mdio_out = 16'h0000; // Sin usar para Lectura
        repeat (16) #10 mdio_out = ~mdio_out;
        rd_data = 16'hcafe; // Datos de Lectura
        #100; // Esperar un tiempo para que la transacción se complete
        print_signals;

        // Esperar un tiempo adicional para permitir que se complete la simulación
        #1000;
        $finish;
    end

endmodule