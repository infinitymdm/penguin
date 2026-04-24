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
                          'd414d764ac782e0c28e79fe79a9cd44c4197fbae')
        self.set_dataroot('local', __file__)

        with self.active_fileset('rtl'):
            with self.active_dataroot('penguin'):
                self.add_file([
                    'src/math/keccak/keccak.sv',
                    'src/math/keccak/keccak_p.sv',
                    'src/math/keccak/keccak_round.sv',
                    'src/math/keccak/permutations/keccak_chi.sv',
                    'src/math/keccak/permutations/keccak_iota.sv',
                    'src/math/keccak/permutations/keccak_theta_rho_pi.sv',
                    'src/math/keccak/permutations/keccak_theta_rho_pi.sv',
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
    project.set('tool', 'yosys', 'task', 'syn_asic', 'var', 'use_slang', True)

    project.run()
    project.summary()
    project.snapshot()

def check():
    assert PenguinSHA3Design().check_filepaths()

if __name__ == "__main__":
    syn()
