#!/bin/bash


if [[ ${INSTALL_GEVOL} = true ]];
then
  GEVOL_BUILD=${BUILDDIR}/gevolution-${GEVOL_VER}
  # Downloading gevolution
  if [[ ! -d ${GEVOL_BUILD} || ${FORCE} = true ]]; then
    echo
    echo "Downloading gevolition..."
    echo
    
    mkdir -p ${BUILDDIR}

    git clone https://github.com/gevolution-code/gevolution-${GEVOL_VER}.git ${GEVOL_BUILD}
  fi

  
  # Installing gevolution
  echo
  echo "Installing gevolution..."
  echo

  cd ${GEVOL_BUILD}
  # Uninstall previous version
  if [[ -f ${GEVOL_BUILD}/m.log ]]; then
      make clean |& tee >(ts "[%x %X]" > ${GEVOL_BUILD}/cl.log)
  fi
  ## Prepare Makefile
  cp ${BUILDSYS}/gevolution/makefile ${GEVOL_BUILD}/
  sed -i '/^INCLUDE/ { s|$| -I'"${LAT2_INSTALL}"'/include|g }' ${GEVOL_BUILD}/makefile
  sed -i '/^INCLUDE/ { s|$| -I'"${GSL2_INSTALL}"'/include|g }' ${GEVOL_BUILD}/makefile
  sed -i '/^INCLUDE/ { s|$| -I'"${FFTW3_INSTALL}"'/include|g }' ${GEVOL_BUILD}/makefile
  sed -i '/^INCLUDE/ { s|$| -I'"${HDF5_INSTALL}"'/include|g }' ${GEVOL_BUILD}/makefile
  sed -i '/^LIB/ { s|$| -L'"${GSL2_INSTALL}"'/lib|g }' ${GEVOL_BUILD}/makefile
  sed -i '/^LIB/ { s|$| -L'"${FFTW3_INSTALL}"'/lib|g }' ${GEVOL_BUILD}/makefile
  sed -i '/^LIB/ { s|$| -L'"${HDF5_INSTALL}"'/lib|g }' ${GEVOL_BUILD}/makefile
  sed -i '/^LIB/ { s|$| -lfftw3 -lm -lhdf5 -lgsl -lgslcblas|g }' ${GEVOL_BUILD}/makefile
  ## Install gevolution 
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${GEVOL_BUILD}/m.log)
  cd ${BUILDDIR}
fi