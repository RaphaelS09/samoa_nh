#! /usr/bin/python

# @file

#
#
# @section DESCRIPTION
#
# Builds sam(oa)^2 with several options.
#

# print the welcome message

import os

#
# set possible variables
#
vars = Variables()

vars.AddVariables(
  PathVariable( 'build_dir', 'build directory', 'bin/', PathVariable.PathIsDirCreate),

  EnumVariable( 'scenario', 'target scenario', 'darcy',
                allowed_values=('darcy', 'swe', 'generic', 'flash') #, 'heat_eq', 'tests')
              ),

  EnumVariable( 'swe_solver', 'flux solver for the swe scenario', 'aug_riemann',
                allowed_values=('lf', 'lfbath', 'llf', 'llfbath', 'fwave', 'aug_riemann')
              ),

  EnumVariable( 'compiler', 'used compiler', 'intel',
                allowed_values=('intel',)
              ),

  EnumVariable( 'target', 'build target, sets debug flag and optimization level', 'release',
                allowed_values=('debug', 'profile', 'release')
              ),

  EnumVariable( 'openmp', 'OpenMP support', 'tasks',
                allowed_values=('noomp', 'no_tasks', 'tasks')
              ),

  EnumVariable( 'mpi', 'MPI support', 'default',
                allowed_values=('nompi', 'default', 'intel', 'mpich2', 'openmpi')
              ),

  BoolVariable( 'standard', 'check for Fortran 2003 standard compatibility', False),

  EnumVariable( 'asagi', 'ASAGI support', 'standard',
                allowed_values=('noasagi', 'standard', 'numa')
              ),
  BoolVariable( 'asagi_timing', 'switch on timing of all ASAGI calls', False),

  PathVariable( 'asagi_dir', 'ASAGI directory', './ASAGI'),

  EnumVariable( 'precision', 'floating point precision', 'double',
                allowed_values=('single', 'double', 'quad')
              ),

  EnumVariable( 'vec_report', 'vectorization report', '0',
                allowed_values=('0', '1', '2', '3', '4', '5', '6', '7')
              ),

  EnumVariable( 'debug_level', 'debug output level', '1',
                allowed_values=('0', '1', '2', '3', '4', '5', '6', '7')
              ),

)

default_env = DefaultEnvironment(variables=vars)

# set environment
env = Environment(ENV = {'PATH': os.environ['PATH']},
        variables=vars)

# handle unknown, maybe misspelled variables
unknownVariables = vars.UnknownVariables()

# exit in the case of unknown variables
if unknownVariables:
  print "*** The following build variables are unknown:", unknownVariables.keys()
  Exit(1)

#
# precompiler, compiler and linker flags
#

#set default compiler flags
env['F90FLAGS'] = '-implicitnone -nologo -fpp -Isrc/Samoa/'
env['LINKFLAGS'] = ''

# If MPI is active, set compilation flags
if env['mpi'] == 'default':
  env['F90'] = 'MPICH_F90=ifort OMPI_FC=ifort I_MPI_F90=ifort mpif90'
  env['LINK'] = 'MPICH_F90=ifort OMPI_FC=ifort I_MPI_F90=ifort mpif90'
  env['F90FLAGS'] += ' -D_MPI'
elif env['mpi'] == 'mpich2':
  env['F90'] = 'MPICH_F90=ifort mpif90'
  env['LINK'] = 'MPICH_F90=ifort mpif90'
  env['F90FLAGS'] += ' -D_MPI'
elif env['mpi'] == 'openmpi':
  env['F90'] = 'OMPI_FC=ifort mpif90'
  env['LINK'] = 'OMPI_FC=ifort mpif90'
  env['F90FLAGS'] += ' -D_MPI'
elif env['mpi'] == 'intel':
  env['F90'] = 'I_MPI_F90=ifort mpif90'
  env['LINK'] = 'I_MPI_F90=ifort mpif90'
  env['F90FLAGS'] += ' -D_MPI'
elif env['mpi'] == 'nompi':
  env['F90'] = 'ifort'
  env['LINK'] = 'ifort'

if env['scenario'] == 'darcy':
  env['F90FLAGS'] += ' -D_DARCY'
  env['asagi'] = 'standard'
  env['lib'] = False
elif env['scenario'] == 'swe':
  env['F90FLAGS'] += ' -D_SWE'
  env['asagi'] = 'standard'
  env['lib'] = False
elif env['scenario'] == 'generic':
  env['F90FLAGS'] += ' -D_GENERIC'
  env['asagi'] = 'noasagi'
  env['lib'] = True
elif env['scenario'] == 'flash':
  env['F90FLAGS'] += ' -D_FLASH'
  env['asagi'] = 'standard'
  env['lib'] = False
elif env['scenario'] == 'heateq':
  env['F90FLAGS'] += ' -D_HEAT_EQ'
  env['asagi'] = 'standard'
  env['lib'] = False
elif env['scenario'] == 'tests':
  env['F90FLAGS'] += ' -D_TESTS'
  env['asagi'] = 'noasagi'
  env['lib'] = False

if env['openmp'] == 'tasks':
  env['F90FLAGS'] += ' -openmp -D_OPENMP_TASKS'
  env['LINKFLAGS'] += ' -openmp'
elif env['openmp'] == 'notasks':
  env['F90FLAGS'] += ' -openmp'
  env['LINKFLAGS'] += ' -openmp'
elif env['openmp'] == 'noomp':
  env['F90FLAGS'] += ' -openmp-stubs'
  env['LINKFLAGS'] += ' -openmp-stubs'

if env['asagi'] != 'noasagi':
  env['F90FLAGS'] += ' -D_ASAGI -I' + env['asagi_dir'] + '/include'
  env['LINKFLAGS'] += ' -Wl,-rpath,' + env['asagi_dir'] + ' -L' + env['asagi_dir']

  if env['asagi'] == 'numa':
    env['F90FLAGS'] += ' -D_ASAGI_NUMA'

  if env['openmp'] == 'noomp':
    env['LINKFLAGS'] += ' -lasagi_nomt'
  else:
    env['LINKFLAGS'] += ' -lasagi'

if env['asagi_timing']:
  env['F90FLAGS'] += ' -D_ASAGI_TIMING'

  if env['asagi'] == 'noasagi':
    print "Error: asagi_timing must not be set if asagi is not active"
    Exit(-1)

if env['swe_solver'] == 'lf':
  env['F90FLAGS'] 		+= ' -D_SWE_LF'
elif env['swe_solver'] == 'lfbath':
  env['F90FLAGS'] 		+= ' -D_SWE_LF_BATH'
elif env['swe_solver'] == 'llf':
  env['F90FLAGS'] += ' -D_SWE_LLF'
elif env['swe_solver'] == 'llfbath':
  env['F90FLAGS'] += ' -D_SWE_LLF_BATH'
elif env['swe_solver'] == 'fwave':
  env['F90FLAGS'] += ' -D_SWE_FWAVE'
elif env['swe_solver'] == 'aug_riemann':
  env['F90FLAGS'] += ' -D_SWE_AUG_RIEMANN'

if env['precision'] == 'single':
  env['F90FLAGS'] += ' -D_SINGLE_PRECISION'
elif env['precision'] == 'double':
  env['F90FLAGS'] += ' -D_DOUBLE_PRECISION'
elif env['precision'] == 'quad':
  env['F90FLAGS'] += ' -D_QUAD_PRECISION'

if env['target'] == 'debug':
  env.SetDefault(debug_level = '3')
  env.SetDefault(assertions = True)
  env.Append(F90FLAGS = ' -g -O0 -traceback -check all -debug all -fpe0')
  env['LINKFLAGS'] += ' -g -O0 -traceback -check all -debug all -fpe0'
elif env['target'] == 'profile':
  env.SetDefault(debug_level = '1')
  env.SetDefault(assertions = False)
  env(F90FLAGS = ' -g -trace -fast -inline-level=0 -funroll-loops -unroll')
  env['LINKFLAGS'] += ' -g -trace -O3 -ip -ipo'
elif env['target'] == 'release':
  env.SetDefault(debug_level = '1')
  env.SetDefault(assertions = False)
  env.Append(F90FLAGS = ' -fno-alias -fast -align all -inline-level=2 -funroll-loops -unroll -no-inline-min-size -no-inline-max-size -no-inline-max-per-routine -no-inline-max-per-compile -no-inline-factor -no-inline-max-total-size')
  env['LINKFLAGS'] += ' -O3 -ip -ipo'

env['LINKFLAGS'] += ' -vec-report' + env['vec_report']
env['F90FLAGS'] += ' -D_DEBUG_LEVEL=' + env['debug_level']

if env['assertions']:
  env['F90FLAGS'] += ' -D_ASSERT'

if env['standard']:
  env['F90FLAGS'] += ' -std'

if env['lib']:
  env['F90FLAGS'] += ' -fpic'
  env['LINKFLAGS'] += ' -fpic -shared'

# generate help text
Help(vars.GenerateHelpText(env))

#
# setup the program name and the build directory
#
program_name = 'samoa'

# add descriptors to the executable for any argument that is not default
program_name += '_' + env['scenario']

if env['openmp'] != default_env['openmp']:
  program_name += '_' + env['openmp']

if env['mpi'] == 'nompi':
  program_name += '_nompi'

if env['asagi'] != default_env['asagi']:
  program_name += '_' + env['asagi']

if env['swe_solver'] != default_env['swe_solver']:
  program_name += '_' + env['swe_solver']

if env['precision'] != default_env['precision']:
  program_name += '_' + env['precision']

if env['target'] != default_env['target']:
  program_name += '_' + env['target']

# set build directory
build_dir = env['build_dir']
object_dir = build_dir + 'build_'+ program_name + '/'
env.Append(F90FLAGS = ' -module ' + object_dir)
env['F90PATH'] = '.'

#copy F77 compiler settings from F90 compiler
env['FORTRAN'] = env['F90']
env['FORTRANFLAGS'] = env['F90FLAGS']
env['FORTRANPATH'] = env['F90PATH']

# get the source files
env.obj_files = []

Export('env')
SConscript('src/SConscript', variant_dir=object_dir, duplicate=0)
Import('env')

# build the program
env.Program(build_dir + program_name, env.obj_files)
