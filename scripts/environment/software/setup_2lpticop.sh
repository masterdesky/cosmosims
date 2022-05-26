#!/bin/bash


if [[ ${INSTALL_2LPT} = true ]];
then
  2LPT_BUILD=${BUILDDIR}/2LPT-IC-OP
  # Downloading 2LPT-IC
  if [[ ! -d ${2LPT_BUILD} || ${FORCE} = true ]]; then
    echo
    echo "Downloading 2LPT-IC with opposite phase..."
    echo

    # If previous download exists, delete it first (relevant in case of forced install)
    if [[ -d ${GV_BUILD} ]]; then
      rm -rf ${GV_BUILD}
    fi
    
    mkdir -p ${BUILDDIR}

    # Check no certificate, because `cosmo.nyu.edu` doesn't have a known issuer.
    # Updating `ca-certificate` does not help in this case.
    # Currently this is an absolutely unsecure solution, but deal with it.
    wget "http://cosmo.nyu.edu/roman/2LPT/2LPTic.tar.gz" --no-check-certificate -P ${BUILDDIR}
    tar -xzvf ${BUILDDIR}/2LPTic.tar.gz -C ${BUILDDIR}
    rm -f ${BUILDDIR}/2LPTic.tar.gz
    mv ${BUILDDIR}/2LPTic ${2LPT_BUILD}
  fi


  # Installing 2LPT-IC
  echo
  echo "Installing 2LPT-IC with opposite phase..."
  echo

  cd ${2LPT_BUILD}
  # Uninstall previous version
  if [[ -f ${2LPT_BUILD}/m.log ]]; then
      make clean |& tee >(ts "[%x %X]" > ${2LPT_BUILD}/cl.log)
  fi
  ## Prepare Makefile
  cp ${BUILDSYS}/2LPT-IC/Makefile ${2LPT_BUILD}/
  sed -i '/^GSL_LIBS/ { s|$| -L'"${GSL1_INSTALL}"'/lib|g }' ${2LPT_BUILD}/Makefile
  sed -i '/^GSL_INCL/ { s|$| -I'"${GSL1_INSTALL}"'/include|g }' ${2LPT_BUILD}/Makefile
  sed -i '/^FFTW_LIBS/ { s|$| -L'"${FFTW2_INSTALL}"'/lib|g }' ${2LPT_BUILD}/Makefile
  sed -i '/^FFTW_INCL/ { s|$| -I'"${FFTW2_INSTALL}"'/include|g }' ${2LPT_BUILD}/Makefile
  sed -i '/^MPICHLIB/ { s|$| -L'"${OMPI_INSTALL}"'/lib|g }' ${2LPT_BUILD}/Makefile

  ## Change part in code which enables us to run opposite phase simulations
  ## Line 216 in `main.c`
  sed -i '/.*phase =.*/ { s|PI|PI + PI|g };' ${2LPT_BUILD}/main.c

  ## Install 2LPT-IC
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${2LPT_BUILD}/m.log)
  cd ${BUILDDIR}
fi