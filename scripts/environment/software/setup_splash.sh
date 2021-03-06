#!/bin/bash


if [[ ${INSTALL_SP} = true ]]; then
  SP_BUILD=${BUILDDIR}/SPLASH
  sed -i '/^export SPLASH/ { s|=.*|='"${SP_BUILD}"'| }' ${SCRIPTDIR}/setup_env.sh
  sed -i '/^export GIZA/ { s|=.*|='"${SP_BUILD}"'/giza| }' ${SCRIPTDIR}/setup_env.sh
  # Downloading SPLASH
  if [[ ! -d ${SP_BUILD} || ${FORCE} = true ]]; then
    echo
    echo "Downloading SPLASH..."
    echo

    # If previous download exists, delete it first (relevant in case of forced install)
    if [[ -d ${SP_BUILD} ]]; then
      rm -rf ${SP_BUILD}
    fi

    # Download SPLASH
    git clone https://github.com/danieljprice/splash.git ${SP_BUILD}

    # Download giza library
    cd ${SP_BUILD}
    git clone https://github.com/danieljprice/giza.git

    cd ${BUILDDIR}
  fi


  # Installing SPLASH
  echo
  echo "Installing SPLASH..."
  echo

  cd ${SP_BUILD}
  # Uninstall previous version
  if [ -f ${SP_BUILD}/m.log ]; then
    make clean |& tee >(ts "[%x %X]" > ${SP_BUILD}/cl.log)
  fi
  # Install SPLASH
  make SYSTEM=gfortran HDF5=yes HDF5ROOT=${HDF5_INSTALL} withgiza \
  |& tee >(ts "[%x %X]" > ${SP_BUILD}/m.log)

  cd ${BUILDDIR}
fi