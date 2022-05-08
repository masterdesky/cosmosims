#!/bin/bash

# Donwloading gevolution
if [[ ${DLOAD_GEVOL} = true ]]; then
  if [[ ! -d ${BUILDDIR}/gevolution-1.2 ]]; then
    echo
    echo "Downloading gevolition..."
    echo
    
    mkdir -p ${BUILDDIR}

    git clone https://github.com/gevolution-code/gevolution-1.2.git ${BUILDDIR}/gevolution-1.2
  fi
fi


if [[ ${INSTALL_GEVOL} = true ]];
then
  echo
  echo "Installing gevolition..."
  echo

  echo ${LD_LIBRARY_PATH}

  # (Re)installing gevolution
  cd ${BUILDDIR}/gevolution-1.2
  if [[ -f ${BUILDDIR}/gevolution-1.2/m.log ]]; then
      make clean |& tee >(ts "[%x %X]" > ${BUILDDIR}/gevolution-1.2/cl.log)
  fi
  ## Prepare Makefile
  cp ${BUILDSYS}/gevolution/makefile ${BUILDDIR}/gevolution-1.2/
  ACTIVE_MK=${BUILDDIR}/gevolution-1.2/makefile
  sed -i '/^INCLUDE/ { s|$| -I'"${LAT2_INSTALL}"'/include|g }' ${ACTIVE_MK}
  sed -i '/^INCLUDE/ { s|$| -I'"${GSL2_INSTALL}"'/include|g }' ${ACTIVE_MK}
  sed -i '/^INCLUDE/ { s|$| -I'"${FFTW3_INSTALL}"'/include|g }' ${ACTIVE_MK}
  sed -i '/^INCLUDE/ { s|$| -I'"${HDF5_INSTALL}"'/include|g }' ${ACTIVE_MK}
  sed -i '/^LIB/ { s|$| -L'"${GSL2_INSTALL}"'/lib|g }' ${ACTIVE_MK}
  sed -i '/^LIB/ { s|$| -L'"${FFTW3_INSTALL}"'/lib|g }' ${ACTIVE_MK}
  sed -i '/^LIB/ { s|$| -L'"${HDF5_INSTALL}"'/lib|g }' ${ACTIVE_MK}
  sed -i '/^LIB/ { s|$| -lfftw3 -lm -lhdf5 -lgsl -lgslcblas|g }' ${ACTIVE_MK}
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${BUILDDIR}/gevolution-1.2/m.log)
  cd ${BUILDDIR}
fi