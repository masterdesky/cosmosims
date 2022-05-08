#!/bin/bash

# Downloading CosmoGRaPH
if [[ ${DLOAD_CGRAPH} = true ]]; then
  if [[ ! -d ${BUILDDIR}/CosmoGRaPH ]]; then
    echo
    echo "Downloading CosmoGRaPH..."
    echo

    mkdir -p ${BUILDDIR}

    git clone --recursive https://github.com/cwru-pat/GR_AMR.git ${BUILDDIR}/CosmoGRaPH
    # Not accessible anymore for the original CosmoGRaPH @ github.com/cwru-pat/cosmograph
    #cd ${BUILDDIR}/CosmoGRaPH
    #git submodule update --init --recursive
  fi
fi


if [[ ${INSTALL_CGRAPH} = true ]];
then
  echo
  echo "Installing CosmoGRaPH..."
  echo

  # (Re)installing CosmoGRaPH
  cd ${BUILDDIR}/CosmoGRaPH
  if [[ -f ${BUILDDIR}/CosmoGRaPH/m.log ]]; then
    make clean |& tee >(ts "[%x %X]" > ${BUILDDIR}/CosmoGRaPH/cl.log)
    rm -r ${BUILDDIR}/CosmoGRaPH/build ${BUILDDIR}/CosmoGRaPH/obj
  fi
  
  # Install SAMRAI (dependency)
  echo
  echo
  echo "Starting SAMRAI install..."
  echo
  mkdir -p ${BUILDDIR}/CosmoGRaPH/obj
  cd ${BUILDDIR}/CosmoGRaPH/obj

  SAM_LOG=${BUILDDIR}/CosmoGRaPH/obj/sm.log
  sh ${BUILDDIR}/CosmoGRaPH/SAMRAI/configure \
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
  mkdir -p mkdir -p ${BUILDDIR}/CosmoGRaPH/build
  cd ${BUILDDIR}/CosmoGRaPH/build

  # Parts of the CMake files needs to be changed
  cp -v ${ENVDIR}/build/CosmoGRaPH/cmake/fftw.cmake ${BUILDDIR}/CosmoGRaPH/cmake
  cp -v ${ENVDIR}/build/CosmoGRaPH/cmake/hdf5.cmake ${BUILDDIR}/CosmoGRaPH/cmake
  
  # Set compile-time parameters via CMake
  cmake ..

  # Build CosmoGRaPH
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${BUILDDIR}/CosmoGRaPH/m.log)

  cd ${BUILDDIR}
fi