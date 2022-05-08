#!/bin/bash

# Downloading and unpacking GADGETViewer ${GV_VER}
if [[ ${DLOAD_GV} = true ]]; then
  if [[ ! -d ${BUILDDIR}/GADGETViewer-${GV_VER} ]]; then
    echo
    echo "Downloading GADGETViewer..."
    echo

    mkdir -p ${BUILDDIR}

    wget "https://github.com/jchelly/gadgetviewer/releases/download/${GV_VER}/gadgetviewer-${GV_VER}.tar.gz" -P ${BUILDDIR}
    tar -xzvf ${BUILDDIR}/gadgetviewer-${GV_VER}.tar.gz -C ${BUILDDIR}
    rm -f ${BUILDDIR}/gadgetviewer-${GV_VER}.tar.gz
    mv ${BUILDDIR}/gadgetviewer-${GV_VER} ${BUILDDIR}/GADGETViewer-${GV_VER}
  fi
fi


if [[ ${INSTALL_GV} = true ]];
then
    echo
    echo "Installing GADGETViewer ${GV_VER}..."
    echo

    # (Re)install GADGETViewer ${GV_VER}
    cd ${BUILDDIR}/GADGETViewer-${GV_VER}
    if [[ -f ${BUILDDIR}/GADGETViewer-${GV_VER}/mi.log ]]; then
        make uninstall |& tee >(ts "[%x %X]" > ${BUILDDIR}/GADGETViewer-${GV_VER}/mu.log)
        make clean |& tee >(ts "[%x %X]" > ${BUILDDIR}/GADGETViewer-${GV_VER}/cl.log)
    fi
    ./configure --prefix=${INSTALLDIR}/GADGETViewer-${GV_VER} \
                CFLAGS='-g -O3 -Wall -std=c17' \
                CXXFLAGS='-g -O3 -Wall -std=c++17 ' \
                FFLAGS='-fallow-argument-mismatch' \
                FCFLAGS='-fallow-argument-mismatch' \
                |& tee >(ts "[%x %X]" > ${BUILDDIR}/GADGETViewer-${GV_VER}/c.log)
    make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${BUILDDIR}/GADGETViewer-${GV_VER}/m.log)
    make install |& tee >(ts "[%x %X]" > ${BUILDDIR}/GADGETViewer-${GV_VER}/mi.log)
    cd ${BUILDDIR}
fi
