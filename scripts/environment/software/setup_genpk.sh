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
  cd ${GPK_BUILD}

  # Build GenPK
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${GPK_BUILD}/m.log)

  cd ${BUILDDIR}
fi