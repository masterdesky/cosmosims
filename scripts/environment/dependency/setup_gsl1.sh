#!/bin/bash


if [[ ${INSTALL_GSL1} = true ]]; then
  # Downloading GNU Scientific Library 1.X
  if [[ ! -d ${GSL1_BUILD} || ${FORCE} = true ]]; then
    echo
    echo "Downloading GSL ${GSL1_VER}..."
    echo

    # If previous download exists, delete it first (relevant in case of forced install)
    if [[ -d ${GSL1_BUILD} ]]; then
      rm -rf ${GSL1_BUILD}
    fi

    mkdir -p ${BUILDDIR}

    # Download GSL 1.X
    wget "https://quantum-mirror.hu/mirrors/pub/gnu/gsl/gsl-${GSL1_VER}.tar.gz" -P ${BUILDDIR}
    tar -xzvf ${BUILDDIR}/gsl-${GSL1_VER}.tar.gz -C ${BUILDDIR}
    rm -f ${BUILDDIR}/gsl-${GSL1_VER}.tar.gz
  fi

  # Installing GNU Scientific Library 1.X
  echo
  echo "Installing GSL ${GSL1_VER}..."
  echo

  mkdir -p ${INSTALLDIR}

  cd ${GSL1_BUILD}
  # Uninstall previous version
  if [ -f ${GSL1_BUILD}/mi.log ]; then
    make uninstall |& tee >(ts "[%x %X]" > ${GSL1_BUILD}/mu.log)
    make clean |& tee >(ts "[%x %X]" > ${GSL1_BUILD}/cl.log)
  fi
  # Install GSL 1.X
  ./configure --prefix=${GSL1_INSTALL} |& tee >(ts "[%x %X]" > ${GSL1_BUILD}/c.log)
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${GSL1_BUILD}/m.log)
  make install |& tee >(ts "[%x %X]" > ${GSL1_BUILD}/mi.log)
  cd ${BUILDDIR}
fi