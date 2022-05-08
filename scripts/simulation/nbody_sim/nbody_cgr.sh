#!/bin/bash


# Prepare output directories
OUT_DIR=${DATADIR}/cosmograph/Simulations/test_run
mkdir -p ${OUT_DIR}
mkdir -p ${LOGDIR}/cosmograph


# >>>>>> START OF THE N-BODY SIMULATION <<<<<<
cd ${OUT_DIR}
mpirun -np ${N_CPUS} ${BUILDDIR}/CosmoGRaPH/build/cosmo \
       ${BUILDDIR}/CosmoGRaPH/input/kerr_blackhole.input
|& tee >(ts "[%x %X]" > ${LOGDIR}/cosmograph/cosmograph_test.log)
# >>>>>> END OF THE N-BODY SIMULATION <<<<<<

# Return to script directory
cd ${SCRIPTDIR}