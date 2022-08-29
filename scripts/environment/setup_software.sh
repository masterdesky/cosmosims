#!/bin/bash

# ==============================================================================
#
#   setup_software.sh
#
#   Downloads and installs the requested simulation softwares.
#
#
# ==============================================================================

# The `ENVDIR` directory will be defined as the directory containing the 
# install scripts for cosmological software and their dependencies, as well as
# the build directory that contains the config files needed to build the
# requested softwares
export ENVDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# The `SCRIPTDIR` directory will be defined as the directory that contains all
# the scripts and folders that are used during the configuration and simulation
# pipelines
export SCRIPTDIR="$( dirname "${ENVDIR}" )"


usage() {
  echo "Usage: $0 [ --arguments (...) ]"
  echo
  echo "Possible arguments are the following:"
  echo
  echo "  --2lpt   : Install 2LPTic to ${BUILDDIR}/2LPT-IC."
  echo "  --2lptop : Install 2LPTic with opposite phase to ${BUILDDIR}/2LPT-IC-OP."
  echo "  --g2     : Install GADGET2 to ${BUILDDIR}/GADGET2."
  echo "  --g4     : Install GADGET4 to ${BUILDDIR}/GADGET4."
  echo "  --steps  : Install StePS to ${BUILDDIR}/StePS."
  echo "  --gizmo  : Install GIZMO to ${BUILDDIR}/GIZMO."
  echo "  --arepo  : Install Arepo to ${BUILDDIR}/Arepo."
  echo "  --gevol  : Install gevolution to ${BUILDDIR}/gevolution."
  echo "  --cgr    : Install CosmoGRaPH to ${BUILDDIR}/CosmoGRaPH."
  echo "  --et     : Install EinteinToolkit with FLRWSolver to ${BUILDDIR}/EinsteinToolkit."
  echo "  --gv     : Install GADGETViewer ${GV_VER} to ${BUILDDIR}/GADGETViewer-${GV_VER}."
  echo "  --genpk  : Install GenPK to ${BUILDDIR}/GenPK."
  echo "  --pyl3   : Install Pylians3 to ${BUILDDIR}/Pylians3."
  echo "  --sp     : Install SPLASH to ${BUILDDIR}/SPLASH."
  echo "  --force  : Force the download of all software selected for install."
  echo "  --help   : Display this message."
  echo 
}

clean_up() {
  # Delete created `parameters*.sh` file at the end of the script
  rm ${SCRIPTDIR}/config/*-temp.sh
  rm ${ENVDIR}/software/*-temp.sh
}


# Parse input parameters
source ${SCRIPTDIR}/parse_yaml.sh ${ENVDIR}/software "parameters"
# Parse machine parameters
source ${SCRIPTDIR}/parse_yaml.sh ${SCRIPTDIR}/config "machine"
# Parse data directory location
source ${SCRIPTDIR}/parse_yaml.sh ${SCRIPTDIR}/config "datadir"

# Setup bash environment for further commands
# Normally this should be set up previously by installing dependencies
source ${SCRIPTDIR}/setup_env.sh


FLAGS="2lpt,2lptop,g2,g4,steps,gizmo,arepo,gevol,cgr,et,gv,genpk,pyl3,sp,force,help"
# Call getopt to validate the provided input 
options=$(getopt -o '' --long ${FLAGS} -- "$@")
[ $? -eq 0 ] || { 
    echo "Incorrect options provided" \
    | ts "[%x %X]"
    usage;
    exit 1
}
eval set -- "${options}"
while true; do
  case ${1} in
  --2lpt)
      export INSTALL_2LPT=true
      ;;
  --2lptop)
      export INSTALL_2LPT_OP=true
      ;;
  --g2)
      export INSTALL_G2=true
      ;;
  --g4)
      export INSTALL_G4=true
      ;;
  --steps)
      export INSTALL_STEPS=true
      ;;
  --gizmo)
      export INSTALL_GIZMO=true
      ;;
  --arepo)
      export INSTALL_AREPO=true
      ;;
  --gevol)
      export INSTALL_GEVOL=true
      ;;
  --cgr)
      export INSTALL_CGRAPH=true
      ;;
  --et)
      export INSTALL_ET=true
      ;;
  --gv)
      export INSTALL_GV=true
      ;;
  --genpk)
      export INSTALL_GENPK=true
      ;;
	--pyl3)
      export INSTALL_PYL3=true
      ;;
  --sp)
      export INSTALL_SP=true
      ;;
  --force)
      export FORCE=true
      ;;
  --help)
      usage
      clean_up
      exit 1;
      ;;
  --)
      shift
      break
      ;;
  esac
  shift
done


# Download necessary softwares, then configure, build and install them
for setup_file in ${ENVDIR}/software/setup*.sh; do
  bash ${setup_file} || break  # execute successfully or break
done


clean_up;