# dirs
preprocess_dir  := 'preprocessed'
build_dir       := 'build'
sim_dir         := 'sim'

# parse source files
include_dirs    := `find {src,include} -name '*.sv*' -printf '-I%h\n' | sort -u | tr '\n' ' '`
src_sv          := `find src -name "*.sv" | tr '\n' ' '`


## Private recipes

_default:
    @just --list

_prep:
    @mkdir -p {{build_dir}}/{{preprocess_dir}}
    @mkdir -p {{sim_dir}}


## Basic recipes

# Clean up generated files
clean:
    rm -f transcript
    rm -rf {{build_dir}}
    rm -rf {{sim_dir}}

# Check the design for common code errors
lint design *VERILATOR_FLAGS:
    verilator --lint-only --timing -Wall {{VERILATOR_FLAGS}} {{include_dirs}} {{src_sv}} --top {{design}} `find -name {{design}}.sv`

# Convert a systemverilog design to verilog using sv2v
preprocess design *SV2V_FLAGS: _prep
    sv2v {{SV2V_FLAGS}} {{include_dirs}} -w{{build_dir}}/{{preprocess_dir}} --top={{design}} `find -name {{design}}.sv` {{src_sv}}


## Simulation Recipes

# Verilate a testbench
verilate design *VERILATOR_FLAGS: _prep
    verilator --binary --timing --trace -Wno-lint \
        -MAKEFLAGS "--silent" \
        --Mdir {{build_dir}} \
        {{VERILATOR_FLAGS}} \
        -j `nproc` \
        {{include_dirs}} \
        --top {{design}} \
        `find -name {{design}}.sv`
    make --silent -C {{build_dir}} -f V{{design}}.mk V{{design}}
    just run {{design}}

# Run simulation on a previously verilated testbench
run design *FLAGS:
    cp {{build_dir}}/V{{design}} {{sim_dir}}/.
    cd {{sim_dir}} && ./V{{design}} {{FLAGS}}

# Simulate a testbench using QuestaSim
questasim design *QUESTA_FLAGS: (preprocess design)
    vlog -lint -work {{sim_dir}}/work {{QUESTA_FLAGS}} {{src_sv}} `find -name {{design}}.sv`
    cd {{sim_dir}} && vsim -c {{design}} -do "run -all"

# View simulation waveforms
view:
    gtkwave {{sim_dir}}/*.vcd
