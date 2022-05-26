#!/bin/bash


if [[ ${INSTALL_2LPT} = true ]];
then
  LPT_BUILD=${BUILDDIR}/2LPT-IC
  # Downloading 2LPT-IC
  if [[ ! -d ${LPT_BUILD} || ${FORCE} = true ]]; then
    echo
    echo "Downloading 2LPT-IC..."
    echo

    # If previous download exists, delete it first (relevant in case of forced install)
    if [[ -d ${GV_BUILD} ]]; then
      rm -rf ${GV_BUILD}
    fi
    
    mkdir -p ${BUILDDIR}

    # Check no certificate, because `cosmo.nyu.edu` doesn't have a known issuer.
    # Updating `ca-certificate` seems not helping.
    # Currently this is an absolutely unsecure solution, but other hacky
    # solutions are also pretty unsecure.
    wget "http://cosmo.nyu.edu/roman/2LPT/2LPTic.tar.gz" --no-check-certificate -P ${BUILDDIR}
    tar -xzvf ${BUILDDIR}/2LPTic.tar.gz -C ${BUILDDIR}
    rm -f ${BUILDDIR}/2LPTic.tar.gz
    mv ${BUILDDIR}/2LPTic ${LPT_BUILD}
  fi


  # Installing 2LPT-IC
  echo
  echo "Installing 2LPT-IC..."
  echo

  cd ${LPT_BUILD}
  # Uninstall previous version
  if [[ -f ${LPT_BUILD}/m.log ]]; then
      make clean |& tee >(ts "[%x %X]" > ${LPT_BUILD}/cl.log)
  fi
  ## Prepare Makefile
  cp ${BUILDSYS}/2LPT-IC/Makefile ${LPT_BUILD}/
  sed -i '/^GSL_LIBS/ { s|$| -L'"${GSL1_INSTALL}"'/lib|g }' ${LPT_BUILD}/Makefile
  sed -i '/^GSL_INCL/ { s|$| -I'"${GSL1_INSTALL}"'/include|g }' ${LPT_BUILD}/Makefile
  sed -i '/^FFTW_LIBS/ { s|$| -L'"${FFTW2_INSTALL}"'/lib|g }' ${LPT_BUILD}/Makefile
  sed -i '/^FFTW_INCL/ { s|$| -I'"${FFTW2_INSTALL}"'/include|g }' ${LPT_BUILD}/Makefile
  sed -i '/^MPICHLIB/ { s|$| -L'"${OMPI_INSTALL}"'/lib|g }' ${LPT_BUILD}/Makefile
  ## Install 2LPT-IC
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${LPT_BUILD}/m.log)
  cd ${BUILDDIR}
fi