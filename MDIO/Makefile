# Testbench source files
TESTBENCH_PERIPHERAL = peripheral/peripheral_tb.v
TESTBENCH_CONTROLLER = controller/controller_tb.v
TESTBENCH_MDIO = MDIO_tb.v

# Simulator
SIMULATOR = iverilog
SIMULATOR_FLAGS = -o

# Waveform viewer
WAVEFORM_VIEWER = gtkwave

# Default target
all: peripheral controller mdio

# Compile Verilog files
peripheral: sim_peripheral
	./sim_peripheral
	$(WAVEFORM_VIEWER) sim.vcd

controller: sim_controller
	./sim_controller
	$(WAVEFORM_VIEWER) sim.vcd

mdio: sim_mdio
	./sim
	$(WAVEFORM_VIEWER) sim.vcd

# Simulation executables
sim_peripheral: $(TESTBENCH_PERIPHERAL) peripheral/peripheral.v
	$(SIMULATOR) $(SIMULATOR_FLAGS) sim_peripheral $(TESTBENCH_PERIPHERAL)

sim_controller: $(TESTBENCH_CONTROLLER) controller/controller.v
	$(SIMULATOR) $(SIMULATOR_FLAGS) sim_controller $(TESTBENCH_CONTROLLER)

sim_mdio: $(TESTBENCH_MDIO) peripheral/peripheral.v controller/controller.v
	$(SIMULATOR) $(SIMULATOR_FLAGS) sim_mdio $(TESTBENCH_MDIO)

# Clean up generated files
clean:
	rm -f sim *.vcd
