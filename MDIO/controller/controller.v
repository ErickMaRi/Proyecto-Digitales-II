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
        data_reg <= 0;
        RD_DATA <= 0;
        DATA_RDY <= 0;
        MDC <= 0;
        MDIO_OE <= 0;
        MDIO_OUT <= 0;
        contador <= 5'd31;
        state <= IDLE;

    end else begin
        // Lógica de transición de estado temporal
        state <= state == IDLE ? MDIO_START ? START: IDLE : state;
    end
end

always @(posedge MDC) begin
    case (state)
    IDLE: begin
        RD_DATA <= 0;
        DATA_RDY <= 0;
        MDC <= 0;
        MDIO_OE <= 0;
        MDIO_OUT <= 0;
    end 
    START: begin
        MDIO_OUT <= T_DATA[contador]; 
        state <= contador == 30? OP_CODE: START;
        MDIO_OE <= 1;
    end
    OP_CODE: begin
        MDIO_OUT <= T_DATA[contador];
        state <= contador == 28? PHY_ADDR: OP_CODE;
    end
    PHY_ADDR: begin
        MDIO_OUT <= T_DATA[contador]; 
        state <= contador == 23? REG_ADDR: PHY_ADDR;
    end
    REG_ADDR: begin
        MDIO_OUT <= T_DATA[contador]; 
        state <= contador == 18? TURNAROUND : REG_ADDR;
    end
    TURNAROUND: begin
        MDIO_OUT <= T_DATA[29]?  1'bz : T_DATA[contador];
        state <= contador == 16? T_DATA[29]? READ_DATA: WRITE_DATA: TURNAROUND;  
    end
    WRITE_DATA: begin
        MDIO_OUT <= T_DATA[contador]; 
        state <= contador == 0 ?  IDLE: WRITE_DATA;
    end
    READ_DATA: begin
        
        data_reg[contador] <= MDIO_IN; 
        state <= DATA_RDY?  IDLE: READ_DATA;
        DATA_RDY <= contador == 0 ? 1: 0;
        RD_DATA <= DATA_RDY ? data_reg: RD_DATA;
        MDIO_OUT <= 1'bz;
        MDIO_OE <= 0;
    end
    endcase
    contador <= state == IDLE ? 5'd31 : contador - 1;
end

endmodule
