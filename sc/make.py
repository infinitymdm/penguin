#!/usr/bin/env python3

from siliconcompiler import Design, ASIC, Lint
from siliconcompiler.flows.lintflow import LintFlow
from siliconcompiler.targets import asic_target

class PenguinSHA3Design(Design):
    def __init__(self):
        super().__init__()
        self.set_name('penguin_sha3')
        self.set_dataroot('penguin',
                          'git+https://github.com/infinitymdm/penguin.git',
                          'c9ee678bd5b7b09b591302acf83142c58f425852')
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

def lint(fileset: str = 'rtl'):
    project = Lint()
    project.set_design(PenguinSHA3Design())
    project.add_fileset(fileset)
    project.set_flow(LintFlow())

    project.run()
    project.summary()

def syn(fileset: str = 'rtl', pdk: str = 'gf180'):
    project = ASIC()
    project.set_design(PenguinSHA3Design())
    project.add_fileset(fileset)
    project.add_fileset(f'sdc.{pdk}')
    asic_target(project, pdk=pdk)

    # Design constraints
    project.set('constraint', 'area', 'diearea', (750,750))
    project.set('constraint', 'area', 'density', 80)

    # Use slang for synthesis, since we're using systemverilog sources
    project.set('tool', 'yosys', 'task', 'syn_asic', 'var', 'use_slang', True)

    # [print(k) for k in project.allkeys()]

    project.run()
    project.summary()
    project.snapshot()

def check():
    assert PenguinSHA3Design().check_filepaths()

if __name__ == "__main__":
    syn()
