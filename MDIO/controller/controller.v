/************************************************************
                    Universidad de Costa Rica
                 Escuela de Ingenieria Electrica
                            IE0523
                   Circuitos Digitales 2

                        controller.v

Autores: 
        Brenda Romero Solano  brenda.romero@ucr.ac.cr

Fecha: [fecha de modificación] 
    
*********************************************************** */ 


//! @title Controlador MDIO
/**
 * Descripción pendiente.
 */

`timescale 1ns / 1ps


module mdio_controller(
    input wire clk,             // Reloj de sistema
    input wire reset,           // Señal de reset
    input wire mdio_start,      // Señal de inicio de  una operación
    input wire [31:0] t_data,   // Señal de datos de entrada
    input wire mdio_in,         // Señal de datos MDIO recibidos
    output reg [15:0] rd_data,  // Datos MDIO leídos
    output reg data_rdy         // Señal de datos listos
    output reg mdc              // Señal de reloj del protocolo MDIO
    output reg mdio_oe,         // Señal de habilitación de salida mdio_out
    output reg mdio_out         // Señal de datos MDIO enviados
);

// Estados del controlador MDIO
localparam IDLE = 0,          // Espera una transacción MDIO.
           START = 1,         // inicio de la trama (01).
           OP_CODE = 2,       // Determina si la operación es lectura (10) o escritura (01).
           PHY_ADDR = 3,      // Carga la dirección del dispositivo PHY en address_reg.
           REG_ADDR = 4,      // Carga la dirección del registro en address_reg.
           TURNAROUND = 5,    // Espera cambio de control del bus.
           WRITE_DATA = 6,    // Envía los datos seriales (en escritura).
           READ_DATA = 7;     // Recibe los datos seriales (en lectura).

reg [31:0] address_reg; // Dirección del dispositivo PHY y el registro a leer/escribir
reg [15:0] data_reg;    // Registro que almacena los datos a enviar o recibir

// Estados del controlador MDIO
reg [2:0] state;
reg [2:0] next_state;

// Generación del reloj MDIO (MDC)
always @(posedge clk) begin
    if (reset) begin
        mdc <= 0;
    end else begin
        mdc <= ~mdc; // Toggle MDC en cada ciclo de reloj
    end
end

// Lógica de control de estado
always @(posedge clk) begin
    if (reset) begin
        state <= IDLE;
        next_state <= IDLE;
        // Resto de las asignaciones de reset
    end else begin
        state <= next_state;
    end
end

// Lógica de transición de estado
always @(*) begin
    next_state = state;
    case (state)
        IDLE: begin
            if (start) next_state = PREPARE;
        end
        PREPARE: begin
            shift_reg = {2'b01, operation ? 2'b10 : 2'b01, phy_addr, reg_addr, 2'b10, write_data}; // Configuración dependiendo de la operación
            bit_count = 31; // Preparar contador de bits
            next_state = SEND;
            busy = 1;
        end
        SEND: begin
            if (bit_count == -1) next_state = operation ? RECEIVE : FINISH; // Pasar a recibir si es lectura
        end
        RECEIVE: begin
            if (bit_count == -1) next_state = FINISH;
        end
        FINISH: begin
            next_state = IDLE;
            busy = 0;
        end
    endcase
end

// Lógica de manejo de datos MDIO
always @(posedge mdc) begin
    if (state == SEND) begin
        mdio_oe <= 1;
        mdio_out <= shift_reg[31];
        shift_reg <= shift_reg << 1;
        bit_count <= bit_count - 1;
    end else if (state == RECEIVE) begin
        mdio_oe <= 0;
        if (bit_count >= 0) begin
            read_data[bit_count] <= mdio_in;
        end
        bit_count <= bit_count - 1;
    end else begin
        mdio_oe <= 0;
    end
end

endmodule
