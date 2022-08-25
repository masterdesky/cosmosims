#!/bin/bash


if [[ ${INSTALL_GIZMO} = true ]];
then
  GIZMO_BUILD=${BUILDDIR}/GIZMO
  # Downloading GIZMO
  if [[ ! -d ${GIZMO_BUILD} || ${FORCE} = true ]]; then
    echo
    echo "Downloading GIZMO..."
    echo

    mkdir -p ${BUILDDIR}

    # If previous download exists, delete it first (relevant in case of forced install)
    if [[ -d ${GIZMO_BUILD} ]]; then
      rm -rf ${GIZMO_BUILD}
    fi

    git clone https://bitbucket.org/phopkins/gizmo-public.git ${GIZMO_BUILD}
  fi


  # Installing GIZMO
  echo
  echo "Installing GIZMO..."
  echo

  cd ${GIZMO_BUILD}
  # Uninstall previous version
  if [[ -f ${GIZMO_BUILD}/m.log ]]; then
      make clean |& tee >(ts "[%x %X]" > ${GIZMO_BUILD}/cl.log)
  fi

  #  Makefile and `Config.sh` setup
  ## a) Prepare buildsystem/Makefile.path.${COMPUTER}
  MAKEFILE=${GIZMO_BUILD}/buildsystem/Makefile.path.${COMPUTER}
  cp ${BUILDSYS}/GIZMO/buildsystem/Makefile.path ${MAKEFILE}
  sed -i '/^GSL_INCL/ { s|$| -I'"${GSL2_INSTALL}"'/include|g }' ${MAKEFILE}
  sed -i '/^GSL_LIBS/ { s|$| -L'"${GSL2_INSTALL}"'/lib|g }' ${MAKEFILE}
  sed -i '/^FFTW_INCL/ { s|$| -I'"${FFTW3_INSTALL}"'/include|g }' ${MAKEFILE}
  sed -i '/^FFTW_LIBS/ { s|$| -L'"${FFTW3_INSTALL}"'/lib|g }' ${MAKEFILE}
  sed -i '/^HDF5_INCL/ { s|$| -I'"${HDF5_INSTALL}"'/include|g }' ${MAKEFILE}
  sed -i '/^HDF5_LIBS/ { s|$| -L'"${HDF5_INSTALL}"'/lib -lhdf5 -lz|g }' ${MAKEFILE}
  ## b) Prepare Makefile.systype
  cp ${BUILDSYS}/GIZMO/Makefile.systype ${GIZMO_BUILD}/Makefile.systype
  sed -i '/^SYSTYPE/ { s|${COMPUTER}|'"${COMPUTER}"'| }' ${GIZMO_BUILD}/Makefile.systype
  ## c) Prepare Makefile
  cp ${BUILDSYS}/GIZMO/Makefile ${GIZMO_BUILD}/Makefile
  sed -i 's|${COMPUTER}|'"${COMPUTER}"'|g' ${GIZMO_BUILD}/Makefile
  ## d) Copy Config.sh file
  cp ${BUILDSYS}/GIZMO/Config.sh ${GIZMO_BUILD}/Config.sh
  ## e) Prepare simulation parameters
  if [[ ! -z ${NMESH} ]]; then
    sed -i '/^PMGRID= *#/ { s|PMGRID= |PMGRID='"${NMESH}"' |g }' ${GIZMO_BUILD}/Config.sh
  fi
  
  # Build GIZMO
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${GIZMO_BUILD}/m.log)

  mkdir -p ${GIZMO_BUILD}/Simulations
  cd ${BUILDDIR}
fi