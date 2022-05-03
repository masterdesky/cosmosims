#!/bin/bash

# Downloading StePS
if [[ ${DLOAD_STEPS} = true ]]; then
  if [[ ! -d ${BUILDDIR}/StePS ]]; then
    echo
    echo "Downloading StePS..."
    echo

    mkdir -p ${BUILDDIR}

    git clone https://github.com/eltevo/StePS.git ${BUILDDIR}/StePS
  fi
fi


if [[ ${INSTALL_STEPS} = true ]];
then
  echo
  echo "Installing StePS..."
  echo

  # (Re)installing StePS
  cd ${BUILDDIR}/StePS/StePS/src
  if [[ -f ${BUILDDIR}/StePS/StePS/src/m.log ]]; then
      make clean |& tee >(ts "[%x %X]" > ${BUILDDIR}/StePS/StePS/src/cl.log)
  fi
  ## Prepare Makefile
  cp ${BUILDSYS}/StePS/Makefile ${BUILDDIR}/StePS/StePS/src/
  sed -i '/^MPI_LIBS/ { s|$| -L'"${OMPI_INSTALL}"'/lib|g }' ${BUILDDIR}/StePS/StePS/src/Makefile
  sed -i '/^MPI_INC/ { s|$|  -I'"${OMPI_INSTALL}"'/include|g }' ${BUILDDIR}/StePS/StePS/src/Makefile
  sed -i '/^HDF5_LIBS/ { s|$| -L'"${HDF5_INSTALL}"'/lib -lhdf5|g }' ${BUILDDIR}/StePS/StePS/src/Makefile
  sed -i '/^HDF5_INC/ { s|$|  -I'"${HDF5_INSTALL}"'/include|g }' ${BUILDDIR}/StePS/StePS/src/Makefile
  ## Add `#include <cstring>` to `inputoutput.cc`
  sed -i '/^#include <stdlib.h>/ { s|$| \n#include <cstring>| }' ${BUILDDIR}/StePS/StePS/src/inputoutput.cc
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${BUILDDIR}/StePS/StePS/src/m.log)
  cd ${BUILDDIR}
fi