#!/bin/bash

# ==============================================================================
#
#   glass.sh
#
#   Handles the glass generation using StePS or GADGET2.
#
# 
# ==============================================================================

# THE `SIMDIR` directory will be defined as the directory that contains all
# the simulation scripts (`glass.sh`, `nbody.sh` and `full.sh`) and all related
# files and directories
export SIMDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# The `SCRIPTDIR` directory will be defined as the directory that contains all
# the scripts and folders that are used during the configuration and simulation
# pipelines
export SCRIPTDIR="$( dirname "${SIMDIR}" )"
# The `PIPELINEDIR` directory will be defined as the directory that contains all
# files and folders used during the configuration and simulation pipelines. This
# includes the `scripts`, `logs` and `data` directories.
export PIPELINEDIR="$( dirname "${SCRIPTDIR}" )"

# Parse input parameters
source ${SCRIPTDIR}/environment/parse_yaml.sh ${SIMDIR} "parameters"
source ${SCRIPTDIR}/environment/parse_yaml.sh ${SIMDIR} "datadir"

# Setup bash environment for further commands
# Normally this should be set up previously by installing the basic apps
source ${SCRIPTDIR}/environment/setup_env.sh

# Set environmental variables for the simulations
source ${SIMDIR}/setup_sim.sh


usage() {
  echo "Usage: $0 [ --arguments (...) ]"
  echo
  echo "Possible arguments are the following:"
  echo
  echo "  --calc-missing : Calculates necessary variables for the simulations."
  echo "  --glass-ic     : Generate initial conditions for the glass generation."
  echo "  --glass-sim    : Perform the glass simulation on CPU or GPU."
  echo "  --force-g2     : Run glass and glass IC generation using GADGET-2."
  echo "  --force-steps  : Run glass generation using StePS."
  echo "  --help         : Displays this message."
  echo 
}

clean_up() {
  # Delete created `*-temp.sh` files at the end of the script
  rm ${SIMDIR}/*-temp.sh
}


# Call getopt to validate the provided input. 
options=$(getopt -o '' --long calc-missing,glass-ic,glass-sim,force-g2,force-steps,help -- "$@")
[ $? -eq 0 ] || { 
    echo "[GLASS GEN] Incorrect options provided" \
    | ts "[%x %X]"
    usage
    exit 1
}
eval set -- "${options}"
while true; do
  case ${1} in
  --calc-missing)
      export CALC_MISSING=true
      ;;
  --glass-ic)
      export GLASS_IC_GEN=true
      ;;
  --glass-sim)
      export GLASS_SIM=true
      ;;
  --force-g2)
      export FORCE_G2=true
      ;;
  --force-steps)
      export FORCE_STEPS=true
      ;;
  --help)
      usage
      clean_up
      exit 1
      ;;
  --)
      break
      shift
      ;;
  esac
  shift
done


# Calculate missing variables
#
## Conda should be sourced by the user
if [[ ${CALC_MISSING} = true ]]; then
  ## Activate environment containing astropy and the basic packages
  conda activate cosmo
  ## Calculate missing variables and write them into the `parameters-*.sh` file
  ${SIMDIR}/edit_variables.py ${H0} ${LBOX} ${LBOX_PER} ${SIMDIR}
  ## Export newly calculated variables
  for PAR in ${SIMDIR}/*-temp.sh; do
    source ${PAR}
  done
  conda deactivate
fi


# Perform glass generation
if [[ ${FORCE_STEPS} = true ]]; then
  if [[ ${GLASS_SIM} = true ]]; then
    echo
    echo "[GLASS GEN] StePS simulation with ${MBINS} mass bin." \
    | ts "[%x %X]"
  fi
  source ${SIMDIR}/glass_sim/glass_StePS.sh
else
  if [[ ${GLASS_SIM} = true ]]; then
    echo
    echo "[GLASS GEN] GADGET2 simulation with ${MBINS} mass bin." \
    | ts "[%x %X]"
  fi
  source ${SIMDIR}/glass_sim/glass_gadget2.sh
fi


clean_up;