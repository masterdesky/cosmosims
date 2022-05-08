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
PREFIX=G4_${SUFFIX}
OUT_DIR=${DATADIR}/GADGET4/Simulations/DM_${SUFFIX_PER_DIR}
mkdir -p ${OUT_DIR}
mkdir -p ${LOGDIR}/GADGET4


# Prepare parameter files
PARAM_DIR=${PIPELINEDIR}/parameters/GADGET4/parameterfiles
CURRENT_PARAM_DIR=${PARAM_DIR}/G4-${SUFFIX_PER_DIR}
CURRENT_PARAM_FILE=${CURRENT_PARAM_DIR}/${PREFIX}.param

mkdir -p ${CURRENT_PARAM_DIR}
cp ${PARAM_DIR}/GADGET4.param ${CURRENT_PARAM_FILE}


# 1. Parameters for relevant files
sed -i '/^InitCondFile/ { s|\r$|         '"${IC}"'| }' ${CURRENT_PARAM_FILE}
sed -i '/^OutputDir/ { s|\r$|            '"${OUT_DIR}"'/output| }' ${CURRENT_PARAM_FILE}
sed -i '/^SnapshotFileBase/ { s|\r$|     '"DM_NW"'| }' ${CURRENT_PARAM_FILE}
sed -i '/^OutputListFilename/ { s|\r$|   '"${OUT_DIR}"'/outputs.txt| }' ${CURRENT_PARAM_FILE}
# 2. I/O settings
sed -i '/^MaxFilesWithConcurrentIO/ { s|\r$|  '"${N_CPUS}"'| }' ${CURRENT_PARAM_FILE}
# 3. Characteristics of run
#START_T=$(printf %.6f\\n "$(( 10**6 * 1 / (START_Z + 1) ))e-6")
#END_T=$(printf %.6f\\n "$(( 10**6 * 1 / (END_Z + 1) ))e-6")
START_T=$(echo "scale=6;x=1 / (${START_Z} + 1); if(x<1) print 0; x" | bc)
END_T=$(echo "scale=6;x=1 / (${END_Z} + 1); if(x<1) print 0; x" | bc)
sed -i '/^TimeBegin/ { s|\r$|        '"${START_T}"'| }' ${CURRENT_PARAM_FILE}
sed -i '/^TimeMax/ { s|\r$|          '"${END_T}"'| }' ${CURRENT_PARAM_FILE}
# 4. Cosmological parameters
sed -i '/^Omega0/ { s|\r$|          '"${OMEGA_M}"'| }' ${CURRENT_PARAM_FILE}
sed -i '/^OmegaLambda/ { s|\r$|     '"${OMEGA_L}"'| }' ${CURRENT_PARAM_FILE}
sed -i '/^OmegaBaryon/ { s|\r$|     '"${OMEGA_B}"'| }' ${CURRENT_PARAM_FILE}
sed -i '/^HubbleParam/ { s|\r$|     '"${h}"'| }' ${CURRENT_PARAM_FILE}
sed -i '/^Hubble/ { s|\r$|          '"100"'| }' ${CURRENT_PARAM_FILE}
sed -i '/^BoxSize/ { s|\r$|         '"${LBOX_PER}"'| }' ${CURRENT_PARAM_FILE}
# 5. Cosmological units
sed -i '/^UnitLength_in_cm/ { s|\r$|           '"${S_g}"'   ;  Mpc / h | }' ${CURRENT_PARAM_FILE}
sed -i '/^UnitMass_in_g/ { s|\r$|              '"${M_g}"'   ;  1e10*M_Sun / h| }' ${CURRENT_PARAM_FILE}
sed -i '/^UnitVelocity_in_cm_per_s/ { s|\r$|   '"${V_g}"'   ;  cm / s| }' ${CURRENT_PARAM_FILE}


# >>>>>> START OF THE N-BODY SIMULATION <<<<<<
# Generate outputs.txt
## Activate environment containing astropy and the basic packages
conda activate cosmo
python3 ${SIMDIR}/nbody_sim/outputs.py ${START_T} ${END_T} ${N_SNAPSHOTS} ${OUT_DIR}
conda deactivate

cd ${OUT_DIR}
mpirun -np ${N_CPUS} --use-hwthread-cpus \
       ${BUILDDIR}/GADGET4/Gadget4 ${CURRENT_PARAM_FILE} \
|& tee >(ts "[%x %X]" > ${LOGDIR}/GADGET4/gadget4_${SUFFIX}.log)
# >>>>>> END OF THE N-BODY SIMULATION <<<<<<


# Return to script directory
cd ${SCRIPTDIR}