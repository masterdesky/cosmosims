#!/bin/bash


if [[ ${INSTALL_FFTW2} = true ]]; then
  # Downloading Fastest Fourier Transform in the West 2.X
  if [[ ! -d ${FFTW2_BUILD} || ${FORCE} = true ]]; then
    echo
    echo "Downloading FFTW ${FFTW2_VER}..."
    echo

    # If previous download exists, delete it first (relevant in case of forced install)
    if [[ -d ${FFTW2_BUILD} ]]; then
      rm -rf ${FFTW2_BUILD}
    fi

    mkdir -p ${BUILDDIR}

    # Download FFTW 2.X
    wget "http://www.fftw.org/fftw-${FFTW2_VER}.tar.gz" -P ${BUILDDIR}
    tar -xzvf ${BUILDDIR}/fftw-${FFTW2_VER}.tar.gz -C ${BUILDDIR}
    rm -f ${BUILDDIR}/fftw-${FFTW2_VER}.tar.gz
  fi

  # Installing Fastest Fourier Transform in the West 2.X
  echo
  echo "Installing FFTW ${FFTW2_VER}..."
  echo

  # Check for dependencies (OpenMPI this case)
  if [[ -z "${OMPI_INSTALL}" || ! -d "${OMPI_INSTALL}" ]]; then
    echo "OpenMPI is not installed!"
    clean_up
    exit 1
  fi

  mkdir -p ${INSTALLDIR}

  cd ${FFTW2_BUILD}
  # Uninstall trailing 32 and 64 bit versions
  if [ -f ${FFTW2_BUILD}/mi32.log ]; then
      ./configure --prefix=${FFTW2_INSTALL} \
                  --enable-mpi --enable-float --enable-type-prefix \
                  LDFLAGS=-L${OMPI_INSTALL}/lib CPPFLAGS=-I${OMPI_INSTALL}/include  # No need for logging
      make uninstall |& tee >(ts "[%x %X]" > ${FFTW2_BUILD}/mu.log)
      make clean |& tee >(ts "[%x %X]" > ${FFTW2_BUILD}/cl.log)
  fi
  if [ -f ${FFTW2_BUILD}/mi64.log ]; then
      ./configure --prefix=${FFTW2_INSTALL} \
                  --enable-mpi --enable-type-prefix \
                  LDFLAGS=-L${OMPI_INSTALL}/lib CPPFLAGS=-I${OMPI_INSTALL}/include  # No need for logging
      make uninstall |& tee >(ts "[%x %X]" > ${FFTW2_BUILD}/mu.log)
      make clean |& tee >(ts "[%x %X]" > ${FFTW2_BUILD}/cl.log)
  fi
  # Install FFTW 2.X with 32 bit precision
  ./configure --prefix=${FFTW2_INSTALL} \
              --enable-mpi --enable-float --enable-type-prefix \
              LDFLAGS=-L${OMPI_INSTALL}/lib CPPFLAGS=-I${OMPI_INSTALL}/include \
              |& tee >(ts "[%x %X]" > ${FFTW2_BUILD}/c32.log)
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${FFTW2_BUILD}/m32.log)
  make install |& tee >(ts "[%x %X]" > ${FFTW2_BUILD}/mi32.log)
  # Install FFTW 2.X with 64 bit precision
  ./configure --prefix=${FFTW2_INSTALL} \
              --enable-mpi --enable-type-prefix \
              LDFLAGS=-L${OMPI_INSTALL}/lib CPPFLAGS=-I${OMPI_INSTALL}/include \
              |& tee >(ts "[%x %X]" > ${FFTW2_BUILD}/c64.log)
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${FFTW2_BUILD}/m64.log)
  make install |& tee >(ts "[%x %X]" > ${FFTW2_BUILD}/mi64.log)
  cd ${BUILDDIR}
fi