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

reg [31:0] address_reg; // Dirección del dispositivo PHY y el registro a leer/escribir
reg [15:0] data_reg;    // Registro que almacena los datos a enviar o recibir

// Estados del controlador MDIO
reg [2:0] state;

// Generación del reloj MDIO (MDC)
always @(posedge CLK) begin
    if (RESET) begin
        MDC <= 0;
    end else begin
        MDC <= ~MDC; // Toggle MDC en cada ciclo de reloj
    end
end

// Lógica de control de estado
always @(posedge CLK) begin
    if (RESET) begin
        state <= IDLE;
        address_reg <= 0;	
        data_reg <= 0;
        RD_DATA <= 0;
        DATA_RDY <= 0;
        RD_DATA <= 0;
        DATA_RDY <= 0;
        MDC <= 0;
        MDIO_OE <= 0;
        MDIO_OUT <= 0;
    end else begin
        // Lógica de transición de estado temporal
        case (state)
            IDLE: begin
                if (MDIO_START) begin
                    state <= START;
                end
            end
            START: begin
                state <= OP_CODE;
            end
            OP_CODE: begin
                state <= PHY_ADDR;
            end
            PHY_ADDR: begin
                state <= REG_ADDR;
            end
            REG_ADDR: begin
                state <= TURNAROUND;
            end
            TURNAROUND: begin
                state <= WRITE_DATA;
            end
            WRITE_DATA: begin
                state <= READ_DATA;
            end
            READ_DATA: begin
                state <= IDLE;
            end
        endcase
    end
end

/* Lógica de transición de estado
always @(*) begin
    next_state = state;
    case (state)
        IDLE: begin
            if (start) next_state = STar;
        end
        STar: begin
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
always @(posedge MDC) begin
    if (state == SEND) begin
        MDIO_OE <= 1;
        MDIO_OUT <= shift_reg[31];
        shift_reg <= shift_reg << 1;
        bit_count <= bit_count - 1;
    end else if (state == RECEIVE) begin
        MDIO_OE <= 0;
        if (bit_count >= 0) begin
            read_data[bit_count] <= MDIO_IN;
        end
        bit_count <= bit_count - 1;
    end else begin
        MDIO_OE <= 0;
    end
end
*/
endmodule
