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
  echo "  --help    : Displays this message."
  echo "  --i2lpt   : Install 2LPTic to ${BUILDDIR}/2LPT-IC."
  echo "  --i2lptop : Install 2LPTic with opposite phase to ${BUILDDIR}/2LPT-IC-OP."
  echo "  --ig2     : Install GADGET2 to ${BUILDDIR}/GADGET2."
  echo "  --ig4     : Install GADGET4 to ${BUILDDIR}/GADGET4."
  echo "  --igizmo  : Install GIZMO to ${BUILDDIR}/GIZMO."
  echo "  --iarepo  : Install Arepo to ${BUILDDIR}/Arepo."
  echo "  --isteps  : Install StePS to ${BUILDDIR}/StePS."
  echo "  --igevol  : Install gevolution to ${BUILDDIR}/gevolution."
  echo "  --icgr    : Install CosmoGRaPH to ${BUILDDIR}/CosmoGRaPH."
  echo "  --iet     : Install EinteinToolkit with FLRWSolver to ${BUILDDIR}/EinsteinToolkit."
  echo "  --igv     : Install GADGETViewer ${GV_VER} to ${BUILDDIR}/GADGETViewer-${GV_VER}."
  echo "  --igenpk  : Install GenPK to ${BUILDDIR}/GenPK."
  echo "  --isp     : Install SPLASH to ${BUILDDIR}/SPLASH"
  echo "  --force   : Force downloading all software selected for install."
  echo "  --help    : Displays this message."
  echo 
}

clean_up() {
  # Delete created `parameters*.sh` file at the end of the script
  rm ${SCRIPTDIR}/config/*-temp.sh
  rm ${ENVDIR}/software/*-temp.sh
}


# Parse input parameters
source ${SCRIPTDIR}/parse_yaml.sh ${ENVDIR}/software "parameters"
# Parse data directory location
source ${SCRIPTDIR}/parse_yaml.sh ${SCRIPTDIR}/config "datadir"

# Setup bash environment for further commands
# Normally this should be set up previously by installing dependencies
source ${SCRIPTDIR}/setup_env.sh


FLAGS="i2lpt,i2lptop,ig2,ig4,igizmo,iarepo,isteps,igevol,icgr,iet,igv,igenpk,isp,force,help"
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
  --i2lpt)
      export INSTALL_2LPT=true
      ;;
  --i2lptop)
      export INSTALL_2LPT_OP=true
      ;;
  --ig2)
      export INSTALL_G2=true
      ;;
  --ig4)
      export INSTALL_G4=true
      ;;
  --isteps)
      export INSTALL_STEPS=true
      ;;
  --igevol)
      export INSTALL_GEVOL=true
      ;;
  --icgr)
      export INSTALL_CGRAPH=true
      ;;
  --igizmo)
      export INSTALL_GIZMO=true
      ;;
  --iarepo)
      export INSTALL_AREPO=true
      ;;
  --igv)
      export INSTALL_GV=true
      ;;
  --iet)
      export INSTALL_ET=true
      ;;
  --igenpk)
      export INSTALL_GENPK=true
      ;;
  --isp)
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