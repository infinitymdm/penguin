# 🐧 Penguin HDL

_Hardware designs for flightless birds_

Penguin HDL is a collection of hardware designs written in SystemVerilog. Most of these were
originally written as experiments with the Alchitry Cu FPGA, but a few have been used elsewhere.

## Getting Started

### Install software

You'll need a few pieces of software to make use of the flows in this repository:

- [verilator](https://github.com/verilator/verilator) for simulation
- [sv2v](https://github.com/zachjs/sv2v) for SystemVerilog to Verilog conversion
- [just](https://github.com/casey/just) for running flows (see the justfile)
- [gtkwave](https://github.com/gtkwave/gtkwave) (optional) if you want to view waveforms using `just view`

### Get the code

Clone the repository: `git clone --recurse-submodules https://github.com/infinitymdm/penguin.git`
Now you should be good to go! Move into the newly cloned directory with `cd penguin` and it's off
to the races.

## Run some Simulations

Once you're all set up, run `just --list` to see available recipes. For a quick test, try
`just verilate tb_alu`.
