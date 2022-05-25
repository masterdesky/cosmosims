#!/bin/bash


if [[ ${INSTALL_FFTW3} = true ]]; then
  if [[ ! -d ${FFTW3_BUILD} || ${FORCE} = true ]]; then
  # Downloading Fastest Fourier Transform in the West 3.X
    echo
    echo "Downloading FFTW ${FFTW3_VER}..."
    echo

    # If previous download exists, delete it first (relevant in case of forced install)
    if [[ -d ${FFTW3_BUILD} ]]; then
      rm -rf ${FFTW3_BUILD}
    fi

    mkdir -p ${BUILDDIR}

    # Download FFTW 3.X
    wget "http://www.fftw.org/fftw-${FFTW3_VER}.tar.gz" -P ${BUILDDIR}
    tar -xzvf ${BUILDDIR}/fftw-${FFTW3_VER}.tar.gz -C ${BUILDDIR}
    rm -f ${BUILDDIR}/fftw-${FFTW3_VER}.tar.gz
  fi

  # Installing Fastest Fourier Transform in the West 3.X
  echo
  echo "Installing FFTW ${FFTW3_VER}..."
  echo

  # Check for dependencies (OpenMPI this case)
  if [[ -z "${OMPI_INSTALL}" || ! -d "${OMPI_INSTALL}" ]]; then
    echo "OpenMPI is not installed!"
    clean_up
    exit 1
  fi

  mkdir -p ${INSTALLDIR}

  cd ${FFTW3_BUILD}
  # Uninstall trailing 32 and 64 bit versions
  if [ -f ${FFTW3_BUILD}/mi32.log ]; then
      ./configure --prefix=${FFTW3_INSTALL} \
                  --enable-mpi --enable-float --enable-threads \
                  LDFLAGS=-L${OMPI_INSTALL}/lib CFLAGS=-I${OMPI_INSTALL}/include  # No need for logging
      make uninstall |& tee >(ts "[%x %X]" > ${FFTW3_BUILD}/mu.log)
      make clean |& tee >(ts "[%x %X]" > ${FFTW3_BUILD}/cl.log)
  fi
  if [ -f ${FFTW3_BUILD}/mi64.log ]; then
      ./configure --prefix=${FFTW3_INSTALL} \
                  --enable-mpi --enable-threads \
                  LDFLAGS=-L${OMPI_INSTALL}/lib CFLAGS=-I${OMPI_INSTALL}/include  # No need for logging
      make uninstall |& tee >(ts "[%x %X]" > ${FFTW3_BUILD}/mu.log)
      make clean |& tee >(ts "[%x %X]" > ${FFTW3_BUILD}/cl.log)
  fi
  # Install FFTW 3.X with 32 bit precision
  ./configure --prefix=${FFTW3_INSTALL} \
              --enable-mpi --enable-float --enable-threads \
              LDFLAGS=-L${OMPI_INSTALL}/lib CFLAGS=-I${OMPI_INSTALL}/include \
              |& tee >(ts "[%x %X]" > ${FFTW3_BUILD}/c32.log)
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${FFTW3_BUILD}/m32.log)
  make install |& tee >(ts "[%x %X]" > ${FFTW3_BUILD}/mi32.log)
  # Install FFTW 3.X with 64 bit precision
  ./configure --prefix=${FFTW3_INSTALL} \
              --enable-mpi --enable-threads \
              LDFLAGS=-L${OMPI_INSTALL}/lib CFLAGS=-I${OMPI_INSTALL}/include \
              |& tee >(ts "[%x %X]" > ${FFTW3_BUILD}/c64.log)
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${FFTW3_BUILD}/m64.log)
  make install |& tee >(ts "[%x %X]" > ${FFTW3_BUILD}/mi64.log)
  cd ${BUILDDIR}
fi