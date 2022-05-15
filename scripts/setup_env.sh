#!/bin/bash

# ==============================================================================
#
#   setup_env.sh
#
#   Exports the necessary global variables needed for the simulation softwares.
#		Also adding appropriate entries to the $PATH and $LD_LIBRARY_PATH variables.
#
#
# ==============================================================================

# Adding entries here by running the installation script of the
# basic applications
export OMPI_INSTALL=/home/masterdesky/opt/openmpi-4.1.3
export GSL1_INSTALL=/home/masterdesky/opt/gsl-1.9
export GSL2_INSTALL=/home/masterdesky/opt/gsl-2.7
export FFTW2_INSTALL=/home/masterdesky/opt/fftw-2.1.5
export FFTW3_INSTALL=/home/masterdesky/opt/fftw-3.3.10
export HWLOC_INSTALL=/home/masterdesky/opt/hwloc-2.6.0
export LAT2_INSTALL=/home/masterdesky/opt/LATfield2
export HDF5_INSTALL=/home/masterdesky/opt/hdf5-1.10.6


# Adding binaries to `PATH` variable
if [[ ":${PATH}:" != *":${OMPI_INSTALL}/bin:"* ]]; then
	export PATH="${OMPI_INSTALL}/bin:${PATH}"
fi


# Adding libraries to the `LD_LIBRARY_PATH` variable
for LIB_PATH in OMPI_INSTALL GSL1_INSTALL GSL2_INSTALL \
                FFTW2_INSTALL FFTW3_INSTALL HWLOC_INSTALL HDF5_INSTALL; do
	if [[ ":${LD_LIBRARY_PATH}:" != *":${!LIB_PATH}/lib:"* ]]; then
		export LD_LIBRARY_PATH="${!LIB_PATH}/lib:${LD_LIBRARY_PATH}"
	fi
done


# Setting include paths for GCC. Some software require the `C_INCLUDE_PATH` and
# `CPLUS_INCLUDE_PATH` variables to be set
for INCLUDE_PATH in LAT2_INSTALL FFTW2_INSTALL FFTW3_INSTALL HDF5_INSTALL; do
	if [[ ":${C_INCLUDE_PATH}:" != *":${!INCLUDE_PATH}/include:"* ]]; then
		export C_INCLUDE_PATH="${!INCLUDE_PATH}/include:${C_INCLUDE_PATH}"
	fi
	if [[ ":${CPLUS_INCLUDE_PATH}:" != *":${!INCLUDE_PATH}/include:"* ]]; then
		export CPLUS_INCLUDE_PATH="${!INCLUDE_PATH}/include:${CPLUS_INCLUDE_PATH}"
	fi
done


# Get `DATADIR` : The location of the data directory, where simulation software
# saves its outputs. Defaults to `${HOME}/data`
if [[ ! -z ${!COMPUTER} ]]; then
  export DATADIR=${!COMPUTER}
else
  export DATADIR=${HOME}/data
fi
echo "[INFO] Data directory is at the following path: ${DATADIR}" \
| ts "[%x %X]"


# Get `CONDAROOT` : The sourcedir of conda on the current machine
## A custom `CONDAROOT` can be set beforehand
export CONDAROOT=""
if [[ -z ${CONDAROOT} ]]; then
  CONDAROOT_OPT=(
    "/usr/local/miniconda3"
    "${HOME}/miniconda3"
    "/opt/conda"
  )
  for c in ${CONDAROOT_OPT[@]}; do
    if [[ -f ${c}/bin/conda ]]; then
      export CONDAROOT=${c}
      break
    fi
  done
fi
## Check whether if specifying/finding conda was successful
if [[ -z ${CONDAROOT} ]]; then
  echo "[ERROR] Conda could not be found on the machine!" \
  | ts "[%x %X]"
  clean_up
  exit 2
elif [[ ! -f ${CONDAROOT}/bin/conda ]]; then
  echo "[ERROR] Conda could not be found on the speified location!" \
  | ts "[%x %X]"
  clean_up
  exit 2
else
  echo "[INFO] Conda found at ${CONDAROOT}!" \
  | ts "[%x %X]"
fi