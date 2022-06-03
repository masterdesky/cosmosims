#!/bin/bash


if [[ ${INSTALL_PYL3} = true ]];
then
  PYL3_BUILD=${BUILDDIR}/Pylians3
  # Downloading Pylians3
  if [[ ! -d ${PYL3_BUILD} || ${FORCE} = true ]]; then
    echo
    echo "Downloading Pylians3..."
    echo

    # If previous download exists, delete it first (relevant in case of forced install)
    if [[ -d ${PYL3_BUILD} ]]; then
      rm -rf ${PYL3_BUILD}
    fi

    mkdir -p ${PYL3_BUILD}

    # Download Pylians3
    git clone https://github.com/franciscovillaescusa/Pylians3.git ${PYL3_BUILD}

    cd ${BUILDDIR}
  fi
  

  # Installing Pylians3
  echo
  echo "Installing Pylians3..."
  echo

  # Setup conda env for building Pylians3
  if { conda env list | grep 'pylians-build'; } >/dev/null 2>&1; then
    conda remove --name pylians-build --all -y
  fi
  conda create --name pylians-build python numpy scipy h5py pyfftw mpi4py cython -y

  # `conda.sh` should be sourced first if `conda` is ran from a bash script
  source ${CONDAROOT}/etc/profile.d/conda.sh
  conda activate pylians-build
  
  # Install Pylians3
  cd ${PYL3_BUILD}/library
  python3 setup.py build |& tee >(ts "[%x %X]" > ${PYL3_BUILD}/m.log)

  sed -i '/^export PYL3_INSTALL/ { s|=.*|='"${PYL3_BUILD}"'/library/build/lib.linux-x86_64-cpython-310| }' ${SCRIPTDIR}/setup_env.sh

  echo
  echo "Testing Pylians3..."
  echo
  python ${PYL3_BUILD}/Tests/import_libraries.py
  
  conda deactivate
  conda remove --name pylians-build --all -y
  cd ${BUILDDIR}
fi