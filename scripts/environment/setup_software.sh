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

# Parse input parameters
source ${SCRIPTDIR}/parse_yaml.sh ${ENVDIR}/software "parameters"
# Parse data directory location
source ${SCRIPTDIR}/parse_yaml.sh ${SCRIPTDIR}/config "datadir"

# Setup bash environment for further commands
# Normally this should be set up previously by installing dependencies
source ${SCRIPTDIR}/setup_env.sh


usage() {
  echo "Usage: $0 [ --arguments (...) ]"
  echo
  echo "Possible arguments are the following:"
  echo
  echo "  --help    : Displays this message."
  echo "  --d2lpt   : Download 2LPTic source files to ${BUILDDIR}/2LPT-IC."
  echo "  --i2lpt   : Install 2LPTic to ${BUILDDIR}/2LPT-IC."
  echo "  --d2lptop : Download 2LPTic with opposite phase source files to ${BUILDDIR}/2LPT-IC-OP."
  echo "  --i2lptop : Install 2LPTic with opposite phase to ${BUILDDIR}/2LPT-IC-OP."
  echo "  --dg2     : Download GADGET2 source files to ${BUILDDIR}/GADGET2."
  echo "  --ig2     : Install GADGET2 to ${BUILDDIR}/GADGET2."
  echo "  --dg4     : Download GADGET4 source files to ${BUILDDIR}/GADGET4."
  echo "  --ig4     : Install GADGET4 to ${BUILDDIR}/GADGET4."
  echo "  --darepo  : Download Arepo source files to ${BUILDDIR}/Arepo."
  echo "  --iarepo  : Install Arepo to ${BUILDDIR}/Arepo."
  echo "  --dsteps  : Download StePS source files to ${BUILDDIR}/StePS."
  echo "  --isteps  : Install StePS to ${BUILDDIR}/StePS."
  echo "  --dgevol  : Download gevolution source files to ${BUILDDIR}/gevolution."
  echo "  --igevol  : Install gevolution to ${BUILDDIR}/gevolution."
  echo "  --dcgr    : Download CosmoGRaPH source files to ${BUILDDIR}/CosmoGRaPH."
  echo "  --icgr    : Install CosmoGRaPH to ${BUILDDIR}/CosmoGRaPH."
  echo "  --det     : Download EinteinToolkit with FLRWSolver to ${BUILDDIR}/EinsteinToolkit."
  echo "  --iet     : Install EinteinToolkit with FLRWSolver to ${BUILDDIR}/EinsteinToolkit."
  echo "  --dgv     : Download GADGETViewer ${GV_VER} source files to ${BUILDDIR}/GADGETViewer-${GV_VER}."
  echo "  --igv     : Install GADGETViewer ${GV_VER} to ${BUILDDIR}/GADGETViewer-${GV_VER}."
  echo "  --dgenpk  : Download GenPK source files to ${BUILDDIR}/GenPK."
  echo "  --igenpk  : Install GenPK to ${BUILDDIR}/GenPK."
  echo "  --help    : Displays this message."
  echo 
}

clean_up() {
  # Delete created `parameters*.sh` file at the end of the script
  rm ${SCRIPTDIR}/config/*-temp.sh
  rm ${ENVDIR}/software/*-temp.sh
}


FLAGS="d2lpt,i2lpt,d2lptop,i2lptop,dg2,ig2,dg4,ig4,darepo,iarepo,dsteps,isteps,\
dgevol,igevol,dcgr,icgr,det,iet,dgv,igv,dgenpk,igenpk,help"
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
  --d2lpt)
      export DLOAD_2LPT=true
      ;;
  --i2lpt)
      export INSTALL_2LPT=true
      ;;
  --d2lptop)
      export DLOAD_2LPT_OP=true
      ;;
  --i2lptop)
      export INSTALL_2LPT_OP=true
      ;;
  --dg2)
      export DLOAD_G2=true
      ;;
  --ig2)
      export INSTALL_G2=true
      ;;
  --dg4)
      export DLOAD_G4=true
      ;;
  --ig4)
      export INSTALL_G4=true
      ;;
  --dsteps)
      export DLOAD_STEPS=true
      ;;
  --isteps)
      export INSTALL_STEPS=true
      ;;
  --dgevol)
      export DLOAD_GEVOL=true
      ;;
  --igevol)
      export INSTALL_GEVOL=true
      ;;
  --dcgr)
      export DLOAD_CGRAPH=true
      ;;
  --icgr)
      export INSTALL_CGRAPH=true
      ;;
  --darepo)
      export DLOAD_AREPO=true
      ;;
  --iarepo)
      export INSTALL_AREPO=true
      ;;
  --dgv)
      export DLOAD_GV=true
      ;;
  --igv)
      export INSTALL_GV=true
      ;;
  --det)
      export DLOAD_ET=true
      ;;
  --iet)
      export INSTALL_ET=true
      ;;
  --dgenpk)
      export DLOAD_GENPK=true
      ;;
  --igenpk)
      export INSTALL_GENPK=true
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