#!/bin/bash


if [[ ${INSTALL_HDF5} = true ]]; then
  if [[ ! -d ${HDF5_BUILD} || ${FORCE} = true ]]; then
    # Downloading Hierarchical Data Format 5
    echo
    echo "Downloading HDF5 ${HDF5_VER}..."
    echo

    # If previous download exists, delete it first (relevant in case of forced install)
    if [[ -d ${HDF5_BUILD} ]]; then
      rm -rf ${HDF5_BUILD}
    fi

    mkdir -p ${BUILDDIR}

    # Download HDF5
    wget "https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${HDF5_VER%.*}/hdf5-${HDF5_VER}/src/hdf5-${HDF5_VER}.tar.gz" -P ${BUILDDIR}
    tar -xzvf ${BUILDDIR}/hdf5-${HDF5_VER}.tar.gz -C ${BUILDDIR}
    rm -f ${BUILDDIR}/hdf5-${HDF5_VER}.tar.gz
  fi
  
  # Installing Hierarchical Data Format 5
  echo
  echo "Installing HDF5 ${HDF5_VER}..."
  echo

  mkdir -p ${INSTALLDIR}

  cd ${HDF5_BUILD}
  # Uninstall previous version
  if [[ -f ${HDF5_BUILD}/mi.log ]]; then
    make uninstall |& tee >(ts "[%x %X]" > ${HDF5_BUILD}/mu.log)
    make clean |& tee >(ts "[%x %X]" > ${HDF5_BUILD}/cl.log)
  fi
  # Install HDF5
  ./configure --prefix=${HDF5_INSTALL} \
              |& tee >(ts "[%x %X]" > ${HDF5_BUILD}/c.log)
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${HDF5_BUILD}/m.log)
  make install |& tee >(ts "[%x %X]" > ${HDF5_BUILD}/mi.log)
  cd ${BUILDDIR}
fi