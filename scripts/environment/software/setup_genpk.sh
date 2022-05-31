#!/bin/bash


if [[ ${INSTALL_GENPK} = true ]];
then
  GPK_BUILD=${BUILDDIR}/GenPK
  # Downloading GenPK
  if [[ ! -d ${GPK_BUILD} || ${FORCE} = true ]]; then
    echo
    echo "Downloading GenPK..."
    echo

    # If previous download exists, delete it first (relevant in case of forced install)
    if [[ -d ${GPK_BUILD} ]]; then
      rm -rf ${GPK_BUILD}
    fi

    mkdir -p ${BUILDDIR}

    git clone https://github.com/sbird/GenPK.git ${GPK_BUILD}
    cd ${GPK_BUILD}
    git submodule update --init --recursive
    
    cp ${GPK_BUILD}/Makefile ${GPK_BUILD}/Makefile.bak
    cp ${GPK_BUILD}/GadgetReader/Makefile ${GPK_BUILD}/GadgetReader/Makefile.bak
  fi


  # Installing GenPk
  echo
  echo "Installing GenPK..."
  echo

  cd ${GPK_BUILD}
  # Uninstall previous version
  if [[ -f ${GPK_BUILD}/m.log ]]; then
      make clean |& tee >(ts "[%x %X]" > ${GPK_BUILD}/cl.log)
  fi

  # Installing GadgetReader
  ## Setup Makefile
  MAKEFILE=${GPK_BUILD}/GadgetReader/Makefile
  cp ${MAKEFILE}.bak ${MAKEFILE}
  sed -i 's|\${CURDIR}|'"${GPK_BUILD}/GadgetReader"'|g' ${MAKEFILE}
  sed -i 's|\$(CURDIR)|'"${GPK_BUILD}/GadgetReader"'|g' ${MAKEFILE}
  sed -i '/^HDF_INC/ { s|=.*|= -I'"${HDF5_INSTALL}"'/include| }' ${MAKEFILE}
  sed -i '/HDF_LINK = -lhdf5 -lhdf5_hl/ { s|=|= -L'"${HDF5_INSTALL}"'/lib| }' ${MAKEFILE}
  ## Build GadgetReader
  cd ${GPK_BUILD}/GadgetReader
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${GPK_BUILD}/m.log)


  # Installing GenPK
  ## Setup Makefile
  MAKEFILE=${GPK_BUILD}/Makefile
  cp ${MAKEFILE}.bak ${MAKEFILE}
  sed -i '/^GREAD/ { s|=.*|='"${GPK_BUILD}"'/GadgetReader| }' ${MAKEFILE}
  NEW_LFLAGS='-L${FFTW3_INSTALL}/lib -L${HDF5_INSTALL}/lib'
  sed -i '/^LFLAGS/ { s|-L${GREAD}|-L${GREAD} '"${NEW_LFLAGS}"'| }' ${MAKEFILE}
  ## Gadget is always compiled with double precision
  sed -i '/^#OPT/ { s|#OPT|OPT| }' ${MAKEFILE}
  ## Build GenPK
  cd ${GPK_BUILD}
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${GPK_BUILD}/m.log)

  cd ${BUILDDIR}
fi