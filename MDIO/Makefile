# Compiler
IVERILOG = iverilog

# Waveform viewer
GTKWAVE = gtkwave

# Verilog sources
SOURCES = controller/controller.v peripheral/peripheral.v MDIO_tb.v

# Object files
OBJECTS = $(SOURCES:.v=.vvp)

# Default target
all: $(OBJECTS)

# Compilation rules
%.vvp: %.v
   $(IVERILOG) -o $@ $<

# Run testbenches
run_controller_tb: controller/controller.vvp
   vvp controller/controller.vvp
   $(GTKWAVE) controller/controller.vcd &

run_peripheral_tb: peripheral/peripheral.vvp
   vvp peripheral/peripheral.vvp
   $(GTKWAVE) peripheral/peripheral.vcd &

run_mdio_tb: MDIO_tb.vvp
   vvp MDIO_tb.vvp
   $(GTKWAVE) MDIO_tb.vcd &

# Clean up
clean:
   rm -f $(OBJECTS) *.vcd

# Dependencies
MDIO_tb.vvp: controller/controller.v peripheral/peripheral.v
controller/controller.vvp: controller/controller.v
peripheral/peripheral.vvp: peripheral/peripheral.v