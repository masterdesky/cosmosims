#!/bin/bash

# Downloading StePS
if [[ ${DLOAD_ET} = true ]]; then
  if [[ ! -d ${BUILDDIR}/EinsteinToolkit ]]; then
    echo
    echo "Downloading EinsteinToolkit with FLRWSolver..."
    echo

    mkdir -p ${BUILDDIR}/EinsteinToolkit

    # Download the EinsteinToolkit
    cd ${BUILDDIR}/EinsteinToolkit
    curl -kLO https://raw.githubusercontent.com/gridaphobe/CRL/ET_2021_11/GetComponents
    chmod a+x GetComponents
    ./GetComponents --parallel https://bitbucket.org/einsteintoolkit/manifest/raw/ET_2021_11/einsteintoolkit.th

    # Download the FLRWsolver
    cd ${BUILDDIR}/EinsteinToolkit/Cactus/repos
    git clone https://github.com/hayleyjm/FLRWSolver_public.git flrwsolver
    cd ${BUILDDIR}/EinsteinToolkit/Cactus/arrangements/EinsteinInitialData
    ln -s ../../repos/flrwsolver flrwsolver

    cd ${BUILDDIR}
  fi
fi


if [[ ${INSTALL_ET} = true ]];
then
  echo
  echo "Installing EinsteinToolkit with FLRWSolver..."
  echo

    # (Re)installing EinsteinToolkit with FLRWSolver
    ## Setup conda env for ET + FLRWSolver
    if ! { conda env list | grep 'et-flrw'; } >/dev/null 2>&1; then
        conda create --name et-flrw python python-configuration cffi numpy scipy -y
    fi
    conda activate et-flrw
    ## Setup Python linking
    PCFLAGS="$(python-config --cflags)"
    PLDFLAGS="$(python-config --ldflags)"

    conda deactivate
    ## Add `#include <cstring>` to `inputoutput.cc`
    #sed -i '/^#include <stdlib.h>/ { s|$| \n#include <cstring>| }' ${BUILDDIR}/StePS/StePS/src/inputoutput.cc
    #make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${BUILDDIR}/StePS/StePS/src/m.log)

    cd ${BUILDDIR}
fi