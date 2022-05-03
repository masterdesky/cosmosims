#!/bin/bash


# Downloading LATfield2
if [[ ${DLOAD_LAT2} = true ]]; then
  if [[ ! -d ${LAT2_BUILD} ]]; then
    echo
    echo "Downloading LATfield2..."
    echo

    # Download GSL 1.X
    git clone https://github.com/daverio/LATfield2.git ${BUILDDIR}/LATfield2
  fi
fi


# Installing LATfield2
if [[ ${INSTALL_LAT2} = true ]];
then
    echo
    echo "Installing GSL LATfield2..."
    echo

    mkdir -p ${INSTALLDIR}/LATfield2/include

    # (Re)install GSL 1.X
    cp ${LAT2_BUILD}/*.h* ${INSTALLDIR}/LATfield2/include
    cp -r ${LAT2_BUILD}/particles ${INSTALLDIR}/LATfield2/include
    cd ${BUILDDIR}
fi