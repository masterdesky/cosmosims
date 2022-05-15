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
  ## Add FLRWSolver thorn to the default thornlist of the EinsteinToolkit's
  ## Cactus configuration
  ##
  ## This is done by adding it to the `manifest/einsteinttolkit.th` file, to
  ## the corresponding `EinsteinInitialData` section
  THORNPATH=EinsteinToolkit/Cactus/thornlists
  cp ${BUILDSYS}/${THORNPATH}/einsteintoolkit.th \
     ${BUILDDIR}/${THORNPATH}/
  sed -i '/^EinsteinInitialData\/Exact/ { s|$|\nEinsteinInitialData\/flrwsolver|  }' \
      ${BUILDDIR}/${THORNPATH}/einsteintoolkit.th

  ## Setup conda env for ET + FLRWSolver
  if ! { conda env list | grep 'et-flrw'; } >/dev/null 2>&1; then
      conda create --name et-flrw python=3.8 python-configuration cffi numpy scipy -y
  fi

  ## Setup Python 3.x linking for the FLRWSolver codes
  ### `conda.sh` should be sourced first if `conda` is ran from a bash script
  source ${CONDAROOT}/etc/profile.d/conda.sh
  conda activate et-flrw
  ### Get compile parameters
  PCFLAGS="$(python3-config --cflags)"
  PLDFLAGS="$(python3-config --ldflags)"
  ### Write these compile parameters to the appropriate files
  CFLAGSPATH=EinsteinToolkit/Cactus/repos/flrwsolver/src/make.code.deps
  LDFLAGSPATH=EinsteinToolkit/Cactus/simfactory/mdb/optionlists/generic.cfg
  cp ${BUILDSYS}/${CFLAGSPATH} ${BUILDDIR}/${CFLAGSPATH}
  cp ${BUILDSYS}/${LDFLAGSPATH} ${BUILDDIR}/${LDFLAGSPATH}
  sed -i '/^CFLAGS/ { s|$|'"${PCFLAGS}"'| }' ${BUILDDIR}/${CFLAGSPATH}  # Exactly 0 space needed
  #sed -i '/^CFLAGS/ { s|$| '"${PCFLAGS}"'| }' ${BUILDDIR}/${LDFLAGSPATH}  # Exactly 1 space needed
  sed -i '/^LDFLAGS/ { s|$| '"${PLDFLAGS}"'| }' ${BUILDDIR}/${LDFLAGSPATH}  # Exactly 1 space needed

  ## Set path to FLRWSolver in `FLRWSolver/src/builder.py`
  flrwsolverpath=${BUILDDIR}/EinsteinToolkit/Cactus/repos/flrwsolver
  sed -i '/^flrwsolverpath/ { s|=.*|="'"${flrwsolverpath}"'"| }' ${flrwsolverpath}/src/builder.py

  ## Generate the static library linking
  cd ${flrwsolverpath}/src
  python3 ${flrwsolverpath}/src/builder.py

  ## Setup simfactory if it's ran for the first time
  cd ${BUILDDIR}/EinsteinToolkit/Cactus
  if [[ ! -f ${BUILDDIR}/EinsteinToolkit/Cactus/simfactory/etc/defs.local.ini ]]; then
    ${BUILDDIR}/EinsteinToolkit/Cactus/simfactory/bin/sim setup
  fi

  ## Setup 

  ## Build Cactus + FLRWSolver
  #${BUILDDIR}/EinsteinToolkit/Cactus/simfactory/bin/sim build \
  #        --clean \
  #        --thornlist=thornlists/einsteintoolkit.th \
  #        --optionlist=generic.cfg \
  #        --cores=8

  conda deactivate
  cd ${BUILDDIR}
fi