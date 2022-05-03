#!/bin/bash

# Downloading GADGET4
if [[ ${DLOAD_G4} = true ]]; then
  if [[ ! -d ${BUILDDIR}/GADGET4 ]]; then
    echo
    echo "Downloading GADGET4..."
    echo

    mkdir -p ${BUILDDIR}

    git clone http://gitlab.mpcdf.mpg.de/vrs/gadget4 ${BUILDDIR}/GADGET4
  fi
fi


if [[ ${INSTALL_G4} = true ]];
then
  echo
  echo "Installing GADGET4..."
  echo

  # (Re)installing GADGET4
  cd ${BUILDDIR}/GADGET4
  if [[ -f ${BUILDDIR}/GADGET4/m.log ]]; then
      make clean |& tee >(ts "[%x %X]" > ${BUILDDIR}/GADGET4/cl.log)
  fi
  MAKEFILE=${BUILDDIR}/GADGET4/buildsystem/Makefile.path.${COMPUTER}

  ## Prepare buildsystem/Makefile.path.${COMPUTER}
  cp ${BUILDSYS}/GADGET4/buildsystem/Makefile.path ${MAKEFILE}
  sed -i '/^GSL_INCL/ { s|$| -I'"${GSL2_INSTALL}"'/include|g }' ${MAKEFILE}
  sed -i '/^GSL_LIBS/ { s|$| -L'"${GSL2_INSTALL}"'/lib|g }' ${MAKEFILE}
  sed -i '/^FFTW_INCL/ { s|$| -I'"${FFTW3_INSTALL}"'/include|g }' ${MAKEFILE}
  sed -i '/^FFTW_LIBS/ { s|$| -L'"${FFTW3_INSTALL}"'/lib|g }' ${MAKEFILE}
  sed -i '/^HDF5_INCL/ { s|$| -I'"${HDF5_INSTALL}"'/include|g }' ${MAKEFILE}
  sed -i '/^HDF5_LIBS/ { s|$| -L'"${HDF5_INSTALL}"'/lib -lhdf5 -lz|g }' ${MAKEFILE}
  sed -i '/^HWLOC_INCL/ { s|$| -I'"${HWLOC_INSTALL}"'/include|g }' ${MAKEFILE}
  sed -i '/^HWLOC_LIBS/ { s|$| -L'"${HWLOC_INSTALL}"'/lib|g }' ${MAKEFILE}
  ## Prepare Makefile.systype
  cp ${BUILDSYS}/GADGET4/Makefile.systype ${BUILDDIR}/GADGET4/Makefile.systype
  sed -i '/^SYSTYPE/ { s|${COMPUTER}|'"${COMPUTER}"'| }' ${BUILDDIR}/GADGET4/Makefile.systype
  ## Prepare Makefile
  cp ${BUILDSYS}/GADGET4/Makefile ${BUILDDIR}/GADGET4/Makefile
  sed -i 's|${COMPUTER}|'"${COMPUTER}"'|g' ${BUILDDIR}/GADGET4/Makefile
  ## Copy Config.sh file
  cp ${BUILDSYS}/GADGET4/Config.sh ${BUILDDIR}/GADGET4/Config.sh
  ## Prepare simulation parameters
  if [[ ! -z ${NMESH} ]]; then
    sed -i '/^PMGRID= *#/ { s|PMGRID= |PMGRID='"${NMESH}"' |g }' ${BUILDDIR}/GADGET4/Config.sh
  fi
  
  # Build GADGET4
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${BUILDDIR}/GADGET4/m.log)

  mkdir -p ${BUILDDIR}/GADGET4/Simulations
  cd ${BUILDDIR}
fi