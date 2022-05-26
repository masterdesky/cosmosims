#!/bin/bash


if [[ ${INSTALL_GV} = true ]];
then
  GV_BUILD=${BUILDDIR}/GADGETViewer-${GV_VER}
  # Downloading GADGETViewer
  if [[ ! -d ${GV_BUILD} || ${FORCE} = true ]]; then
    echo
    echo "Downloading GADGETViewer..."
    echo

    # If previous download exists, delete it first (relevant in case of forced install)
    if [[ -d ${GV_BUILD} ]]; then
      rm -rf ${GV_BUILD}
    fi

    mkdir -p ${BUILDDIR}

    # Development version
    git clone https://github.com/jchelly/gadgetviewer ${GV_BUILD}
    
    # Release version
    #wget "https://github.com/jchelly/gadgetviewer/releases/download/${GV_VER}/gadgetviewer-${GV_VER}.tar.gz" -P ${BUILDDIR}
    #tar -xzvf ${GV_BUILD}.tar.gz -C ${BUILDDIR}
    #rm -f ${GV_BUILD}.tar.gz
    #mv ${GV_BUILD} ${GV_BUILD}
  fi


  # Installing GADGETViewer  
  echo
  echo "Installing GADGETViewer ${GV_VER}..."
  echo

  cd ${GV_BUILD}
  # Uninstall previous version
  if [[ -f ${GV_BUILD}/mi.log ]]; then
    make uninstall |& tee >(ts "[%x %X]" > ${GV_BUILD}/mu.log)
    make clean |& tee >(ts "[%x %X]" > ${GV_BUILD}/cl.log)
  fi

  # Install GADGETViewer
  # Devel versions requires the configure script to be generated first
  if [[ ! -f ${GV_BUILD}/configure ]]; then
    source ${GV_BUILD}/autogen.sh
  fi
  ./configure --prefix=${INSTALLDIR}/GADGETViewer-${GV_VER} \
              CFLAGS='-g -O3 -Wall -std=c17' \
              FCFLAGS='-fallow-argument-mismatch' \
              |& tee >(ts "[%x %X]" > ${GV_BUILD}/c.log)
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${GV_BUILD}/m.log)
  make install |& tee >(ts "[%x %X]" > ${GV_BUILD}/mi.log)
  cd ${BUILDDIR}
fi
