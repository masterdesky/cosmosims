#!/bin/bash

# Prerequisites
# -------------
# - conda installed for user with an environment called `steps`, 
#   containing python, numpy, pandas, scipy, future, matplotlib,
#   seaborn, astropy and h5py. This can be setup via
#       `conda create --name steps python numpy pandas scipy future matplotlib seaborn astropy h5py`
#
# - Valid C, C++ and Fortran compilers, eg. GCC and GFortran that can be
#   installed via
#       `sudo apt install build-essential gfortran`
#
# - Autotools, whose binaries and libraries can be installed via
#       `sudo apt install automake autoconf libtool libedit`
#
# - Git that can be installed via
#       `sudo apt install git`
#
# - For GadgetViewer, at least GTK+ 2.0 is required that can be installed via
#       `sudo apt install libgtk2.0-dev`
#   GadgetViewer also requires some additional libraries if compiled using
#   GCC 11.2+:
#       `sudo apt install libtool texinfo`
#
# - The FLRWSolver thorn for the Cactus framework requires the linking of
#   static Python libraries manually. This is done using the `python3-config`
#   command that is part of the `python3-dev` apt package. This has to be
#   installed first via
#       `sudo apt install python3-dev`

# The `SCRIPTDIR` directory will be defined as the directory containing the 
#`start.sh` script, as well as all the other scripts used during the simulation
# pipeline
export SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# The `PIPELINEDIR` directory is the directory above the `SCRIPTDIR`
export PIPELINEDIR="${SCRIPTDIR%/*}"

# Parse input parameters
source ${SCRIPTDIR}/parse_yaml.sh
# Setup bash environment for further scripts
source ${SCRIPTDIR}/setup_env.sh

# Set up basic applications and libraries
source ${SCRIPTDIR}/start_basic.sh

# Set up top applications
source ${SCRIPTDIR}/start_top.sh

# Start simulation
source ${SCRIPTDIR}/start_sim.sh