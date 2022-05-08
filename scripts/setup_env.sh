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
export OMPI_INSTALL=/home/masterdesky/opt/openmpi-4.1.1
export GSL1_INSTALL=/home/masterdesky/opt/gsl-1.9
export GSL2_INSTALL=/home/masterdesky/opt/gsl-2.7
export FFTW2_INSTALL=/home/masterdesky/opt/fftw-2.1.5
export FFTW3_INSTALL=/home/masterdesky/opt/fftw-3.3.10
export HWLOC_INSTALL=/home/masterdesky/opt/hwloc-2.6.0
export LAT2_INSTALL=/home/masterdesky/opt/LATfield2
export HDF5_INSTALL=/home/masterdesky/opt/hdf5-1.12.1


# Adding binaries to $PATH variable
if [[ ":${PATH}:" != *":${OMPI_INSTALL}/bin:"* ]]; then
	export PATH="${OMPI_INSTALL}/bin:${PATH}"
fi

# Adding libraries to the $LD_LIBRARY_PATH variable
for LIB_PATH in OMPI_INSTALL GSL1_INSTALL GSL2_INSTALL \
                FFTW2_INSTALL FFTW3_INSTALL HWLOC_INSTALL HDF5_INSTALL; do
	if [[ ":${LD_LIBRARY_PATH}:" != *":${!LIB_PATH}/lib:"* ]]; then
		export LD_LIBRARY_PATH="${!LIB_PATH}/lib:${LD_LIBRARY_PATH}"
	fi
done

# Setting include paths for gcc
for INCLUDE_PATH in LAT2_INSTALL FFTW2_INSTALL FFTW3_INSTALL HDF5_INSTALL; do
	if [[ ":${C_INCLUDE_PATH}:" != *":${!INCLUDE_PATH}/include:"* ]]; then
		export C_INCLUDE_PATH="${!INCLUDE_PATH}/include:${C_INCLUDE_PATH}"
	fi
	if [[ ":${CPLUS_INCLUDE_PATH}:" != *":${!INCLUDE_PATH}/include:"* ]]; then
		export CPLUS_INCLUDE_PATH="${!INCLUDE_PATH}/include:${CPLUS_INCLUDE_PATH}"
	fi
done


# Initialize conda for the shell
## Get the location of `conda.sh`
if [[ -d /usr/local/miniconda3 ]]; then
  export CONDAROOT=/usr/local/miniconda3
  echo "[INFO] Conda found at /usr/local/miniconda3"
elif [[ -d /opt/conda ]]; then
  export CONDAROOT=/opt/conda
  echo "[INFO] Conda found at /opt/conda"
elif [[ -d ${HOME}/miniconda3 ]]; then
  export CONDAROOT=${HOME}/miniconda3
  echo "[INFO] Conda found at ${HOME}/miniconda3"
else
  echo "[ERROR] Conda could not be found on the machine!" | ts "[%x %X]"
  clean_up
  exit 1
fi
## `conda.sh` should be sourced first if `conda` is ran from bash script
source ${CONDAROOT}/etc/profile.d/conda.sh