/************************************************************
                    Universidad de Costa Rica
                 Escuela de Ingenieria Electrica
                            IE0523
                   Circuitos Digitales 2

                        peripheral.v

Autores: 
        Brenda Romero Solano  brenda.romero@ucr.ac.cr

Fecha: [fecha de modificación] 
    
*********************************************************** */ 


//! @title Periférico MDIO
/**
 * Descripción pendiente.
 */
module peripheral (
    input wire RESET,           // Señal de RESET
    input wire [15:0] RD_DATA,  // Datos MDIO leídos
    input wire MDC,             // Señal de reloj del protocolo MDIO
    input wire MDIO_OE,         // Señal de habilitación de salida MDIO_OUT
    input wire MDIO_OUT,        // Señal de datos MDIO enviados
    output reg [4:0] ADDR,      // Dirección
    output reg [15:0] WR_DATA,  // Datos de escritura
    output reg MDIO_DONE,      // Señal de finalización de transacción MDIO
    output reg WR_STB,         // Señal de escritura
    output reg MDIO_IN          // Datos MDIO recibidos
);

// Declaración de estados
localparam IDLE = 3'b000,               // Espera una transacción MDIO.
           CAPTURA_OP = 3'b001,         // Captura el bit de operación
           CAPTURA_ADDR = 3'b010,       // Captura la dirección
           CAPTURA_DATOS_WR = 3'b011,   // Captura los datos de escritura
           ENVIAR_DATOS_RD = 3'b100,    // Envía los datos de lectura
           FINALIZAR = 3'b101;          // Finaliza la transacción

// Registros internos
reg [2:0] estado_actual;             // Estado actual de la máquina de estados
reg [2:0] estado_siguiente;          // Estado siguiente de la máquina de estados
reg [5:0] bit_cnt;                   // Contador de bits
reg [4:0] reg_addr;                  // Dirección capturada
reg [15:0] reg_datos;                // Datos capturados
reg op_bit;                          // Bit de operación capturado

// Máquina de estados
always @(posedge MDC or posedge RESET) begin
    if (RESET) begin
        estado_actual <= IDLE;
        bit_cnt <= 6'd0;
        reg_addr <= 5'd0;
        reg_datos <= 16'd0;
        MDIO_DONE <= 1'b0;
        MDIO_IN <= 1'b0;
        ADDR <= 5'd0;
        WR_DATA <= 16'd0;
        WR_STB <= 1'b0;
    end else begin
        estado_actual <= estado_siguiente;
        case (estado_actual)
            IDLE: begin
                if (MDIO_OE && MDIO_OUT) begin // Detección de inicio de transacción
                    estado_siguiente <= CAPTURA_OP;
                    bit_cnt <= 5'd1;
                end else begin
                    estado_siguiente <= IDLE;
                end
            end
            CAPTURA_OP: begin
                op_bit <= MDIO_OUT; // Captura el bit de operación
                estado_siguiente <= CAPTURA_ADDR;
                bit_cnt <= bit_cnt + 5'd1;
            end
            CAPTURA_ADDR: begin
                reg_addr <= {reg_addr[3:0], MDIO_OUT}; // Captura la dirección
                if (bit_cnt == 5'd6) begin
                    if (op_bit) begin // Transacción de escritura
                        estado_siguiente <= CAPTURA_DATOS_WR;
                    end else begin // Transacción de lectura
                        estado_siguiente <= ENVIAR_DATOS_RD;
                    end
                    bit_cnt <= bit_cnt + 5'd1;
                end else begin
                    bit_cnt <= bit_cnt + 5'd1;
                end
            end
            CAPTURA_DATOS_WR: begin
                reg_datos <= {reg_datos[14:0], MDIO_OUT}; // Captura los datos de escritura
                if (bit_cnt == 5'd22) begin
                    estado_siguiente <= FINALIZAR;
                end else begin
                    bit_cnt <= bit_cnt + 5'd1;
                end
            end
            ENVIAR_DATOS_RD: begin
                if (bit_cnt >= 5'd17 && bit_cnt <= 6'd32) begin
                    MDIO_IN <= reg_datos[bit_cnt - 5'd17]; // Envía los datos de lectura
                end
                if (bit_cnt == 6'd32) begin
                    estado_siguiente <= FINALIZAR;
                end else begin
                    bit_cnt <= bit_cnt + 5'd1;
                end
            end
            FINALIZAR: begin
                MDIO_DONE <= 1'b1; // Genera el pulso MDIO_DONE
                ADDR <= reg_addr;
                if (op_bit) begin // Transacción de escritura
                    WR_DATA <= reg_datos;
                    WR_STB <= 1'b1;
                end
                estado_siguiente <= IDLE;
            end
        endcase
    end
end

endmodule