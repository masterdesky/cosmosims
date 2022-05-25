#!/bin/bash


if [[ ${INSTALL_OMPI} = true ]]; then
  # Downloading OpenMPI
  if [[ ! -d ${OMPI_BUILD} || ${FORCE} = true ]]; then
    echo
    echo "Downloading OpenMPI ${OMPI_VER}..."
    echo

    # If previous download exists, delete it first (relevant in case of forced install)
    if [[ -d ${OMPI_BUILD} ]]; then
      rm -rf ${OMPI_BUILD}
    fi

    mkdir -p ${BUILDDIR}

    # Download OpenMPI
    wget "https://download.open-mpi.org/release/open-mpi/v${OMPI_VER%.*}/openmpi-${OMPI_VER}.tar.gz" -P ${BUILDDIR}
    tar -xzvf ${BUILDDIR}/openmpi-${OMPI_VER}.tar.gz -C ${BUILDDIR}
    rm -f ${BUILDDIR}/openmpi-${OMPI_VER}.tar.gz
  fi

  # Installing OpenMPI
  echo
  echo "Installing OpenMPI ${OMPI_VER}..."
  echo

  mkdir -p ${INSTALLDIR}

  cd ${OMPI_BUILD}
  # Uninstall previous version
  if [ -f ${OMPI_BUILD}/mi.log ]; then
    make uninstall |& tee >(ts "[%x %X]" > ${OMPI_BUILD}/mu.log)
    make clean |& tee >(ts "[%x %X]" > ${OMPI_BUILD}/cl.log)
  fi
  # Install OpenMPI
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