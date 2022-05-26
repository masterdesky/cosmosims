#!/bin/bash


if [[ ${INSTALL_GENPK} = true ]];
then
  GPK_BUILD=${BUILDDIR}/GenPK
  # Downloading GenPK
  if [[ ! -d ${CPK_BUILD} || ${FORCE} = true ]]; then
    echo
    echo "Downloading GenPK..."
    echo

    mkdir -p ${BUILDDIR}

    git clone https://github.com/sbird/GenPK.git ${CPK_BUILD}
    cd ${CPK_BUILD}
    git submodule update --init --recursive
  fi


  # Installing GenPk
  echo
  echo "Installing GenPK..."
  echo

  cd ${CPK_BUILD}
  # Uninstall previous version
  if [[ -f ${CPK_BUILD}/m.log ]]; then
      make clean |& tee >(ts "[%x %X]" > ${CPK_BUILD}/cl.log)
  fi
  cd ${CPK_BUILD}

  # Build GenPK
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${CPK_BUILD}/m.log)

  cd ${BUILDDIR}
fi