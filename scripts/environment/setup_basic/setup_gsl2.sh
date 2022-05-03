#!/bin/bash


# Downloading and unpacking GSL 2.X if necessary
if [[ ${DLOAD_GSL2} = true ]]; then
  if [[ ! -d ${GSL2_BUILD} ]]; then
    echo
    echo "Downloading GSL ${GSL2_VERS}..."
    echo

    mkdir -p ${BUILDDIR}

    # Download GSL 2.X
    wget "https://quantum-mirror.hu/mirrors/pub/gnu/gsl/gsl-${GSL2_VERS}.tar.gz" -P ${BUILDDIR}
    tar -xzvf ${BUILDDIR}/gsl-${GSL2_VERS}.tar.gz -C ${BUILDDIR}
    rm -f ${BUILDDIR}/gsl-${GSL2_VERS}.tar.gz
  fi
fi


if [[ ${INSTALL_GSL2} = true ]];
then
    echo
    echo "Installing GSL ${GSL2_VERS}..."
    echo

    mkdir -p ${INSTALLDIR}

    # (Re)install GSL 2.X
    cd ${GSL2_BUILD}
    if [ -f ${GSL2_BUILD}/mi.log ]; then
        make uninstall |& tee >(ts "[%x %X]" > ${GSL2_BUILD}/mu.log)
        make clean |& tee >(ts "[%x %X]" > ${GSL2_BUILD}/cl.log)
    fi
    ./configure --prefix=${GSL2_INSTALL} |& tee >(ts "[%x %X]" > ${GSL2_BUILD}/c.log)
    make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${GSL2_BUILD}/m.log)
    make install |& tee >(ts "[%x %X]" > ${GSL2_BUILD}/mi.log)
    cd ${BUILDDIR}
fi