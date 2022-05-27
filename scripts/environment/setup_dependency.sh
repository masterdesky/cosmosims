#!/bin/bash

# ==============================================================================
#
#   setup_dependency.sh
#
#   Downloads and installs the requested dependencies required for
#   most cosmological softwares.
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
  echo "  --iompi  : Install OpenMPI ${OMPI_VER} to ${INSTALLDIR}."
  echo "  --igsl1  : Install GSL ${GSL1_VER} to ${INSTALLDIR}."
  echo "  --igsl2  : Install GSL ${GSL2_VER} to ${INSTALLDIR}."
  echo "  --ifftw2 : Install FFTW ${FFTW2_VER} to ${INSTALLDIR}."
  echo "  --ifftw3 : Install FFTW ${FFTW3_VER} to ${INSTALLDIR}."
  echo "  --ihwloc : Install hwloc ${HWLOC_VER} to ${INSTALLDIR}."
  echo "  --ilat2  : Install LATfield2 to ${INSTALLDIR}."
  echo "  --ihdf5  : Install HDF ${HDF5_VER} to ${INSTALLDIR}."
  echo "  --force  : Force the download of the software selected for install."
  echo "  --help   : Displays this message."
  echo 
}

clean_up() {
  # Delete created `parameters*.sh` file at the end of the script
  rm ${SCRIPTDIR}/config/*-temp.sh
  rm ${ENVDIR}/dependency/*-temp.sh
}


# Parse input parameters
source ${SCRIPTDIR}/parse_yaml.sh ${ENVDIR}/dependency "parameters"
# Parse machine parameters
source ${SCRIPTDIR}/parse_yaml.sh ${SCRIPTDIR}/config "machine"
# Parse data directory location
source ${SCRIPTDIR}/parse_yaml.sh ${SCRIPTDIR}/config "datadir"

# Setup bash environment for further commands
# Normally this should be set up previously by installing the basic apps
source ${SCRIPTDIR}/setup_env.sh


FLAGS="iompi,igsl1,igsl2,ifftw2,ifftw3,ihwloc,ilat2,ihdf5,force,help"
# Call getopt to validate the provided input. 
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
  --iompi)
      export INSTALL_OMPI=true
      export OMPI_BUILD=${BUILDDIR}/openmpi-${OMPI_VER}
      export OMPI_INSTALL=${INSTALLDIR}/openmpi-${OMPI_VER}
      sed -i '/^export OMPI/ { s|\=.*|='"${OMPI_INSTALL}"'| }' ${SCRIPTDIR}/setup_env.sh
      ;;
  --igsl1)
      export INSTALL_GSL1=true
      export GSL1_BUILD=${BUILDDIR}/gsl-${GSL1_VER}
      export GSL1_INSTALL=${INSTALLDIR}/gsl-${GSL1_VER}
      sed -i '/^export GSL1/ { s|\=.*|='"${GSL1_INSTALL}"'| }' ${SCRIPTDIR}/setup_env.sh
      ;;
  --igsl2)
      export INSTALL_GSL2=true
      export GSL2_BUILD=${BUILDDIR}/gsl-${GSL2_VER}
      export GSL2_INSTALL=${INSTALLDIR}/gsl-${GSL2_VER}
      sed -i '/^export GSL2/ { s|\=.*|='"${GSL2_INSTALL}"'| }' ${SCRIPTDIR}/setup_env.sh
      ;;
  --ifftw2)
      export INSTALL_FFTW2=true
      export FFTW2_BUILD=${BUILDDIR}/fftw-${FFTW2_VER}
      export FFTW2_INSTALL=${INSTALLDIR}/fftw-${FFTW2_VER}
      sed -i '/^export FFTW2/ { s|\=.*|='"${FFTW2_INSTALL}"'| }' ${SCRIPTDIR}/setup_env.sh
      ;;
  --ifftw3)
      export INSTALL_FFTW3=true
      export FFTW3_BUILD=${BUILDDIR}/fftw-${FFTW3_VER}
      export FFTW3_INSTALL=${INSTALLDIR}/fftw-${FFTW3_VER}
      sed -i '/^export FFTW3/ { s|\=.*|='"${FFTW3_INSTALL}"'| }' ${SCRIPTDIR}/setup_env.sh
      ;;
  --ihwloc)
      export INSTALL_HWLOC=true
      export HWLOC_BUILD=${BUILDDIR}/hwloc-${HWLOC_VER}
      export HWLOC_INSTALL=${INSTALLDIR}/hwloc-${HWLOC_VER}
      sed -i '/^export HWLOC/ { s|=.*|='"${HWLOC_INSTALL}"'| }' ${SCRIPTDIR}/setup_env.sh
      ;;
  --ilat2)
      export INSTALL_LAT2=true
      export LAT2_BUILD=${BUILDDIR}/LATfield2
      export LAT2_INSTALL=${INSTALLDIR}/LATfield2
      sed -i '/^export LAT2/ { s|=.*|='"${LAT2_INSTALL}"'| }' ${SCRIPTDIR}/setup_env.sh
      ;;
  --ihdf5)
      export INSTALL_HDF5=true
      export HDF5_BUILD=${BUILDDIR}/hdf5-${HDF5_VER}    
      export HDF5_INSTALL=${INSTALLDIR}/hdf5-${HDF5_VER}
      sed -i '/^export HDF5/ { s|=.*|='"${HDF5_INSTALL}"'| }' ${SCRIPTDIR}/setup_env.sh
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
for setup_file in ${ENVDIR}/dependency/setup*.sh; do
  bash ${setup_file} || break  # execute successfully or break
done


clean_up;