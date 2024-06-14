`timescale 1ns / 1ps

module mdio_controller(
    input wire clk,
    input wire reset,
    input wire mdio_in,
    output reg mdio_out,
    output reg mdio_oe,
    output reg mdc,
    input wire [4:0] phy_addr,
    input wire [4:0] reg_addr,
    input wire [15:0] write_data,
    output reg [15:0] read_data,
    input wire start,
    input wire operation, // 0 para escritura, 1 para lectura
    output reg busy
);

// Estados del controlador MDIO
localparam IDLE = 0,
           PREPARE = 1,
           SEND = 2,
           RECEIVE = 3,
           FINISH = 4;

integer state = IDLE, next_state = IDLE;
integer bit_count; // Contador de bits enviados/recibidos
reg [31:0] shift_reg; // Registro de desplazamiento para la trama MDIO

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
        busy <= 0;
        mdio_oe <= 0;
        mdio_out <= 0;
        read_data <= 0;
        shift_reg <= 0;
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
