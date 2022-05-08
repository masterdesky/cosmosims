#!/bin/bash


# Downloading and unpacking FFTW 2.X if necessary
if [[ ${DLOAD_FFTW2} = true ]]; then
  if [[ ! -d ${FFTW2_BUILD} ]]; then
    echo
    echo "Downloading FFTW ${FFTW2_VERS}..."
    echo

    mkdir -p ${BUILDDIR}

    # Download FFTW 2.X
    wget "http://www.fftw.org/fftw-${FFTW2_VERS}.tar.gz" -P ${BUILDDIR}
    tar -xzvf ${BUILDDIR}/fftw-${FFTW2_VERS}.tar.gz -C ${BUILDDIR}
    rm -f ${BUILDDIR}/fftw-${FFTW2_VERS}.tar.gz
  fi
fi


if [[ ${INSTALL_FFTW2} = true ]];
then
    echo
    echo "Installing FFTW ${FFTW2_VERS}..."
    echo

    mkdir -p ${INSTALLDIR}

    # (Re)install FFTW 2.X
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