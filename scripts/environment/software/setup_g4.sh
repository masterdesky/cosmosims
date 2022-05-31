#!/bin/bash


if [[ ${INSTALL_G4} = true ]];
then
  G4_BUILD=${BUILDDIR}/GADGET4
  # Downloading GADGET4
  if [[ ! -d ${G4_BUILD} || ${FORCE} = true ]]; then
    echo
    echo "Downloading GADGET4..."
    echo

    mkdir -p ${BUILDDIR}

    # If previous download exists, delete it first (relevant in case of forced install)
    if [[ -d ${G4_BUILD} ]]; then
      rm -rf ${G4_BUILD}
    fi

    git clone http://gitlab.mpcdf.mpg.de/vrs/gadget4 ${G4_BUILD}
  fi


  # Installing GADGET4
  echo
  echo "Installing GADGET4..."
  echo

  cd ${G4_BUILD}
  # Uninstall previous version
  if [[ -f ${G4_BUILD}/m.log ]]; then
      make clean |& tee >(ts "[%x %X]" > ${G4_BUILD}/cl.log)
  fi

  #  Makefile and `Config.sh` setup
  ## a) Prepare buildsystem/Makefile.path.${COMPUTER}
  MAKEFILE=${G4_BUILD}/buildsystem/Makefile.path.${COMPUTER}
  cp ${BUILDSYS}/GADGET4/buildsystem/Makefile.path ${MAKEFILE}
  sed -i '/^GSL_INCL/ { s|$| -I'"${GSL2_INSTALL}"'/include|g }' ${MAKEFILE}
  sed -i '/^GSL_LIBS/ { s|$| -L'"${GSL2_INSTALL}"'/lib|g }' ${MAKEFILE}
  sed -i '/^FFTW_INCL/ { s|$| -I'"${FFTW3_INSTALL}"'/include|g }' ${MAKEFILE}
  sed -i '/^FFTW_LIBS/ { s|$| -L'"${FFTW3_INSTALL}"'/lib|g }' ${MAKEFILE}
  sed -i '/^HDF5_INCL/ { s|$| -I'"${HDF5_INSTALL}"'/include|g }' ${MAKEFILE}
  sed -i '/^HDF5_LIBS/ { s|$| -L'"${HDF5_INSTALL}"'/lib -lhdf5 -lz|g }' ${MAKEFILE}
  sed -i '/^HWLOC_INCL/ { s|$| -I'"${HWLOC_INSTALL}"'/include|g }' ${MAKEFILE}
  sed -i '/^HWLOC_LIBS/ { s|$| -L'"${HWLOC_INSTALL}"'/lib|g }' ${MAKEFILE}
  ## b) Prepare Makefile.systype
  cp ${BUILDSYS}/GADGET4/Makefile.systype ${G4_BUILD}/Makefile.systype
  sed -i '/^SYSTYPE/ { s|${COMPUTER}|'"${COMPUTER}"'| }' ${G4_BUILD}/Makefile.systype
  ## c) Prepare Makefile
  cp ${BUILDSYS}/GADGET4/Makefile ${G4_BUILD}/Makefile
  sed -i 's|${COMPUTER}|'"${COMPUTER}"'|g' ${G4_BUILD}/Makefile
  ## d) Copy Config.sh file
  cp ${BUILDSYS}/GADGET4/Config.sh ${G4_BUILD}/Config.sh
  ## e) Prepare simulation parameters
  if [[ ! -z ${NMESH} ]]; then
    sed -i '/^PMGRID= *#/ { s|PMGRID= |PMGRID='"${NMESH}"' |g }' ${G4_BUILD}/Config.sh
  fi
  
  # Build GADGET4
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${G4_BUILD}/m.log)

  mkdir -p ${G4_BUILD}/Simulations
  cd ${BUILDDIR}
fi