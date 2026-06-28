INC_DIR := ./include

# Tops
DUT_TOP ?= OTTER_PIP        # RTL/synthesis/OpenLane top
TB_TOP  ?= TB_OTTER         # simulation/testbench top

# Sources
RTL_SRCS := $(shell find rtl -type f \( -name '*.sv' -o -name '*.v' \))

PKG_SRCS := $(shell grep -l "^[[:space:]]*package[[:space:]]" $(RTL_SRCS) 2>/dev/null | sort)
RTL_SRCS_SORT := $(sort $(RTL_SRCS))
RTL_NO_PKG    := $(filter-out $(PKG_SRCS),$(RTL_SRCS_SORT))
ORDERED_SRCS  := $(PKG_SRCS) $(RTL_NO_PKG)

INCLUDE_DIRS := $(sort $(dir $(shell find . -name '*.svh')))
RTL_DIRS	 := $(sort $(dir $(RTL_SRCS)))

# Include both Include and RTL directories for linting
LINT_INCLUDES := $(foreach dir, $(INCLUDE_DIRS) $(RTL_DIRS), -I$(realpath $(dir))) -I$(PDKPATH) 

TEST_DIR = ./tests
TEST_SUBDIRS = $(shell cd $(TEST_DIR) && ls -d */ | grep -v "__pycache__" )
TESTS = $(TEST_SUBDIRS:/=)

# Main Linter and Simulatior is Verilator
LINTER := verilator
SIMULATOR := verilator
SIMULATOR_ARGS := --binary --timing --trace --trace-structs \
	--assert --timescale 1ns --quiet --sv 
SIM_TOP_FLAG := --top-module $(TB_TOP)
SIMULATOR_BINARY := ./obj_dir/V*
SIMULATOR_SRCS := $(foreach src,$(ORDERED_SRCS),$(realpath $(src))) *.sv

# Questa / Quartus Prime simulation
QUESTA_HOME ?= /home/sardude54/intelFPGA_lite/questa_fse/linux_x86_64
VSIM        ?= $(QUESTA_HOME)/vsim

# Your Questa Tcl/DO script
QSIM_SCRIPT ?= sim/run_core.tcl

# Optional waveform setup script used inside run_core.tcl
WAVE_SCRIPT ?= core_wave.do

# Memory image passed into Memory.sv through +MEM=<file>
MEM_IMG ?= $(abspath otter_mem.mem)

# GUI mode by default. Override with GUI=0 for command-line mode.
GUI ?= 1

ifeq ($(GUI),1)
VSIM_MODE := -gui
else
VSIM_MODE := -c
endif

# Optional use of Icarus as Linter and Simulator
ifdef ICARUS
SIMULATOR := iverilog
SIMULATOR_ARGS := -g2012
SIMULATOR_BINARY := a.out
SIMULATOR_SRCS := $(foreach src,$(ORDERED_SRCS),$(realpath $(src))) *.sv
SIM_TOP_FLAG := -s $(TB_TOP)
endif

ifdef GL
SIMULATOR := iverilog
LINT_INCLUDES := -I$(PDKPATH) -I$(realpath gl)
SIMULATOR_ARGS := -g2012 -DFUNCTIONAL -DUSE_POWER_PINS
SIMULATOR_BINARY := a.out
SIMULATOR_SRCS := $(foreach src,$(ORDERED_SRCS),$(realpath $(src))) *.sv
SIM_TOP_FLAG   := --top-module $(TB_TOP)
endif



LINT_OPTS += --lint-only --timing --sv $(LINT_INCLUDES)

# Text formatting for tests
BOLD = `tput bold`
GREEN = `tput setaf 2`
ORANG = `tput setaf 214`
RED = `tput setaf 1`
RESET = `tput sgr0`

TEST_GREEN := $(shell tput setaf 2)
TEST_ORANGE := $(shell tput setaf 214)
TEST_RED := $(shell tput setaf 1)
TEST_RESET := $(shell tput sgr0)

MEM_IMG ?= $(abspath otter_mem.mem)

all: lint_all tests

lint: lint_all

.PHONY: lint_all
lint_all:
	@printf "\n$(GREEN)$(BOLD) ----- Linting All Modules ----- $(RESET)\n"
	@for src in $(RTL_NO_PKG); do \
		top_module=$$(basename $$src .sv); \
		top_module=$$(basename $$top_module .v); \
		printf "Linting $$src . . . "; \
		if $(LINTER) $(LINT_OPTS) --top-module $$top_module $(ORDERED_SRCS) > /dev/null 2>&1; then \
			printf "$(GREEN)PASSED$(RESET)\n"; \
		else \
			printf "$(RED)FAILED$(RESET)\n"; \
			$(LINTER) $(LINT_OPTS) --top-module $$top_module $(ORDERED_SRCS); \
		fi; \
	done



.PHONY: lint_top
lint_top:
	@printf "\n$(GREEN)$(BOLD) ----- Linting $(TOP_MODULE) ----- $(RESET)\n"
	@printf "Linting Top Level Module: $(TOP_FILE)\n";
	$(LINTER) $(LINT_OPTS) --top-module $(TOP_MODULE) $(TOP_FILE)


tests: $(TESTS) 

tests/%: FORCE
	make -s $(subst /,, $(basename $*))

itests: 
	@ICARUS=1 make tests

gl_tests:
	@mkdir -p gl
	@cp runs/recent/final/pnl/* gl/
	@cat scripts/gatelevel.vh gl/*.v > gl/temp
	@mv -f gl/temp gl/*.v
	@rm -f gl/temp
	@GL=1 make tests

.PHONY: $(TESTS)
$(TESTS):
	@printf "\n$(GREEN)$(BOLD) ----- Running Test: $@ ----- $(RESET)\n"
	@printf "\n$(BOLD) Building with $(SIMULATOR)... $(RESET)\n"
	@cd $(TEST_DIR)/$@; \
	$(SIMULATOR) $(SIMULATOR_ARGS) $(LINT_INCLUDES) $(SIM_TOP_FLAG) $(SIMULATOR_SRCS) > build.log 2>&1 \
	|| { printf "$(RED)Build failed$(RESET)\n"; cat build.log; exit 1; }

	@printf "\n$(BOLD) Running... $(RESET)\n"
	@if cd $(TEST_DIR)/$@; \
	./$(SIMULATOR_BINARY) +MEM=$(MEM_IMG) > results.log \
	&& !( cat results.log | grep -qi error ); then \
		printf "$(GREEN)PASSED $@$(RESET)\n"; \
	else \
		printf "$(RED)FAILED $@$(RESET)\n"; \
		cat results.log; \
	fi


COCOTEST_DIR = ./cocotests
COCOTEST_SUBDIRS = $(shell cd $(COCOTEST_DIR) && ls -d */ | grep -v "__pycache__" )
COCOTESTS = $(COCOTEST_SUBDIRS:/=)
.PHONY: cocotests
cocotests:
	@$(foreach test,  $(COCOTESTS), make -sC $(COCOTEST_DIR)/$(test);)

OPENLANE_CONF ?= config.*
openlane:
	@TOP_MODULE=$(DUT_TOP) `which openlane` --flow Classic $(OPENLANE_CONF)
	@cd runs && rm -f recent && ln -sf `ls | tail -n 1` recent


%.json %.yaml: FORCE
	@echo $@
	OPENLANE_CONF=$@ make openlane

FORCE: ;

openroad:
	scripts/openroad_launch.sh | openroad

.PHONY: qsim
qsim:
	@printf "\n$(GREEN)$(BOLD) ----- Running Questa Simulation ----- $(RESET)\n"
	@printf "Script:   $(QSIM_SCRIPT)\n"
	@printf "MEM_IMG:  $(MEM_IMG)\n"
	@printf "Wave DO:  $(WAVE_SCRIPT)\n"
	$(VSIM) $(VSIM_MODE) -do "set MEM_FILE {$(MEM_IMG)}; set WAVE_DO {$(WAVE_SCRIPT)}; do $(QSIM_SCRIPT)"

.PHONY: qsim_cli
qsim_cli:
	@GUI=0 $(MAKE) qsim

.PHONY: qsim_tb
qsim_tb:
	@$(MAKE) qsim MEM_IMG=$(abspath tb_only_test.mem)

.PHONY: qsim_clean
qsim_clean:
	rm -rf work transcript vsim.wlf wave.vcd sim_log.txt

.PHONY: clean
clean:
	rm -f `find tests -iname "*.vcd"`
	rm -f `find tests -iname "a.out"`
	rm -f `find tests -iname "*.log"`
	rm -rf `find tests -iname "obj_dir"`

.PHONY: VERILOG_SOURCES
VERILOG_SOURCES: 
	@echo $(realpath $(RTL_SRCS))