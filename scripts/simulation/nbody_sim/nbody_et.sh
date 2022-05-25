#!/bin/bash

cd ${BUILDDIR}/EinsteinToolkit/Cactus

# `conda.sh` should be sourced first if `conda` is ran from a bash script
source ${CONDAROOT}/etc/profile.d/conda.sh
conda activate et-flrw

# Python should be added to LD_LIBRARY_PATH
PYTHONPATH=$(which python3)
PYTHONPATH=${PYTHONPATH%/*/*}
if [[ ":${LD_LIBRARY_PATH}:" != *":${PYTHONPATH}/lib:"* ]]; then
  export LD_LIBRARY_PATH="${PYTHONPATH}/lib:${LD_LIBRARY_PATH}"
fi
echo ${LD_LIBRARY_PATH}

# Run the pre-built simulation using `simfactory`
PROGRAMNAME="flrw_test"
OUTDIR=${DATADIR}/EinsteinToolkit/simulations/${PROGRAMNAME}
#if [[ -d ${OUTDIR} ]]; then
#  rm -r ${OUTDIR}
#fi
FLRWSOLVERPATH=${BUILDDIR}/EinsteinToolkit/Cactus/repos/flrwsolver
ETPARFILE=FLRW_powerspectrum
#./simfactory/bin/sim create-run ${PROGRAMNAME} \
#        --parfile ${FLRWSOLVERPATH}/par/${ETPARFILE}.par \
#        --cores=8 \
#        --walltime=0:05:00


# Prepare simulation output for visualization with `splash`
cd ${OUTDIR}/output-0000/${ETPARFILE}/
python3 ${FLRWSOLVERPATH}/tools/split_HDF5_per_iteration3.py

Z=1200
splash -cactus_hdf5 ${ETPARFILE}_it00${Z}

conda deactivate