#!/bin/bash

# Prerequisites
# - conda installed for user with an environment called `steps`, 
#   containing python, numpy, pandas, scipy, future, matplotlib,
#		seaborn, astropy and h5py. This can be setup via
#     `conda create --name steps python numpy pandas scipy future matplotlib seaborn astropy h5py`
#
# - Autotools, whose binaries and libraries can be installed via
#			`sudo apt install automake autoconf libtool libedit`
#
# - Git that can be installed via
#     `sudo apt install git`

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