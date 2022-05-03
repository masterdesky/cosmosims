#!/bin/bash

# Donwloading 2LPT-IC
if [[ ${DLOAD_2LPT} = true ]]; then
  if [[ ! -d ${BUILDDIR}/2LPT-IC ]]; then
    echo
    echo "Downloading 2LPT-IC..."
    echo
    
    mkdir -p ${BUILDDIR}

    # Check no certificate, because `cosmo.nyu.edu` doesn't have a known issuer.
    # Updating `ca-certificate` seems not helping.
    # Currently this is an absolutely unsecure solution, but other hacky
    # solutions are also pretty unsecure.
    wget "http://cosmo.nyu.edu/roman/2LPT/2LPTic.tar.gz" --no-check-certificate -P ${BUILDDIR}
    tar -xzvf ${BUILDDIR}/2LPTic.tar.gz -C ${BUILDDIR}
    rm -f ${BUILDDIR}/2LPTic.tar.gz
    mv ${BUILDDIR}/2LPTic ${BUILDDIR}/2LPT-IC
  fi
fi


if [[ ${INSTALL_2LPT} = true ]];
then
  echo
  echo "Installing 2LPT-IC..."
  echo

  # (Re)installing 2LPT-IC
  cd ${BUILDDIR}/2LPT-IC
  if [[ -f ${BUILDDIR}/2LPT-IC/m.log ]]; then
      make clean |& tee >(ts "[%x %X]" > ${BUILDDIR}/2LPT-IC/cl.log)
  fi
  ## Prepare Makefile
  cp ${BUILDSYS}/2LPT-IC/Makefile ${BUILDDIR}/2LPT-IC/
  sed -i '/^GSL_LIBS/ { s|$| -L'"${GSL1_INSTALL}"'/lib|g }' ${BUILDDIR}/2LPT-IC/Makefile
  sed -i '/^GSL_INCL/ { s|$| -I'"${GSL1_INSTALL}"'/include|g }' ${BUILDDIR}/2LPT-IC/Makefile
  sed -i '/^FFTW_LIBS/ { s|$| -L'"${FFTW2_INSTALL}"'/lib|g }' ${BUILDDIR}/2LPT-IC/Makefile
  sed -i '/^FFTW_INCL/ { s|$| -I'"${FFTW2_INSTALL}"'/include|g }' ${BUILDDIR}/2LPT-IC/Makefile
  sed -i '/^MPICHLIB/ { s|$| -L'"${OMPI_INSTALL}"'/lib|g }' ${BUILDDIR}/2LPT-IC/Makefile
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${BUILDDIR}/2LPT-IC/m.log)
  cd ${BUILDDIR}
fi