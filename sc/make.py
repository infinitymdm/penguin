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

import itertools
from pathlib import Path

from siliconcompiler import Design, ASIC
from siliconcompiler.flows import lintflow, dvflow, synflow, asicflow, drcflow

class PenguinSHA3Design(Design):
    """
    Highly modular SHA-3/SHAKE implementation with configurable stage count
    """
    def __init__(self):
        super().__init__()
        self.set_name('penguin_sha3')
        self.set_dataroot('penguin',
                          'git+https://github.com/infinitymdm/penguin.git',
                          'be8c2f78c0a76ec6d3f4e27d2fe9e48670e8e769')
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
                self.set_topmodule('keccak_pipelined')

        with self.active_fileset('sdc.gf180'):
            with self.active_dataroot('local'):
                self.add_file('penguin_sha3.sdc')

        with self.active_fileset('testbench'):
            with self.active_dataroot('penguin'):
                self.add_file('tb/tb_sha3_pipelined.sv') # FIXME


def configure_asic(project: ASIC, pdk: str = 'gf180', stackup: int = 5, libtype: int = 9):
    """
    Configure the complete ASIC flow (lint, sim, synth, DRC, LVS) against the given design.
    """
    ## Load the design and PDK

    # Select PDK based on arguments
    match pdk, stackup, libtype:
        case 'gf180', 3, 7:
            from lambdapdk.gf180 import GF180_3LM_1TM_9K_7t as asic_pdk
            from lambdapdk.gf180.libs.gf180mcu import GF180_MCU_7T_3LMLibrary as asic_lib
            from lambdapdk.gf180.libs.gf180io import GF180Lambdalib_IO_3LM as asic_io
        case 'gf180', 3, 9:
            from lambdapdk.gf180 import GF180_3LM_1TM_9K_9t as asic_pdk
            from lambdapdk.gf180.libs.gf180mcu import GF180_MCU_9T_3LMLibrary as asic_lib
            from lambdapdk.gf180.libs.gf180io import GF180Lambdalib_IO_3LM as asic_io
        case 'gf180', 4, 7:
            from lambdapdk.gf180 import GF180_4LM_1TM_9K_7t as asic_pdk
            from lambdapdk.gf180.libs.gf180mcu import GF180_MCU_7T_4LMLibrary as asic_lib
            from lambdapdk.gf180.libs.gf180io import GF180Lambdalib_IO_4LM as asic_io
        case 'gf180', 4, 9:
            from lambdapdk.gf180 import GF180_4LM_1TM_9K_9t as asic_pdk
            from lambdapdk.gf180.libs.gf180mcu import GF180_MCU_9T_4LMLibrary as asic_lib
            from lambdapdk.gf180.libs.gf180io import GF180Lambdalib_IO_4LM as asic_io
        case 'gf180', 5, 7:
            from lambdapdk.gf180 import GF180_5LM_1TM_9K_7t as asic_pdk
            from lambdapdk.gf180.libs.gf180mcu import GF180_MCU_7T_5LMLibrary as asic_lib
            from lambdapdk.gf180.libs.gf180io import GF180Lambdalib_IO_5LM as asic_io
        case 'gf180', 5, 9:
            from lambdapdk.gf180 import GF180_5LM_1TM_9K_9t as asic_pdk
            from lambdapdk.gf180.libs.gf180mcu import GF180_MCU_9T_5LMLibrary as asic_lib
            from lambdapdk.gf180.libs.gf180io import GF180Lambdalib_IO_5LM as asic_io
        case 'gf180', 6, 7:
            from lambdapdk.gf180 import GF180_6LM_1TM_9K_7t as asic_pdk
            from lambdapdk.gf180.libs.gf180mcu import GF180_MCU_7T_6LMLibrary as asic_lib
            from lambdapdk.gf180.libs.gf180io import GF180Lambdalib_IO_6LM as asic_io
        case 'gf180', 6, 9 | _:
            from lambdapdk.gf180 import GF180_6LM_1TM_9K_9t as asic_pdk
            from lambdapdk.gf180.libs.gf180mcu import GF180_MCU_9T_6LMLibrary as asic_lib
            from lambdapdk.gf180.libs.gf180io import GF180Lambdalib_IO_6LM as asic_io

    # Configure the design with the imported PDK and libs
    project.set_pdk(asic_pdk())
    project.add_asiclib(asic_lib())
    project.set_mainlib(asic_lib())

    ## Configure the flow and dependencies

    project.set_flow(asicflow.ASICFlow())
    # project.add_dep(dvflow.DVFlow(tool='verilator')) FIXME: update testbench
    project.add_dep(lintflow.LintFlow(tool='verilator'))
    project.add_dep(synflow.SynthesisFlow()) # FIXME: use yosys-slang
    project.add_dep(drcflow.DRCFlow())

    # Define timing corners
    scenario = project.constraint.timing.make_scenario('slow')
    scenario.add_libcorner('slow')
    scenario.set_pexcorner('wst')
    scenario.add_check('setup')
    scenario.set_pin_voltage('VDD', 4.5)

    scenario = project.constraint.timing.make_scenario('typical')
    scenario.add_libcorner('typical')
    scenario.set_pexcorner('typ')
    scenario.add_check('power')
    scenario.set_pin_voltage('VDD', 5.0)

    scenario = project.constraint.timing.make_scenario('fast')
    scenario.add_libcorner('fast')
    scenario.set_pexcorner('bst')
    scenario.add_check('hold')
    scenario.set_pin_voltage('VDD', 5.5)

    project.set_asic_delaymodel('nldm')

    ## Configure physical design constraints
    project.constraint.area.set_density(80)
    project.constraint.area.set_coremargin(1)

    ## Alias I/O libraries
    asic_io.alias(project)


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


def asic_project(design: Design, pdk: str = 'gf180', stackup: int = 5, lib_type: int = 9, **rtl_params):
    project = ASIC()
    project.set_design(design)
    project.add_fileset('rtl')
    project.add_fileset('testbench')
    project.add_fileset(f'sdc.{pdk}')

    # Override parameters if given
    for param, value in rtl_params.items():
        design.set_param(param, str(value), fileset='rtl')

    configure_asic(project, pdk=pdk, stackup=5, libtype=9)

    # Use slang for synthesis, since we're using systemverilog sources
    # TODO: Figure out a cleaner way to set this instead of manipulating the schema directly
    project.set('tool', 'yosys', 'task', 'syn_asic', 'var', 'use_slang', True)

    return project


def sweep_sha3_parameters(**rtl_param_lists):
    """
    Generate PenguinSHA3Design variations from lists of parameters.
    """
    params, values = zip(*rtl_param_lists.items())
    for variation in itertools.product(*values):
        design = PenguinSHA3Design()
        variation_dict = dict(zip(params, variation))
        variation_name = '__'.join([f'{p}_{str(v)}' for p, v in variation_dict.items()])
        for param, value in variation_dict.items():
            design.set_param(param, str(value), fileset='rtl')
            design.set_param(param, str(value), fileset='testbench')
        yield design, variation_name


if __name__ == "__main__":
    for design, name in sweep_sha3_parameters(D=[512, 384, 256, 224], L=[6]):
        project = asic_project(design)
        project.run()
        with open(Path('results') / name, 'w', encoding='utf-8') as f:
            project.summary(fd=f)
