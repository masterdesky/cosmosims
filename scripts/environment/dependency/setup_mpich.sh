#!/bin/bash


if [[ ${INSTALL_MPICH} = true ]]; then
  # Downloading MPICH
  if [[ ! -d ${MPICH_BUILD} || ${FORCE} = true ]]; then
    echo
    echo "Downloading MPICH ${MPICH_VER}..."
    echo

    # If previous download exists, delete it first (relevant in case of forced install)
    if [[ -d ${MPICH_BUILD} ]]; then
      rm -rf ${MPICH_BUILD}
    fi

    mkdir -p ${BUILDDIR}

    # Download MPICH
    if [[ ${MPICH_PREFIX::1} < 3 ]]; then
        MPICH_PREFIX="mpich2"
    else
        MPICH_PREFIX="mpich"
    fi
    wget "https://www.mpich.org/static/downloads/${MPICH_VER}/${MPICH_PREFIX}-${MPICH_VER}.tar.gz"
    tar -xzvf ${BUILDDIR}/${MPICH_PREFIX}-${MPICH_VER}.tar.gz -C ${BUILDDIR}
    rm -f ${BUILDDIR}/${MPICH_PREFIX}-${MPICH_VER}.tar.gz
  fi

  # Installing MPICH
  echo
  echo "Installing MPICH ${MPICH_VER}..."
  echo

  mkdir -p ${INSTALLDIR}

  cd ${MPICH_BUILD}
  # Uninstall previous version
  if [ -f ${MPICH_BUILD}/mi.log ]; then
    make uninstall |& tee >(ts "[%x %X]" > ${MPICH_BUILD}/mu.log)
    make clean |& tee >(ts "[%x %X]" > ${MPICH_BUILD}/cl.log)
  fi
  # Install MPICH
  ./configure --prefix=${MPICH_INSTALL} \
              |& tee >(ts "[%x %X]" > ${MPICH_BUILD}/c.log)
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${MPICH_BUILD}/m.log)
  make install |& tee >(ts "[%x %X]" > ${MPICH_BUILD}/mi.log)
  cd ${BUILDDIR}
fi