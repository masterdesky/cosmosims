#!/bin/bash


# Downloading HDF5 latest development version if necessary
# My computer (Debian 11 Bullseye): HDF5 1.10.6 is supported
# ELTE servers (Ubuntu 20_04 Focal): HDF5 1.10.4 is supported
if [[ ${DLOAD_HDF5} = true ]]; then
  if [[ ! -d ${HDF5_BUILD} ]]; then
    echo
    echo "Downloading HDF5 ${HDF5_VER}..."
    echo

    mkdir -p ${BUILDDIR}

    # Download HDF5
    #mkdir -p ${BUILDDIR}/hdf5-${HDF5_VER}
    #cd ${BUILDDIR}/hdf5-${HDF5_VER}
    #apt-get source libhdf5-dev=${HDF5_VER}
    wget "https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${HDF5_VER%.*}/hdf5-${HDF5_VER}/src/hdf5-${HDF5_VER}.tar.gz" -P ${BUILDDIR}
    tar -xzvf ${BUILDDIR}/hdf5-${HDF5_VER}.tar.gz -C ${BUILDDIR}
    rm -f ${BUILDDIR}/hdf5-${HDF5_VER}.tar.gz
  fi
fi


if [[ ${INSTALL_HDF5} = true ]];
then
    echo
    echo "Installing HDF5 ${HDF5_VER}..."
    echo

    mkdir -p ${INSTALLDIR}

    # (Re)install HDF5
    cd ${HDF5_BUILD}
    if [[ -f ${HDF5_BUILD}/mi.log ]]; then
        make uninstall |& tee >(ts "[%x %X]" > ${HDF5_BUILD}/mu.log)
        make clean |& tee >(ts "[%x %X]" > ${HDF5_BUILD}/cl.log)
    fi
    ./configure --prefix=${HDF5_INSTALL} \
                |& tee >(ts "[%x %X]" > ${HDF5_BUILD}/c.log)
    make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${HDF5_BUILD}/m.log)
    make install |& tee >(ts "[%x %X]" > ${HDF5_BUILD}/mi.log)
    cd ${BUILDDIR}
fi