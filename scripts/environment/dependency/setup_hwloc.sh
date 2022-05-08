#!/bin/bash


# Downloading and unpacking hwloc if necessary
if [[ ${DLOAD_HWLOC} = true ]]; then
  if [[ ! -d ${HWLOC_BUILD} ]]; then
    echo
    echo "Downloading hwloc ${HWLOC_VER}..."
    echo

    mkdir -p ${BUILDDIR}

    # Download hwloc
    wget "https://download.open-mpi.org/release/hwloc/v${HWLOC_VER%.*}/hwloc-${HWLOC_VER}.tar.gz" -P ${BUILDDIR}
    tar -xzvf ${BUILDDIR}/hwloc-${HWLOC_VER}.tar.gz -C ${BUILDDIR}
    rm -f ${BUILDDIR}/hwloc-${HWLOC_VER}.tar.gz
  fi
fi


if [[ ${INSTALL_HWLOC} = true ]];
then
    echo
    echo "Installing hwloc ${HWLOC_VER}..."
    echo

    mkdir -p ${INSTALLDIR}

    # (Re)install hwloc
    cd ${HWLOC_BUILD}
    if [ -f ${HWLOC_BUILD}/mi.log ]; then
        make uninstall |& tee >(ts "[%x %X]" > ${HWLOC_BUILD}/mu.log)
        make clean |& tee >(ts "[%x %X]" > ${HWLOC_BUILD}/cl.log)
    fi
    ./configure --prefix=${HWLOC_INSTALL} |& tee >(ts "[%x %X]" > ${HWLOC_BUILD}/c.log)
    make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${HWLOC_BUILD}/m.log)
    make install |& tee >(ts "[%x %X]" > ${HWLOC_BUILD}/mi.log)
    cd ${BUILDDIR}
fi