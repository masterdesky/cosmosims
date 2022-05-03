#!/bin/bash

# ==============================================================================
#
#   setup_sim.sh
#
#   Handles the enviromental setup for the simulations themeselves.
#
# 
# ==============================================================================

# `DATADIR` location depending where the simulations run. It matters only for
# specific servers.
if [[ ! -z ${!COMPUTER} ]]; then
  export DATADIR=${!COMPUTER}
else
  export DATADIR=${HOME}/data
fi


# Check if parameters are correctly set
##  1. NPART
if [[ ${NPART} < 1 ]]; then
  echo "[ERROR] NPART should be an integer greater than 1!" | ts "[%x %X]"
  clean_up
  exit 2
fi
##  2. LBOX
if [[ ${LBOX} < 0 ]]; then
  echo "[ERROR] LBOX should be positive!" | ts "[%x %X]"
  clean_up
  exit 2
fi
##  3. LBOX_PER
if [[ ${LBOX_PER} < 0 || ${LBOX_PER} < ${LBOX} ]]; then
  echo "[ERROR] LBOX_PER should be positive and greater than LBOX!" | ts "[%x %X]"
  clean_up
  exit 2
fi
##  4.  MBINS
if [[ ${MBINS} < 1 ]]; then
  echo "[ERROR] MBINS should be an integer greater than 1!" | ts "[%x %X]"
  clean_up
  exit 2
## If there is only a single mass bin, then there's no need to set the
## minimum number of particles in a mass bin  
if [[ ${MBINS} = 1 ]]; then
  export PARTMIN=1
fi


# Template name for all output files of the simulations
## Common ending for non-periodic volumes (eg. glass ICs and glasses)
export SUFFIX=N${NPART}_L${LBOX}_M${MBINS}_min${PARTMIN}
## Common ending for directories containing non-periodic volumes
export SUFFIX_DIR=N${NPART}_L${LBOX}_M${MBINS}
## Common ending for periodic volumes (eg. perturbed glasses and N-body sim.)
export SUFFIX_PER=N${NPART}_L${LBOX_PER}_M${MBINS}_min${PARTMIN}
## Common ending for directories containing periodic volumes
export SUFFIX_PER_DIR=N${NPART}_L${LBOX_PER}_M${MBINS}


# Get the location of `conda.sh`
if [[ -d /usr/local/miniconda3 ]]; then
  export CONDAROOT=/usr/local/miniconda3
elif [[ -d /opt/conda ]]; then
  export CONDAROOT=/opt/conda
elif [[ -d ${HOME}/miniconda3 ]]; then
  export CONDAROOT=${HOME}/miniconda3
else
  echo "[ERROR] Conda could not be found on the machine!" | ts "[%x %X]"
  clean_up
  exit 1
fi
# `conda.sh` should be sourced first if `conda` is ran from bash script
source ${CONDAROOT}/etc/profile.d/conda.sh