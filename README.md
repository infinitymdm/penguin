# 🐧 Penguin HDL

_Hardware designs for flightless birds_

<!--Post-quantum ENGineering for Usable Integrated eNcryption-->

Penguin is a collection of hardware designs written in SystemVerilog, with a heavy emphasis on
post-quantum cryptographic primitives. The eventual goal is to provide a highly modular family of
cryptography hardware that's easy to integrate into your designs.

Most of these were originally written as experiments with the Alchitry Cu FPGA. You can find the
tools to use penguin hardware with the Cu over in [cu-fpga](https://github.com/infinitymdm/cu-fpga)

## Getting Started

### Install software

You'll need a few pieces of software to make use of the flows in this repository:

- [verilator](https://github.com/verilator/verilator) for simulation
- [sv2v](https://github.com/zachjs/sv2v) for SystemVerilog to Verilog conversion
- [just](https://github.com/casey/just) for running flows (see the justfile)
- (Optional) [surfer](https://surfer-project.org) if you want to view waveforms using `just view`

### Get the code

Clone the repository: `git clone --recurse-submodules https://github.com/infinitymdm/penguin.git`
Now you should be good to go! Move into the newly cloned directory with `cd penguin` and it's off
to the races.

## Run some Simulations

Once you're all set up, run `just --list` to see available recipes. For a quick test, try
`just verilate tb_alu`.

You can find other things to simulate in the `src` directory. Most designs that have any amount of
complexity will have their own README with more information on how to run simulation.

## Questions or Feedback?

If you need help getting something in this repo to work, feel free to
[open an issue](https://github.com/infinitymdm/penguin/issues/new).
