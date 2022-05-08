#!/bin/bash


# Downloading and unpacking GSL 1.X if necessary
if [[ ${DLOAD_GSL1} = true ]]; then
  if [[ ! -d ${GSL1_BUILD} ]]; then
    echo
    echo "Downloading GSL ${GSL1_VERS}..."
    echo

    mkdir -p ${BUILDDIR}

    # Download GSL 1.X
    wget "https://quantum-mirror.hu/mirrors/pub/gnu/gsl/gsl-${GSL1_VERS}.tar.gz" -P ${BUILDDIR}
    tar -xzvf ${BUILDDIR}/gsl-${GSL1_VERS}.tar.gz -C ${BUILDDIR}
    rm -f ${BUILDDIR}/gsl-${GSL1_VERS}.tar.gz
  fi
fi


if [[ ${INSTALL_GSL1} = true ]];
then
    echo
    echo "Installing GSL ${GSL1_VERS}..."
    echo

    mkdir -p ${INSTALLDIR}

    # (Re)install GSL 1.X
    cd ${GSL1_BUILD}
    if [ -f ${GSL1_BUILD}/mi.log ]; then
        make uninstall |& tee >(ts "[%x %X]" > ${GSL1_BUILD}/mu.log)
        make clean |& tee >(ts "[%x %X]" > ${GSL1_BUILD}/cl.log)
    fi
    ./configure --prefix=${GSL1_INSTALL} |& tee >(ts "[%x %X]" > ${GSL1_BUILD}/c.log)
    make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${GSL1_BUILD}/m.log)
    make install |& tee >(ts "[%x %X]" > ${GSL1_BUILD}/mi.log)
    cd ${BUILDDIR}
fi