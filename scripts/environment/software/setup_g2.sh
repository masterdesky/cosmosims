#!/bin/bash


if [[ ${INSTALL_G2} = true ]];
then
  G2_BUILD=${BUILDDIR}/GADGET2
  # Downloading GADGET2
  if [[ ! -d ${G2_BUILD} || ${FORCE} = true ]]; then
    echo
    echo "Downloading GADGET2..."
    echo

    mkdir -p ${BUILDDIR}

    # If previous download exists, delete it first (relevant in case of forced install)
    if [[ -d ${G2_BUILD} ]]; then
      rm -rf ${G2_BUILD}
    fi

    # Download GADGET2
    wget "https://wwwmpa.mpa-garching.mpg.de/gadget/gadget-2.0.7.tar.gz" -P ${BUILDDIR}
    tar -xzvf ${BUILDDIR}/gadget-2.0.7.tar.gz -C ${BUILDDIR}
    rm -f ${BUILDDIR}/gadget-2.0.7.tar.gz
    mv ${BUILDDIR}/Gadget-2.0.7 ${G2_BUILD}
  fi


  # Installing GADGET2
  echo
  echo "Installing GADGET2..."
  echo

  cd ${G2_BUILD}/Gadget2
  # Uninstall previous version
  if [[ -f ${G2_BUILD}/Gadget2/m.log ]]; then
      make clean |& tee >(ts "[%x %X]" > ${G2_BUILD}/Gadget2/cl.log)
  fi

  #  1. Makefile setup
  ## a) Path to dependencies
  MAKEFILE=${G2_BUILD}/Gadget2/Makefile
  cp ${BUILDSYS}/GADGET2/Makefile ${MAKEFILE}
  sed -i '/^GSL_INCL/ { s|$| -I'"${GSL1_INSTALL}"'/include| }' ${MAKEFILE}
  sed -i '/^GSL_LIBS/ { s|$| -L'"${GSL1_INSTALL}"'/lib| }' ${MAKEFILE}
  sed -i '/^FFTW_INCL/ { s|$| -I'"${FFTW2_INSTALL}"'/include| }' ${MAKEFILE}
  sed -i '/^FFTW_LIBS/ { s|$| -L'"${FFTW2_INSTALL}"'/lib| }' ${MAKEFILE}
  sed -i '/^HDF5INCL/ { s|$| -I'"${HDF5_INSTALL}"'/include| }' ${MAKEFILE}
  sed -i '/^HDF5LIB/ { s|$| -L'"${HDF5_INSTALL}"'/lib -lhdf5 -lz| }' ${MAKEFILE}
  ## b) The computer variable
  sed -i 's|${COMPUTER}|'"${COMPUTER}"'|g' ${MAKEFILE}
  ## c) Simulation parameters
  if [[ ! -z ${NMESH} ]]; then
    sed -i 's/-DPMGRID=/-DPMGRID='"${NMESH}"'/g' ${MAKEFILE}
  else
    echo "[GADGET2 ERROR]: `NMESH` variable is undefined!"
    exit 2
  fi
  if [[ ! -z ${NPART} ]]; then
    sed -i 's/-DMAKEGLASS=/-DMAKEGLASS='"${NPART}"'/g' ${MAKEFILE}
  else
    echo "[GADGET2 ERROR]: `NPART` variable is undefined!"
    exit 2
  fi
  ## d) Select between built-in glass generation or reading IC file
  sed -i '/-DREAD_IC/ { s|^#|| }' ${MAKEFILE}
  if [[ ${G2} = true ]]; then
    sed -i '/-DREAD_IC/ { s|^|#| }' ${MAKEFILE}
  fi

  #  2. Source code changes to implement IC reading before glass generation
  OLD_STR='#if \(MAKEGLASS > 1\)\n      seed_glass\(\);'
  NEW_STR='#if \(MAKEGLASS > 1\)\n#ifdef READ_IC\n      read_ic\(All.InitCondFile\);\n#else\n      seed_glass\(\);\n#endif'
  perl -i -p0e 's/'"${OLD_STR}"'/'"${NEW_STR}"'/igs' ${G2_BUILD}/Gadget2/init.c

  # Build GADGET2
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${G2_BUILD}/Gadget2/m.log)

  cd ${BUILDDIR}
fi