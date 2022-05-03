#!/bin/bash

# Downloading AREPO
if [[ ${DLOAD_AREPO} = true ]]; then
  if [[ ! -d ${BUILDDIR}/AREPO ]]; then
    echo
    echo "Downloading AREPO..."
    echo

    mkdir -p ${BUILDDIR}

    git clone https://gitlab.mpcdf.mpg.de/vrs/arepo.git ${BUILDDIR}/AREPO
  fi
fi


if [[ ${INSTALL_AREPO} = true ]];
then
  echo
  echo "Installing AREPO..."
  echo

  # (Re)installing AREPO
  cd ${BUILDDIR}/AREPO
  if [[ -f ${BUILDDIR}/AREPO/m.log ]]; then
      make clean |& tee >(ts "[%x %X]" > ${BUILDDIR}/AREPO/cl.log)
  fi
fi