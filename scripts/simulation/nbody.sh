#!/bin/bash

# ==============================================================================
#
#   nbody.sh
#
#   Handles the N-body simulations.
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
    echo "  --g2           : Use GADGET-2 for the N-body simulation."
    echo "  --g4           : Use GADGET-4 for the N-body simulation."
    echo "  --gevol        : Use gevolution for the N-body simulation."
    echo "  --cgr          : Use CosmoGRaPH for the hydrodynamic GR simulation."
    echo "  --et           : Use the EinsteinToolkit for the hydrodynamic GR simulation."
    echo "  --arepo        : Use AREPO for the hydrodynamic simulation."
    echo "  --help         : Displays this message."
    echo 
}

clean_up() {
    # Delete created `*-temp.sh` files upon exit
    rm ${SCRIPTDIR}/config/*-temp.sh
    rm ${SIMDIR}/*-temp.sh

    # Delete conda environment created for N-body simulations
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

# Setup conda environment for N-body simulations
conda create --name cosmo-nbody python numpy astropy -y


FLAGS="calc-missing,g2,g4,gevol,cgr,et,arepo,help"
# Call getopt to validate the provided input. 
options=$(getopt -o '' --long ${FLAGS} -- "$@")
[ $? -eq 0 ] || { 
    echo "[NBODY] Incorrect options provided" \
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
    --g2)
        export G2=true
        ;;
    --g4)
        export G4=true
        ;;
    --gevol)
        export GEVOL=true
        ;;
    --cgr)
        export CGR=true
        ;;
    --et)
        export ET=true
        ;;
    --arepo)
        export AREPO=true
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
if [[ ${CALC_MISSING} = true ]]; then
    ## Activate environment containing numpy and astropy
    conda activate cosmo-calc
    ## Calculate missing variables and write them into the `parameters-*.sh` file
    ${SIMDIR}/calc_variables.py ${H0} ${RES} ${LBOX} ${LBOX_PER} ${SIMDIR}
    ## Souce newly calculated variables
    for PAR in ${SIMDIR}/*-temp.sh; do
        source ${PAR}
    done
    conda deactivate
fi

if [[ ${G2} = true ]]; then
    echo "[NBODY] GADGET2 simulation with newtonian physics." \
    | ts "[%x %X]"
    ${SCRIPTDIR}/environment/setup_software.sh --ig2
    source ${SIMDIR}/nbody_sim/nbody_gadget2.sh
elif [[ ${G4} = true ]]; then
    echo "[NBODY] GADGET4 simulation with newtonian physics." \
    | ts "[%x %X]"
    ${SCRIPTDIR}/environment/setup_software.sh --ig4
    source ${SIMDIR}/nbody_sim/nbody_gadget4.sh
elif [[ ${GEVOL} = true ]]; then
    echo "[NBODY] gevolution 1.2 simulation with GR physics." \
    | ts "[%x %X]"
    source ${SIMDIR}/nbody_sim/nbody_gevolution.sh
elif [[ ${CGR} = true ]]; then
    echo "[NBODY] CosmoGRaPH simulation with GR physics." \
    | ts "[%x %X]"
    source ${SIMDIR}/nbody_sim/nbody_cgr.sh
elif [[ ${ET} = true ]]; then
    echo "[NBODY] EinsteinToolkit simulation with GR physics." \
    | ts "[%x %X]"
    source ${SIMDIR}/nbody_sim/nbody_et.sh
elif [[ ${AREPO} = true ]]; then
    echo "[NBODY] AREPO hydro simulation with newtonian physics." \
    | ts "[%x %X]"
    source ${SIMDIR}/nbody_sim/nbody_arepo.sh
fi


clean_up;