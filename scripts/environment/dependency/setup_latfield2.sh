#!/bin/bash


if [[ ${INSTALL_LAT2} = true ]]; then
  # Downloading LATfield2
  if [[ ! -d ${LAT2_BUILD} || ${FORCE} = true ]]; then
    echo
    echo "Downloading LATfield2..."
    echo

    # If previous download exists, delete it first (relevant in case of forced install)
    if [[ -d ${LAT2_BUILD} ]]; then
      rm -rf ${LAT2_BUILD}
    fi

    # Download LATfield2
    git clone https://github.com/daverio/LATfield2.git ${BUILDDIR}/LATfield2
  fi

  # Installing LATfield2
  echo
  echo "Installing LATfield2..."
  echo

  # Uninstall previous version
  if [[ -d ${LAT2_INSTALL} ]]; then
    rm -rf ${LAT2_INSTALL}
  fi

  # Install LATfield2
  mkdir -p ${LAT2_INSTALL}/include
  cp ${LAT2_BUILD}/*.h* ${LAT2_INSTALL}/include
  cp -r ${LAT2_BUILD}/particles ${LAT2_INSTALL}/include
  cd ${BUILDDIR}
fi