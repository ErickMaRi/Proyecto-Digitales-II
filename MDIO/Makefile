
ifeq ($(OS),Windows_NT)
    # Configuraciones para Windows

	TESTBENCH_PERIPHERAL = peripheral\peripheral_tb.v
	TESTBENCH_CONTROLLER = controller\controller_tb.v
	CONTROLLER = controller\controller.v
	PERIPHERAL = peripheral\peripheral.v
	OUT = .\sim
	RM = del
	WAVEFROM= .\sim.vcd
	
else
    # Configuraciones para Linux
	TESTBENCH_PERIPHERAL = peripheral/peripheral_tb.v
	TESTBENCH_CONTROLLER = controller/controller_tb.v
	TESTBENCH_PERIPHERAL = peripheral/peripheral_tb.v
	TESTBENCH_CONTROLLER = controller/controller_tb.v
	OUT = ./sim
	RM = rm
	WAVEFROM= ./sim.vcd

endif
# Testbench source files
TESTBENCH_MDIO = MDIO_tb.v

# Simulator
SIMULATOR = iverilog
SIMULATOR_FLAGS = -o

# Waveform viewer
WAVEFORM_VIEWER = gtkwave

# Default target
all: peripheral controller mdio clean

# Compile Verilog files
peripheral: sim_peripheral
	$(WAVEFORM_VIEWER) $(WAVEFROM)

controller: sim_controller
	$(WAVEFORM_VIEWER) $(WAVEFROM)

mdio: sim_mdio
	$(WAVEFORM_VIEWER) $(WAVEFROM)

# Simulation executables
sim_peripheral: $(TESTBENCH_PERIPHERAL) $(PERIPHERAL)
	$(SIMULATOR) $(SIMULATOR_FLAGS) sim $(TESTBENCH_PERIPHERAL)
	vvp sim
sim_controller: $(TESTBENCH_CONTROLLER) $(CONTROLLER)
	$(SIMULATOR) $(SIMULATOR_FLAGS) sim $(TESTBENCH_CONTROLLER)
	vvp sim

sim_mdio: $(TESTBENCH_MDIO) $(PERIPHERAL) $(CONTROLLER)
	$(SIMULATOR) $(SIMULATOR_FLAGS) sim $(TESTBENCH_MDIO)
	vvp sim

# Clean up generated files
clean:
	$(RM) -f sim *.vcd
