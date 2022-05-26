#!/bin/bash


if [[ ${INSTALL_CGRAPH} = true ]];
then
  CGR_BUILD=${BUILDDIR}/CosmoGRaPH
  # Downloading CosmoGRaPH
  if [[ ! -d ${CGR_BUILD} || ${FORCE} = true ]]; then
    echo
    echo "Downloading CosmoGRaPH..."
    echo

    # If previous download exists, delete it first (relevant in case of forced install)
    if [[ -d ${CGR_BUILD} ]]; then
      rm -rf ${CGR_BUILD}
    fi

    mkdir -p ${BUILDDIR}

    git clone --recursive https://github.com/cwru-pat/GR_AMR.git ${CGR_BUILD}
    # Not accessible anymore for the original CosmoGRaPH @ github.com/cwru-pat/cosmograph
    #cd ${CGR_BUILD}
    #git submodule update --init --recursive
  fi


  # Installing CosmoGRaPH
  echo
  echo "Installing CosmoGRaPH..."
  echo

  cd ${CGR_BUILD}
  # Uninstall previous version
  if [[ -f ${CGR_BUILD}/m.log ]]; then
    make clean |& tee >(ts "[%x %X]" > ${CGR_BUILD}/cl.log)
    rm -r ${CGR_BUILD}/build ${CGR_BUILD}/obj
  fi
  
  # Install SAMRAI (dependency)
  echo
  echo
  echo "Starting SAMRAI install..."
  echo
  mkdir -p ${CGR_BUILD}/obj
  cd ${CGR_BUILD}/obj

  SAM_LOG=${CGR_BUILD}/obj/sm.log
  sh ${CGR_BUILD}/SAMRAI/configure \
      --with-F77=gfortran \
      --with-hdf5=${HDF5_INSTALL} \
      CXXFLAGS="-std=c++11" \
      LDFLAGS=-L${FFTW3_INSTALL}/lib CFLAGS=-I${FFTW3_INSTALL}/include \
  |& tee >(ts "[%x %X]" > ${SAM_LOG})
  make library -j${N_CPUS} |& tee >(ts "[%x %X]" >> ${SAM_LOG})
  make tools   -j${N_CPUS} |& tee >(ts "[%x %X]" >> ${SAM_LOG})
  make install -j${N_CPUS} |& tee >(ts "[%x %X]" >> ${SAM_LOG})


  # Install CosmoGRaPH
  echo
  echo
  echo "Starting CosmoGRaPH install..."
  echo
  mkdir -p mkdir -p ${CGR_BUILD}/build
  cd ${CGR_BUILD}/build

  # Parts of the CMake files needs to be changed
  cp -v ${ENVDIR}/build/CosmoGRaPH/cmake/fftw.cmake ${CGR_BUILD}/cmake
  cp -v ${ENVDIR}/build/CosmoGRaPH/cmake/hdf5.cmake ${CGR_BUILD}/cmake
  
  # Set compile-time parameters via CMake
  cmake ..

  # Build CosmoGRaPH
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${CGR_BUILD}/m.log)

  cd ${BUILDDIR}
fi