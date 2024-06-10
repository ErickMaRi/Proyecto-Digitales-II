# Makefile for compiling, simulating and synthesizing Verilog files

# Testbench source files
TESTBENCH_PERIPHERAL = peripheral/peripheral.v
TESTBENCH_CONTROLLER = controller/controller.v
TESTBENCH_MDIO = MDIO_tb.v

# Comandos de simulación
SIMULATOR = iverilog
SIMULATOR_FLAGS = -o
SIMULATOR_EXECUTABLE = sim

# Comandos para ver la salida de simulación
WAVEFORM_VIEWER = gtkwave

# Objetivo por defecto
all: peripheral controller mdio

# Compilar archivos Verilog
peripheral:
	$(SIMULATOR) $(SIMULATOR_FLAGS) $(SIMULATOR_EXECUTABLE) $(TESTBENCH_PERIPHERAL)
	.peripheral/$(SIMULATOR_EXECUTABLE)
	$(WAVEFORM_VIEWER) $(SIMULATOR_EXECUTABLE).vcd

controller:
	$(SIMULATOR) $(SIMULATOR_FLAGS) $(SIMULATOR_EXECUTABLE) $(TESTBENCH_CONTROLLER)
	.controller/$(SIMULATOR_EXECUTABLE)
	$(WAVEFORM_VIEWER) $(SIMULATOR_EXECUTABLE).vcd

mdio:
	$(SIMULATOR) $(SIMULATOR_FLAGS) $(SIMULATOR_EXECUTABLE) $(TESTBENCH_MDIO)
	./$(SIMULATOR_EXECUTABLE)
	$(WAVEFORM_VIEWER) $(SIMULATOR_EXECUTABLE).vcd

# Limpiar archivos generados
clean:
	rm -f $(SIMULATOR_EXECUTABLE) $(SIMULATOR_EXECUTABLE).vcd _.vvp_ .vcd _.log
