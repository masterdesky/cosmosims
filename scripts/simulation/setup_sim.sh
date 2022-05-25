#!/bin/bash

# ==============================================================================
#
#   setup_sim.sh
#
#   Handles the enviromental setup for the simulations themeselves.
#
# 
# ==============================================================================


# Check if parameters are correctly set
##  1. NPART : - Number of simulated particles in N-body simulations
##             - Number of simulated HD volumes in HD simulations 
if [[ ${NPART} < 1 ]]; then
  echo "[ERROR] NPART should be an integer greater than 1!" \
  | ts "[%x %X]"
  clean_up
  exit 2
fi
##  2. LBOX : - Boxsize of periodic, cubical simulations
if [[ ${LBOX} < 0 ]]; then
  echo "[ERROR] LBOX should be positive!" \
  | ts "[%x %X]"
  clean_up
  exit 2
fi
##  3. LBOX_PER : - Boxsize of the tiled, periodic, cubical simulations. Tiling
##                  could be used to generate glasses of bigger size or 
if [[ ${LBOX_PER} < 0 || ${LBOX_PER} < ${LBOX} ]]; then
  echo "[ERROR] LBOX_PER should be positive and greater than LBOX!" \
  | ts "[%x %X]"
  clean_up
  exit 2
fi
##  4.  MBINS : - Number of different masses that given to particles in N-body
##                simulations that support this feature (Eg. StePS, GADGET)
if [[ ${MBINS} < 1 ]]; then
  echo "[ERROR] MBINS should be an integer greater than 0!" \
  | ts "[%x %X]"
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