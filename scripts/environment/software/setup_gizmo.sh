#!/bin/bash


if [[ ${INSTALL_GIZMO} = true ]];
then
  GIZMO_BUILD=${BUILDDIR}/GIZMO
  # Downloading GIZMO
  if [[ ! -d ${GIZMO_BUILD} || ${FORCE} = true ]]; then
    echo
    echo "Downloading GIZMO..."
    echo

    mkdir -p ${BUILDDIR}

    # If previous download exists, delete it first (relevant in case of forced install)
    if [[ -d ${GIZMO_BUILD} ]]; then
      rm -rf ${GIZMO_BUILD}
    fi

    git clone https://bitbucket.org/phopkins/gizmo-public.git ${GIZMO_BUILD}
  fi


  # Installing GIZMO
  echo
  echo "Installing GIZMO..."
  echo

  cd ${GIZMO_BUILD}
  # Uninstall previous version
  if [[ -f ${GIZMO_BUILD}/m.log ]]; then
      make clean |& tee >(ts "[%x %X]" > ${GIZMO_BUILD}/cl.log)
  fi

  #  Makefile and `Config.sh` setup
  cp ${BUILDSYS}/GIZMO/Makefile ${GIZMO_BUILD}/Makefile
  cp ${BUILDSYS}/GIZMO/Makefile.systype ${GIZMO_BUILD}/Makefile.systype
  cp ${BUILDSYS}/GIZMO/Config.sh ${GIZMO_BUILD}/Config.sh
  ## e) Prepare simulation parameters
  if [[ ! -z ${NMESH} ]]; then
    sed -i '/^#PMGRID/ { s|#PMGRID|PMGRID| }'
    sed -i '/^PMGRID/  { s|PMGRID=\d+|PMGRID='"${NMESH}"'| }' ${GIZMO_BUILD}/Config.sh
  else
    sed -i '/^PMGRID/  { s|PMGRID|#PMGRID| }' ${GIZMO_BUILD}/Config.sh
  fi
  
  # Build GIZMO
  make -j${N_CPUS} |& tee >(ts "[%x %X]" > ${GIZMO_BUILD}/m.log)

  cd ${BUILDDIR}
fi