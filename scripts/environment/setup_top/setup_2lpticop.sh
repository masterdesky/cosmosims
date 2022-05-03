#!/bin/bash

# Donwloading 2LPT-IC with opponent phase
if [[ ${DLOAD_2LPT_OP} = true ]]; then
  if [[ ! -d ${BUILDDIR}/2LPT-IC-OP ]]; then
    echo
    echo "Downloading 2LPT-IC-OP..."
    echo

    mkdir -p ${BUILDDIR}
    
    # Check no certificate, because `cosmo.nyu.edu` doesn't have a known issuer.
    # Updating `ca-certificate` seems not helping.
    # Currently this is an absolutely unsecure solution, but other hacky
    # solutions are also pretty unsecure.
    wget "http://cosmo.nyu.edu/roman/2LPT/2LPTic.tar.gz" --no-check-certificate -P ${BUILDDIR}
    tar -xzvf ${BUILDDIR}/2LPTic.tar.gz -C ${BUILDDIR}
    rm -f ${BUILDDIR}/2LPTic.tar.gz
    mv ${BUILDDIR}/2LPTic ${BUILDDIR}/2LPT-IC-OP
  fi
fi


if [[ ${INSTALL_2LPT_OP} = true ]];
then
  echo
  echo "Installing 2LPT-IC with opponent phase..."
  echo

  # (Re)installing 2LPT-IC
  cd ${BUILDDIR}/2LPT-IC-OP
  if [[ -f ${BUILDDIR}/2LPT-IC-OP/m.log ]]; then
      make clean |& tee >(ts "[%x %X]" > ${BUILDDIR}/2LPT-IC-OP/cl.log)
  fi
  ## Change part in code which enables us to run opposite phase simulations
  ## Line 216 in `main.c`
  sed -i '/.*phase =.*/ { s|PI|PI + PI|g };' ${BUILDDIR}/2LPT-IC-OP/main.c

  ## Prepare Makefile
  cp ${BUILDSYS}/2LPT-IC-OP/Makefile ${BUILDDIR}/2LPT-IC-OP/
  sed -i '/^GSL_LIBS/ { s|$| -L'"${GSL1_INSTALL}"'/lib|g }' ${BUILDDIR}/2LPT-IC-OP/Makefile
  sed -i '/^GSL_INCL/ { s|$| -I'"${GSL1_INSTALL}"'/include|g }' ${BUILDDIR}/2LPT-IC-OP/Makefile
  sed -i '/^FFTW_LIBS/ { s|$| -L'"${FFTW2_INSTALL}"'/lib|g }' ${BUILDDIR}/2LPT-IC-OP/Makefile
  sed -i '/^FFTW_INCL/ { s|$| -I'"${FFTW2_INSTALL}"'/include|g }' ${BUILDDIR}/2LPT-IC-OP/Makefile
  sed -i '/^MPICHLIB/ { s|$| -L'"${OMPI_INSTALL}"'/lib|g }' ${BUILDDIR}/2LPT-IC-OP/Makefile
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${BUILDDIR}/2LPT-IC-OP/m.log)
  cd ${BUILDDIR}
fi