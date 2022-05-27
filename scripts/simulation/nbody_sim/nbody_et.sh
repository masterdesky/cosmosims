#!/bin/bash

cd ${BUILDDIR}/EinsteinToolkit/Cactus

# `conda.sh` should be sourced first if `conda` is ran from a bash script
source ${CONDAROOT}/etc/profile.d/conda.sh
# Setup conda env for ET + FLRWSolver
if { conda env list | grep 'et-flrw'; } >/dev/null 2>&1; then
  conda remove --name et-flrw --all -y
fi
conda create --name et-flrw python=3.8 numpy scipy cffi h5py -y

conda activate et-flrw
# Python should be added to LD_LIBRARY_PATH
PYTHONPATH=$(which python3)
PYTHONPATH=${PYTHONPATH%/*/*}
if [[ ":${LD_LIBRARY_PATH}:" != *":${PYTHONPATH}/lib:"* ]]; then
  export LD_LIBRARY_PATH="${PYTHONPATH}/lib:${LD_LIBRARY_PATH}"
fi
echo ${LD_LIBRARY_PATH}

# Setup output directory
PROGRAMNAME="flrw_test_${SUFFIX_PER}"
OUTDIR=${DATADIR}/EinsteinToolkit/simulations/${PROGRAMNAME}
## Delete previous run with the same parameters
if [[ -d ${OUTDIR} ]]; then
  rm -r ${OUTDIR}
  mkdir -p ${OUTDIR}
fi

FLRWSOLVERPATH=${BUILDDIR}/EinsteinToolkit/Cactus/repos/flrwsolver
# Get parfile name and location
ETPARFILE=FLRW_powerspectrum
ETPARFILEPATH=${FLRWSOLVERPATH}/par/${ETPARFILE}.par
# Changing power spectrum file location
PKPATH=${FLRWSOLVERPATH}/powerspectra/camb/FLRW_matterpower_z1100.dat
sed -i '/^FLRWSolver::FLRW_powerspectrum_file/ { s|=.*|= '"${PKPATH}"'| }' ${ETPARFILEPATH}
./simfactory/bin/sim create-run ${PROGRAMNAME} \
        --parfile ${ETPARFILEPATH} \
        --cores=${N_CPUS} \
        --walltime=0:05:00 \
|& tee >(ts "[%x %X]" > ${OUTDIR}/run.log)

# Prepare simulation output for visualization with `splash`
cd ${OUTDIR}/output-0000/${ETPARFILE}/
python3 ${FLRWSOLVERPATH}/tools/split_HDF5_per_iteration3.py

conda deactivate
conda remove --name et-flrw --all -y

# Visualize with splash
Z=1200
splash -cactus_hdf5 ${ETPARFILE}_it00${Z}.hdf5