#!/bin/bash


if [[ ${INSTALL_GSL2} = true ]]; then
  # Downloading GNU Scientific Library 2.X
  if [[ ! -d ${GSL2_BUILD} || ${FORCE} = true ]]; then
    echo
    echo "Downloading GSL ${GSL2_VER}..."
    echo

    # If previous download exists, delete it first (relevant in case of forced install)
    if [[ -d ${GSL2_BUILD} ]]; then
      rm -rf ${GSL2_BUILD}
    fi

    mkdir -p ${BUILDDIR}

    # Download GSL 2.X
    wget "https://quantum-mirror.hu/mirrors/pub/gnu/gsl/gsl-${GSL2_VER}.tar.gz" -P ${BUILDDIR}
    tar -xzvf ${BUILDDIR}/gsl-${GSL2_VER}.tar.gz -C ${BUILDDIR}
    rm -f ${BUILDDIR}/gsl-${GSL2_VER}.tar.gz
  fi

  # Installing GNU Scientific Library 2.X
  echo
  echo "Installing GSL ${GSL2_VER}..."
  echo

  mkdir -p ${INSTALLDIR}

  cd ${GSL2_BUILD}
  # Uninstall previous version
  if [ -f ${GSL2_BUILD}/mi.log ]; then
    make uninstall |& tee >(ts "[%x %X]" > ${GSL2_BUILD}/mu.log)
    make clean |& tee >(ts "[%x %X]" > ${GSL2_BUILD}/cl.log)
  fi
  # Install GSL 2.X
  ./configure --prefix=${GSL2_INSTALL} |& tee >(ts "[%x %X]" > ${GSL2_BUILD}/c.log)
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${GSL2_BUILD}/m.log)
  make install |& tee >(ts "[%x %X]" > ${GSL2_BUILD}/mi.log)
  cd ${BUILDDIR}
fi