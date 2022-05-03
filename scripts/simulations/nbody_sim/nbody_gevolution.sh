#!/bin/bash


# Get the path to the input unperturbed glass file
if [[ ${IC} = "/dev/null" ]]; then
  echo "[NBODY] N-body IC wasn't generated yet!" \
       | ts "[%x %X]"
  clean_up
  exit 2
elif [[ ! -f ${IC} && ! -f ${IC}.0 ]]; then
  echo "[NBODY] N-body IC cannot be find in the data directory!" \
       | ts "[%x %X]"
  clean_up
  exit 2
fi


# Prepare output directories
PREFIX=gevolution_${SUFFIX}
OUT_DIR=${DATADIR}/gevolution/Simulations/DM_${SUFFIX_PER_DIR}
mkdir -p ${OUT_DIR}
mkdir -p ${LOGDIR}/gevolution


# Prepare parameter files
PARAM_DIR=${PIPELINEDIR}/parameters/gevolution/parameterfiles
CURRENT_PARAM_DIR=${PARAM_DIR}/gevolution-${SUFFIX_PER_DIR}
CURRENT_PARAM_FILE=${CURRENT_PARAM_DIR}/${PREFIX}.param

mkdir -p ${CURRENT_PARAM_DIR}
cp ${PARAM_DIR}/gevolution.param ${CURRENT_PARAM_FILE}


# Change parameters in the new parameter file
# 1. Parameters for relevant files
sed -i '/^particle file / { s|$|   '"${IC}"'| }' ${CURRENT_PARAM_FILE}
## `output path` needs a `/` at the end!
sed -i '/^output path / { s|$|   '"${OUT_DIR}"'/| }' ${CURRENT_PARAM_FILE}
sed -i '/^generic file base / { s|$|   '"DM_GR"'| }' ${CURRENT_PARAM_FILE}
sed -i '/^snapshot file base / { s|$|   '"DM_GR_snap"'| }' ${CURRENT_PARAM_FILE}
sed -i '/^Pk file base / { s|$|   '"DM_GR_Pk"'| }' ${CURRENT_PARAM_FILE}
# 2. Characteristics of run
sed -i '/^initial redshift / { s|$|   '"${START_Z}"'| }' ${CURRENT_PARAM_FILE}
#LBOX_PER_GEV=$(printf %.3f\\n "$(( 10**3 * LBOX_PER / 1000 ))e-3")
LBOX_PER_GEV=$(echo "scale=3;x=${LBOX_PER} / 1000; if(x<1) print 0; x" | bc)
echo "SIM SIZE: ${LBOX_PER_GEV}"
sed -i '/^boxsize / { s|$|   '"${LBOX_PER_GEV}"'| }' ${CURRENT_PARAM_FILE}
sed -i '/^Ngrid / { s|$|   '"${NMESH}"'| }' ${CURRENT_PARAM_FILE}
# 3. Cosmological parameters
sed -i '/^h / { s|$|   '"${h}"'| }' ${CURRENT_PARAM_FILE}


# >>>>>> START OF THE N-BODY SIMULATION <<<<<<
cd ${OUT_DIR}
mpirun -np ${N_CPUS} --use-hwthread-cpus \
       ${BUILDDIR}/gevolution-1.2/gevolution 
       -n 2 -m 4 -s ${CURRENT_PARAM_FILE} \
|& tee >(ts "[%x %X]" > ${LOGDIR}/gevolution/gevolution_${SUFFIX}.log)
# >>>>>> END OF THE N-BODY SIMULATION <<<<<<


# Return to script directory
cd ${SCRIPTDIR}