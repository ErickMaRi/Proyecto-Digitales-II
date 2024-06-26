/************************************************************
                    Universidad de Costa Rica
                 Escuela de Ingenieria Electrica
                            IE0523
                   Circuitos Digitales 2

                        peripheral.v

Autores: 
        Brenda Romero Solano  brenda.romero@ucr.ac.cr

Fecha: 30/6/2024
    
*********************************************************** */ 


//! @title Periférico MDIO
/**
 * El módulo peripheral es un módulo en Verilog que implementa la comunicación con un dispositivo periférico.
 * Este implementa diferentes estados para manejar las operaciones de lectura y escritura. El módulo utiliza registros
 * y lógica de control para gestionar la transición entre los diferentes estados y realizar las operaciones correspondientes.
 * También se utiliza un contador de bits para rastrear el progreso de la transmisión de datos.
 */
module peripheral (
    input wire RESET,           // Señal de RESET
    input wire [15:0] RD_DATA,  // Datos MDIO leídos
    input wire MDC,             // Señal de reloj del protocolo MDIO
    input wire MDIO_OE,         // Señal de habilitación de salida MDIO_OUT
    input wire MDIO_OUT,        // Señal de datos MDIO enviados
    output reg [4:0] ADDR,      // Dirección de registro
    output reg [15:0] WR_DATA,  // Datos de escritura
    output reg MDIO_DONE,       // Señal de finalización de transacción MDIO
    output reg WR_STB,          // Señal de escritura
    output reg MDIO_IN          // Datos MDIO recibidos de phy
);

// Estados del controlador MDIO
localparam IDLE = 0,          // Espera una transacción MDIO.
           OP_CODE = 1,       // Determina si la operación es lectura (10) o escritura (01).
           REG_ADDR = 2,      // Carga la dirección del registro en address_reg.
           TURNAROUND = 3,    // Espera cambio de control del bus.
           WRITE_DATA = 4,    // Envía los datos seriales (en escritura).
           READ_DATA = 5;     // Recibe los datos seriales (en lectura).

// Variables de control del estado
reg [4:0] bit_cnt;     // Contador para el seguimiento de bits
reg [2:0] state;       // Estado actual del controlador MDIO
reg op_bit;            // Bit de operación capturado
reg [4:0] reg_addr;    // Dirección capturada

// Lógica de control de estado
always @(posedge MDC or negedge RESET) begin
    if (~RESET) begin
        ADDR <= 5'd0;
        WR_DATA <= 16'd0;
        MDIO_DONE <= 0;
        WR_STB  <= 0;
        MDIO_IN <= 0;
        bit_cnt <= 5'd31;
        state <= IDLE;
        reg_addr <= 5'd0;
    end else begin

        // Lógica de transición de estado
        case (state)
        IDLE: begin
            ADDR <= 5'd0;
            WR_DATA <= 16'd0;
            MDIO_DONE <= 0;
            WR_STB  <= 0;
            MDIO_IN <= 0;
            reg_addr <= 5'd0;
            op_bit <= 0;
            state <= MDIO_OE && MDIO_OUT ? OP_CODE: IDLE;
        end 
        OP_CODE: begin
            op_bit <= bit_cnt == 29 ? MDIO_OUT: op_bit ;
            state <= bit_cnt == 23? REG_ADDR: OP_CODE;
        end
        REG_ADDR: begin
            reg_addr <= bit_cnt > 18? {reg_addr[3:0], MDIO_OUT}: reg_addr; 
            state <= bit_cnt == 18? TURNAROUND : REG_ADDR;
        end
        TURNAROUND: begin
            state <= bit_cnt == 16 ? op_bit? READ_DATA: WRITE_DATA: TURNAROUND; 
            ADDR  <= bit_cnt == 16 && op_bit ? reg_addr: 5'd0;
        end
        WRITE_DATA: begin
            WR_DATA[bit_cnt] <= bit_cnt < 30 ?  MDIO_OUT:0;
            WR_STB  <= bit_cnt == 31 ? 1: 0;
            MDIO_DONE <= bit_cnt == 31 ? 1: 0;
            ADDR  <= bit_cnt == 31? reg_addr: 5'd0;
            state <= bit_cnt == 30 ? IDLE: WRITE_DATA;
        end
        READ_DATA: begin
            MDIO_DONE <= bit_cnt == 31 ? 1: 0;
            MDIO_IN <=  bit_cnt < 30 ? RD_DATA[bit_cnt]: 0;
            ADDR  <= bit_cnt == 30? 5'd0 : reg_addr;
            state <= bit_cnt == 30 ? IDLE: READ_DATA;
        end
        default : state <= IDLE;
        endcase
        bit_cnt <= state == IDLE ? ~MDIO_OE ? 5'd31 : bit_cnt - 1: bit_cnt - 1;
    end
end

endmodule