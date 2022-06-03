#!/bin/bash

# The `ANADIR` directory will be defined as the directory containing the 
# analysis scripts for cosmological simulations by `cosmosims`
export ANADIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# The `SCRIPTDIR` directory will be defined as the directory that contains all
# the scripts and folders that are used during the configuration and simulation
# pipelines
export SCRIPTDIR="$( dirname "${ANADIR}" )"


clean_up() {
  # Delete created `parameters*.sh` file at the end of the script
  rm ${SCRIPTDIR}/config/*-temp.sh
}


# Parse machine parameters
source ${SCRIPTDIR}/parse_yaml.sh ${SCRIPTDIR}/config "machine"
# Parse data directory location
source ${SCRIPTDIR}/parse_yaml.sh ${SCRIPTDIR}/config "datadir"

# Setup bash environment for further commands
# Normally this should be set up previously by installing dependencies
source ${SCRIPTDIR}/setup_env.sh


# Setup conda env for using Pylians3
#if { conda env list | grep 'cosmo-analysis'; } >/dev/null 2>&1; then
#    conda remove --name cosmo-analysis --all -y
#fi
#conda create --name cosmo-analysis python numpy scipy h5py matplotlib pyfftw -y

# `conda.sh` should be sourced first if `conda` is ran from a bash script
source ${CONDAROOT}/etc/profile.d/conda.sh
conda activate cosmo-analysis

python3 ${ANADIR}/power_spectrum.py $1 $2
python3 ${ANADIR}/find_voids.py $1 $2

conda deactivate

clean_up;