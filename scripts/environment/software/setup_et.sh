#!/bin/bash


if [[ ${INSTALL_ET} = true ]];
then
  ET_BUILD=${BUILDDIR}/EinsteinToolkit
  # Downloading EinsteinToolkit
  if [[ ! -d ${ET_BUILD} || ${FORCE} = true ]]; then
    echo
    echo "Downloading EinsteinToolkit with FLRWSolver..."
    echo

    # If previous download exists, delete it first (relevant in case of forced install)
    if [[ -d ${ET_BUILD} ]]; then
      rm -rf ${ET_BUILD}
    fi

    mkdir -p ${ET_BUILD}

    # Download the EinsteinToolkit
    cd ${ET_BUILD}
    curl -kLO https://raw.githubusercontent.com/gridaphobe/CRL/ET_2021_11/GetComponents
    chmod a+x GetComponents
    ./GetComponents --parallel https://bitbucket.org/einsteintoolkit/manifest/raw/ET_2021_11/einsteintoolkit.th

    # Download the FLRWsolver
    cd ${ET_BUILD}/Cactus/repos
    git clone https://github.com/hayleyjm/FLRWSolver_public.git flrwsolver
    cd ${ET_BUILD}/Cactus/arrangements/EinsteinInitialData
    ln -s ../../repos/flrwsolver flrwsolver

    cd ${BUILDDIR}
  fi
  

  # Installing EinsteinToolkit
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
    conda create --name et-flrw python=3.8 python-configuration cffi numpy scipy h5py -y
  fi

  ## Setup Python 3.x linking for the FLRWSolver codes
  ### `conda.sh` should be sourced first if `conda` is ran from a bash script
  source ${CONDAROOT}/etc/profile.d/conda.sh
  conda activate et-flrw
  ### Get compile parameters
  PCFLAGS="$(python3-config --cflags --embed)"
  PLDFLAGS="$(python3-config --ldflags --embed) -lgfortran"
  LIBFLAGS="$(python3-config --libs --embed) -lgfortran"
  ### Write these compile parameters to the appropriate files
  CFLAGSPATH=EinsteinToolkit/Cactus/repos/flrwsolver/src/make.code.deps
  LDFLAGSPATH=EinsteinToolkit/Cactus/simfactory/mdb/optionlists/generic.cfg
  cp ${BUILDSYS}/${CFLAGSPATH} ${BUILDDIR}/${CFLAGSPATH}
  cp ${BUILDSYS}/${LDFLAGSPATH} ${BUILDDIR}/${LDFLAGSPATH}
  sed -i '/^CFLAGS/ { s|$|'"${PCFLAGS}"'| }' ${BUILDDIR}/${CFLAGSPATH}  # Exactly 0 space needed
  sed -i '/^LDFLAGS/ { s|$| '"${PLDFLAGS}"'| }' ${BUILDDIR}/${LDFLAGSPATH}  # Exactly 1 space needed
  sed -i '/^LDFLAGS/ { s|$|\nLIBS = '"${LIBFLAGS}"'| }' ${BUILDDIR}/${LDFLAGSPATH}

  ## Set path to FLRWSolver in `FLRWSolver/src/builder.py`
  FLRWSOLVERPATH=${ET_BUILD}/Cactus/repos/flrwsolver
  sed -i '/^FLRWSOLVERPATH/ { s|=.*|="'"${FLRWSOLVERPATH}\/"'"| }' ${FLRWSOLVERPATH}/src/builder.py

  ## Generate the static library linking
  cd ${FLRWSOLVERPATH}/src
  python3 ${FLRWSOLVERPATH}/src/builder.py

  ## Setup simfactory if it's ran for the first time
  cd ${ET_BUILD}/Cactus
  if [[ ! -f ${ET_BUILD}/Cactus/simfactory/etc/defs.local.ini ]]; then
    ${ET_BUILD}/Cactus/simfactory/bin/sim setup \
    |& tee >(ts "[%x %X]" > ${ET_BUILD}/setup.log)
  fi

  ## Change configuration for the current machine generated by the simfactory setup
  MACHINENAME=$(hostname).$(hostname -d)
  MCONFIG=${ET_BUILD}/Cactus/simfactory/mdb/machines/${MACHINENAME}.ini
  sed -i '/^basedir/ { s|=.*|= '"${DATADIR}"'\/EinsteinToolkit\/simulations| }' ${MCONFIG}
  sed -i '/^nodes/ { s|=.*|= 1| }' ${MCONFIG}
  sed -i '/^ppn/ { s|=.*|= '"${N_CPUS}"'| }' ${MCONFIG}
  sed -i '/^max-num-threads/ { s|=.*|= '"${N_CPUS}"'| }' ${MCONFIG}
  sed -i '/^num-threads/ { s|=.*|= '"${N_CPUS}"'| }' ${MCONFIG}

  ## Build Cactus + FLRWSolver
  ${ET_BUILD}/Cactus/simfactory/bin/sim build \
          --thornlist=thornlists/einsteintoolkit.th \
          --optionlist=generic.cfg \
          --cores=${N_CPUS} \
    |& tee >(ts "[%x %X]" > ${ET_BUILD}/m.log)
#          --clean \
  
  conda deactivate
  cd ${BUILDDIR}
fi