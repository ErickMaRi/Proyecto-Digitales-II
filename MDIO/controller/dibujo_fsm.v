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
    input wire CLK,             // Reloj de sistema
    input wire RESET,           // Señal de RESET
    input wire MDIO_START,      // Señal de inicio de  una operación
    input wire [31:0] T_DATA,   // Señal de datos de entrada
    input wire MDIO_IN,         // Señal de datos MDIO recibidos
    output reg [15:0] RD_DATA,  // Datos MDIO leídos
    output reg DATA_RDY,        // Señal de datos listos
    output reg MDC,             // Señal de reloj del protocolo MDIO
    output reg MDIO_OE,         // Señal de habilitación de salida MDIO_OUT
    output reg MDIO_OUT         // Señal de datos MDIO enviados
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

// Variables de control del estado
reg [4:0] contador;     // Contador para el seguimiento de bits
reg [2:0] state;        // Estado actual del controlador MDIO
reg [15:0] data_reg;     // Registro de dirección del registro
// Generación del reloj MDIO (MDC)
always @(posedge CLK) begin
    if (~RESET) begin
        MDC <= 0;
    end else if (state != IDLE) begin
        MDC <= ~MDC; // Toggle MDC en cada ciclo de reloj
    end else begin
        MDC <= 0;
        RD_DATA <= 0;
        DATA_RDY <= 0;
        MDC <= 0;
        MDIO_OE <= 0;
        MDIO_OUT <= 0;
    end
end

// Lógica de control de estado
always @(posedge CLK) begin
    if (~RESET) begin
        state <= IDLE;

    end else begin
        case (state)
        IDLE: begin
            if (MDIO_START) begin
                state <= START;
            end else
                state <= IDLE;
        end 
        START: begin
            if (T_DATA[1:0] != 2'b01) begin
                if (contador == 30) begin
                    state <= OP_CODE;
                end else
                    state <= START;
                MDIO_OUT <= T_DATA[contador]; 
                MDIO_OE <= 1;
            end else state <= IDLE;
        end
        OP_CODE: begin
            MDIO_OUT <= T_DATA[contador];
            if (contador == 28) begin
                state <= PHY_ADDR;
            end else
                state <= OP_CODE;
        end
        PHY_ADDR: begin 
            MDIO_OUT <= T_DATA[contador];
            if (contador == 23) begin
                state <= REG_ADDR;
            end else
                state <= PHY_ADDR;
        end
        REG_ADDR: begin 
            MDIO_OUT <= T_DATA[contador];
            if (contador == 23) begin
                state <= TURNAROUND;
            end else
                state <= REG_ADDR;
        end
        TURNAROUND: begin
            MDIO_OUT <= T_DATA[29]?  1'bz : T_DATA[contador];
            if (contador == 16) begin
                if (T_DATA[29]) begin
                    state <= READ_DATA;
                end else begin
                    state <= WRITE_DATA;
                end
            end else state <= TURNAROUND;  
        end
        WRITE_DATA: begin 
            MDIO_OUT <= T_DATA[contador]; 
            if (contador == 0) begin
                state <= IDLE;
            end else state <= WRITE_DATA;
        end
        READ_DATA: begin
            if (DATA_RDY) begin
                state <= IDLE;
            end else  state <= READ_DATA;
        end
        default : state <= IDLE;

        endcase
        contador <= state == IDLE ? 5'd31 : contador - 1;
    end
end
endmodule
