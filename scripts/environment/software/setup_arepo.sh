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

  #  Makefile and `Config.sh` setup
  cp ${BUILDSYS}/AREPO/Makefile ${AREPO_BUILD}/Makefile
  cp ${BUILDSYS}/AREPO/Makefile.systype ${AREPO_BUILD}/Makefile.systype
  cp ${BUILDSYS}/AREPO/Config.sh ${AREPO_BUILD}/Config.sh

  # Build AREPO
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${AREPO_BUILD}/m.log)

  cd ${BUILDDIR}

fi