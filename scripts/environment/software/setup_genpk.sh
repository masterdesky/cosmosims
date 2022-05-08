#!/bin/bash

# Donwloading GenPK
if [[ ${DLOAD_GENPK} = true ]]; then
  if [[ ! -d ${BUILDDIR}/GenPK ]]; then
    echo
    echo "Downloading GenPK..."
    echo

    mkdir -p ${BUILDDIR}

    git clone https://github.com/sbird/GenPK.git ${BUILDDIR}/GenPK
    cd ${BUILDDIR}/GenPK
    git submodule update --init --recursive
  fi
fi


if [[ ${INSTALL_GENPK} = true ]];
then
  echo
  echo "Installing GenPK..."
  echo

  # (Re)installing GenPK
  cd ${BUILDDIR}/GenPK
  if [[ -f ${BUILDDIR}/GenPK/m.log ]]; then
      make clean |& tee >(ts "[%x %X]" > ${BUILDDIR}/GenPK/cl.log)
  fi
  cd ${BUILDDIR}/GenPK

  # Build GenPK
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${BUILDDIR}/GenPK/m.log)

  cd ${BUILDDIR}
fi