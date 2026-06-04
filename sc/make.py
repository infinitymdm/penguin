#!/usr/bin/env python3

"""SHA3 Performance Experiments

Experiment Design

Goal: The purpose of this experiment is to characterize the power, performance, and area of a SHA3
hash function hardware design with varying parameters. There are two designs under consideration:

- A pipelined design which splits the keccak round into steps: theta/rho/pi, then chi/iota.
- A speed-optimized design which may perform multiple keccak rounds per clock cycle.

The design should be tested under all possible configurations and multiple PDKs.

The experiment is as follows:
1. Test and synthesize each design configuration.
    - Digest lengths: 512, 384, 256, 224
    - Cycles per chunk: 48 (2-cycle pipelined), 24, 12, 8, 6, 4, 3, 2 1
2. Measure power, performance, and area results for each configuration.
    - Dynamic and leakage power
    - Critical path, fmax, throughput
    - Core area
3. Analyze results

"""

from pathlib import Path

from siliconcompiler import Design, ASIC, Lint, Sim
from siliconcompiler.flows.lintflow import LintFlow
from siliconcompiler.flows.dvflow import DVFlow
from siliconcompiler.targets import asic_target

class PenguinSHA3Design(Design):
    def __init__(self):
        super().__init__()
        self.set_name('penguin_sha3')
        self.set_dataroot('penguin',
                          'git+https://github.com/infinitymdm/penguin.git',
                          '721760604bc6ab8743b2a5ff977a0337b8d201c2')
        self.set_dataroot('local', __file__)

        with self.active_fileset('rtl'):
            with self.active_dataroot('penguin'):
                self.add_file([
                    'src/math/keccak/keccak_pipelined.sv',
                    'src/math/keccak/permutations/keccak_chi.sv',
                    'src/math/keccak/permutations/keccak_iota.sv',
                    'src/math/keccak/permutations/keccak_theta_rho_pi.sv',
                    'src/math/keccak/block2vector.sv',
                    'src/math/keccak/vector2block.sv',
                    'src/flop/dffre.sv'])
            with self.active_dataroot('local'):
                self.add_file('penguin_sha3_top.sv')
                self.set_topmodule('penguin_sha3_top')

        with self.active_fileset('sdc.gf180'):
            with self.active_dataroot('local'):
                self.add_file('penguin_sha3.sdc')

        with self.active_fileset('testbench'):
            with self.active_dataroot('penguin'):
                self.add_file('tb/tb_sha3_pipelined.sv')


def check():
    assert PenguinSHA3Design().check_filepaths()


def sim(tool: str = 'verilator', **rtl_params):
    project = Sim()
    design = PenguinSHA3Design()
    project.set_design(design)
    project.add_fileset('rtl')
    project.add_fileset('testbench')

    # Override parameters if given
    for param, value in rtl_params.items():
        design.set_param(param, str(value), fileset='testbench')

    project.set_flow(DVFlow(tool=tool))

    # Set verilator to use --main since we have a pure sv testbench
    project.set('tool', 'verilator', 'task', 'compile', 'var', 'main', True)

    project.run()
    project.summary()


def lint(fileset: str = 'rtl'):
    project = Lint()
    project.set_design(PenguinSHA3Design())
    project.add_fileset(fileset)
    project.set_flow(LintFlow())

    project.run()
    project.summary()


def syn(pdk: str = 'gf180', **rtl_params):
    project = ASIC()
    design = PenguinSHA3Design()
    project.set_design(design)
    project.add_fileset('rtl')
    project.add_fileset(f'sdc.{pdk}')

    # Override parameters if given
    for param, value in rtl_params.items():
        design.set_param(param, str(value), fileset='rtl')

    asic_target(project, pdk=pdk)

    # Design constraints
    project.set('constraint', 'area', 'diearea', (750,750))
    project.set('constraint', 'area', 'density', 80)

    # Use slang for synthesis, since we're using systemverilog sources
    project.set('tool', 'yosys', 'task', 'syn_asic', 'var', 'use_slang', True)

    project.run()
    project.summary()
    project.snapshot()


if __name__ == "__main__":
    check()
    # lint()
    # syn()
    sim(D=512, M=Path('../README').resolve().absolute())
