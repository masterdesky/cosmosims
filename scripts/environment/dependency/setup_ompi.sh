#!/bin/bash


# Downloading and unpacking OpenMPI if necessary
if [[ ${DLOAD_OMPI} = true ]]; then
  if [[ ! -d ${OMPI_BUILD} ]]; then
    echo
    echo "Downloading OpenMPI ${OMPI_VER}..."
    echo

    mkdir -p ${BUILDDIR}

    # Download OpenMPI
    wget "https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-${OMPI_VER}.tar.gz" -P ${BUILDDIR}
    tar -xzvf ${BUILDDIR}/openmpi-${OMPI_VER}.tar.gz -C ${BUILDDIR}
    rm -f ${BUILDDIR}/openmpi-${OMPI_VER}.tar.gz
  fi
fi


if [[ ${INSTALL_OMPI} = true ]];
then
    echo
    echo "Installing OpenMPI ${OMPI_VER}..."
    echo

    mkdir -p ${INSTALLDIR}

    # (Re)install OpenMPI
    cd ${OMPI_BUILD}
    if [ -f ${OMPI_BUILD}/mi.log ]; then
        make uninstall |& tee >(ts "[%x %X]" > ${OMPI_BUILD}/mu.log)
        make clean |& tee >(ts "[%x %X]" > ${OMPI_BUILD}/cl.log)
    fi
    if [ -d /usr/cuda ] || [ -d /usr/local/cuda ];
    then
        ./configure --prefix=${OMPI_INSTALL} --with-cuda \
                    |& tee >(ts "[%x %X]" > ${OMPI_BUILD}/c.log)
    else
        ./configure --prefix=${OMPI_INSTALL} \
                    |& tee >(ts "[%x %X]" > ${OMPI_BUILD}/c.log)
    fi
    make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${OMPI_BUILD}/m.log)
    make install |& tee >(ts "[%x %X]" > ${OMPI_BUILD}/mi.log)
    cd ${BUILDDIR}
fi