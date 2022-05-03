#!/bin/bash

# ==============================================================================
#
#   nbody.sh
#
#   Handles the N-body simulations using GADGET4 or AREPO.
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
  echo "  --perturbate   : Apply 2LPT perturbations to the input glass."
  echo "  --n-body       : Perform the N-body simulation on the input glass."
  echo "  --gr           : Use the GR equations for the N-body simulation."
  echo "  --help         : Displays this message."
  echo 
}

clean_up() {
  # Delete created `*-temp.sh` files at the end of the script
  rm ${SIMDIR}/*-temp.sh
}


# Call getopt to validate the provided input. 
options=$(getopt -o '' --long calc-missing,perturbate,ophase,n-body,gr,help -- "$@")
[ $? -eq 0 ] || { 
    echo "Incorrect options provided" \
    | ts "[%x %X]"
    usage;
    exit 1
}
eval set -- "${options}"
while true; do
  case ${1} in
  --calc-missing)
      export CALC_MISSING=true
      ;;
  --perturbate)
      export PERTURBATE=true
      ;;
  --ophase)
      export O_PHASE=true
      ;;
  --n-body)
      export NBODY=true
      ;;
  --gevol)
      export GEVOL=true
      ;;
  --cgr)
      export CGR=true
      ;;
  --help)
      usage
      clean_up
      exit 1;
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

if [[ ${PERTURBATE} = true ]]; then
  # Perturbate glass with 2LPT-IC
  source ${SIMDIR}/nbody_sim/perturbate_2lptic.sh
fi

if [[ ${NBODY} = true ]]; then
  if [[ ${GEVOL} = true ]]; then
    echo "[NBODY] gevolution 1.2 simulation with GR physics." \
    | ts "[%x %X]"
    source ${SIMDIR}/nbody_sim/nbody_gevolution.sh
  elif [[ ${CGR} = true ]]; then
    echo "[NBODY] CosmoGRaPH simulation with GR physics." \
    | ts "[%x %X]"
    source ${SIMDIR}/nbody_sim/nbody_cgr.sh
  else
    echo "[NBODY] GADGET4 simulation with newtonian physics." \
    | ts "[%x %X]"
    ${SCRIPTDIR}/environment/start_top.sh --ig4
    source ${SIMDIR}/nbody_sim/nbody_gadget4.sh
  fi
fi


clean_up;