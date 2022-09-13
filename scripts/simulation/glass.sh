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
# the simulation scripts (`glass.sh` and `nbody.sh`) and all related files
# and directories
export SIMDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# The `SCRIPTDIR` directory will be defined as the directory that contains all
# the scripts and folders that are used during the configuration and simulation
# pipelines
export SCRIPTDIR="$( dirname "${SIMDIR}" )"
# The `ROOTDIR` directory will be defined as the directory that contains all
# files and folders of the `cosmosims` repository
export ROOTDIR="$( dirname "${SCRIPTDIR}" )"


usage() {
    echo 
    echo "Usage: $0 [ --arguments (...) ]"
    echo
    echo "Possible arguments are the following:"
    echo
    echo "  --calc-missing : Calculates necessary variables for the simulations."
    echo "  --glass-ic     : Generate initial conditions for the glass generation."
    echo "  --glass-sim    : Perform the glass simulation on CPU or GPU."
    echo "  --force-g2     : Run glass and glass IC generation using GADGET-2."
    echo "  --force-steps  : Run glass generation using StePS."
    echo "  --perturbate   : Apply 2LPT perturbations to the input glass."
    echo "  --ophase       : Apply opposite phase 2LPT perturbations."
    echo "  --help         : Displays this message."
    echo 
}

clean_up() {
    # Delete created `*-temp.sh` files upon exit
    rm ${SCRIPTDIR}/config/*-temp.sh
    rm ${SIMDIR}/*-temp.sh

    # Delete conda environment created for N-body sims. and glass gen.
    if { conda env list | grep 'cosmo-nbody'; } >/dev/null 2>&1; then
        conda remove --name cosmo-nbody --all -y
    fi
}
# Initial clean up previous sessions
clean_up;


# Parse input parameters
source ${SCRIPTDIR}/parse_yaml.sh ${SIMDIR} "parameters"
# Parse machine parameters
source ${SCRIPTDIR}/parse_yaml.sh ${SCRIPTDIR}/config "machine"
# Parse data directory location
source ${SCRIPTDIR}/parse_yaml.sh ${SCRIPTDIR}/config "datadir"

# Setup bash environment for further commands
# Normally this should be set up previously by installing the basic apps
source ${SCRIPTDIR}/setup_env.sh


FLAGS="calc-missing,glass-ic,glass-sim,force-g2,force-steps,perturbate,ophase,help"
# Call getopt to validate the provided input. 
options=$(getopt -o '' --long ${FLAGS} -- "$@")
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
    --perturbate)
        export PERTURBATE=true
        ;;
    --ophase)
        export O_PHASE=true
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


# Setup conda environment for N-body sims. and glass gen.
conda create --name cosmo-nbody python numpy astropy -y

# Calculate missing variables
if [[ ${CALC_MISSING} = true ]]; then
    ## Activate environment containing numpy and astropy
    conda activate cosmo-nbody
    ## Calculate missing variables and write them into the `parameters-*.sh` file
    ${SIMDIR}/calc_variables.py ${H0} ${LBOX} ${LBOX_PER} ${SIMDIR}
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
        echo "[GLASS GEN] StePS simulation with ${MBINS} mass bins." \
        | ts "[%x %X]"
    fi
    source ${SIMDIR}/glass_linear/glass_StePS.sh
else
    if [[ ${GLASS_SIM} = true ]]; then
        echo
        echo "[GLASS GEN] GADGET2 simulation with ${MBINS} mass bins." \
        | ts "[%x %X]"
    fi
    source ${SIMDIR}/glass_linear/glass_gadget2.sh
fi


# Add non-linear components to the linear glass
if [[ ${PERTURBATE} = true ]]; then
    # Perturbate glass with 2LPT-IC
    source ${SIMDIR}/glass_nonlinear/perturbate_2lptic.sh
fi


clean_up;