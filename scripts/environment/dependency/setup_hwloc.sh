#!/bin/bash


if [[ ${INSTALL_HWLOC} = true ]]; then
  # Downloading the Portable Hardware Locality software package
  if [[ ! -d ${HWLOC_BUILD} || ${FORCE} = true ]]; then
    echo
    echo "Downloading hwloc ${HWLOC_VER}..."
    echo

    # If previous download exists, delete it first (relevant in case of forced install)
    if [[ -d ${HWLOC_BUILD} ]]; then
      rm -rf ${HWLOC_BUILD}
    fi

    mkdir -p ${BUILDDIR}

    # Download hwloc
    wget "https://download.open-mpi.org/release/hwloc/v${HWLOC_VER%.*}/hwloc-${HWLOC_VER}.tar.gz" -P ${BUILDDIR}
    tar -xzvf ${BUILDDIR}/hwloc-${HWLOC_VER}.tar.gz -C ${BUILDDIR}
    rm -f ${BUILDDIR}/hwloc-${HWLOC_VER}.tar.gz
  fi

  # Installing the Portable Hardware Locality software package
  echo
  echo "Installing hwloc ${HWLOC_VER}..."
  echo

  mkdir -p ${INSTALLDIR}

  cd ${HWLOC_BUILD}
  # Uninstall previous version
  if [ -f ${HWLOC_BUILD}/mi.log ]; then
      make uninstall |& tee >(ts "[%x %X]" > ${HWLOC_BUILD}/mu.log)
      make clean |& tee >(ts "[%x %X]" > ${HWLOC_BUILD}/cl.log)
  fi
  # Install hwloc
  ./configure --prefix=${HWLOC_INSTALL} |& tee >(ts "[%x %X]" > ${HWLOC_BUILD}/c.log)
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${HWLOC_BUILD}/m.log)
  make install |& tee >(ts "[%x %X]" > ${HWLOC_BUILD}/mi.log)
  cd ${BUILDDIR}
fi