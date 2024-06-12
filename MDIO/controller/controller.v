`timescale 1ns / 1ps

module controller(
    input wire clk,
    input wire reset,
    output reg mdio_out,
    output reg mdio_oe,
    output reg mdio_done,
    output reg [15:0] mdio_in,
    output reg [4:0] addr,
    output reg [15:0] wr_data,
    input wire [15:0] rd_data,
    output reg wr_stb
);

// Declaración de parámetros y estados
parameter IDLE = 3'b000, READ = 3'b001, WRITE = 3'b010, SEND_DATA = 3'b011, RECEIVE_DATA = 3'b100;
reg [2:0] state, next_state;
reg [4:0] bit_counter;
reg [31:0] shift_reg;

// Lógica de estado siguiente
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        mdio_done <= 0;
        mdio_in <= 0;
        addr <= 0;
        wr_data <= 0;
        wr_stb <= 0;
        bit_counter <= 0;
        shift_reg <= 0;
    end else begin
        state <= next_state;
    end
end

// Lógica de salida y transiciones de estado
always @(posedge clk) begin
    case (state)
        IDLE: begin
            mdio_done <= 0;
            wr_stb <= 0;
            bit_counter <= 0;
            shift_reg <= 0;
            if (mdio_oe) begin
                next_state <= (mdio_out) ? WRITE : READ;
            end else begin
                next_state <= IDLE;
            end
        end
        READ: begin
            if (bit_counter < 15) begin
                shift_reg <= {shift_reg[30:0], mdio_out};
                bit_counter <= bit_counter + 1;
            end else if (bit_counter == 15) begin
                next_state <= RECEIVE_DATA;
                mdio_in <= rd_data;
                mdio_done <= 1;
            end
        end
        WRITE: begin
            if (bit_counter < 31) begin
                shift_reg <= {shift_reg[30:0], mdio_out};
                bit_counter <= bit_counter + 1;
            end else if (bit_counter == 31) begin
                next_state <= SEND_DATA;
                addr <= shift_reg[22:18];
                wr_data <= shift_reg[15:0];
                wr_stb <= 1;
                mdio_done <= 1;
            end
        end
        SEND_DATA: begin
            next_state <= IDLE;
        end
        RECEIVE_DATA: begin
            if (bit_counter < 31) begin
                mdio_in <= {mdio_in[14:0], mdio_out};
                bit_counter <= bit_counter + 1;
            end else if (bit_counter == 31) begin
                mdio_done <= 1;
                next_state <= IDLE;
            end
        end
    endcase
end

endmodule
