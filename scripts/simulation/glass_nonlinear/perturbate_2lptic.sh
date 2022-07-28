#!/bin/bash


# Get the path to the input unperturbed glass file
if [[ ${GLASS} = "/dev/null" ]]; then
  echo "[PERTURBATE] Glass wasn't generated yet!" \
       | ts "[%x %X]"
  clean_up
  exit 2
elif [[ ! -f ${GLASS} ]]; then
  echo "[PERTURBATE] Glass cannot be find in the data directory!" \
       | ts "[%x %X]"
  clean_up
  exit 2
fi


# Prepare output directories
if [[ ${O_PHASE} = true ]]; then
  PREFIX=IC_OP_${SUFFIX}
  IC_DIR=${DATADIR}/2LPT-IC/ICs/IC_OP_${SUFFIX_PER_DIR}
else
  PREFIX=IC_${SUFFIX}
  IC_DIR=${DATADIR}/2LPT-IC/ICs/IC_${SUFFIX_PER_DIR}
fi
export IC=${IC_DIR}/${PREFIX}
mkdir -p ${IC_DIR}
mkdir -p ${LOGDIR}/2LPT-IC

# Export IC name to parameters file
sed -i '/^IC / { s|:.*|: '"${IC}"'| }' ${SIMDIR}/parameters*.yml


# Prepare the parameterfile for 2LPT-IC
PARAM_DIR=${PIPELINEDIR}/parameters/2LPT-IC/parameterfiles
CURRENT_PARAM_DIR=${PARAM_DIR}/IC-${SUFFIX_PER_DIR}
CURRENT_PARAM_FILE=${CURRENT_PARAM_DIR}/${PREFIX}.param

mkdir -p ${CURRENT_PARAM_DIR}
cp ${PARAM_DIR}/2lptic.param ${CURRENT_PARAM_FILE}


# Change parameters in the new parameter file
sed -i '/^Nmesh$/ { s|$|           '"${NMESH}"'| }' ${CURRENT_PARAM_FILE}
sed -i '/^Nsample$/ { s|$|         '"${NMESH}"'| }' ${CURRENT_PARAM_FILE}
sed -i '/^Box$/ { s|$|             '"${LBOX_PER}"'| }' ${CURRENT_PARAM_FILE}

sed -i '/^FileBase$/ { s|$|        '"${PREFIX}"'| }' ${CURRENT_PARAM_FILE}
sed -i '/^OutputDir$/ { s|$|       '"${IC_DIR}"'| }' ${CURRENT_PARAM_FILE}
sed -i '/^GlassFile$/ { s|$|       '"${GLASS}"'| }' ${CURRENT_PARAM_FILE}
sed -i '/^GlassTileFac$/ { s|$|    '"${GLASSTILEFAC}"'| }' ${CURRENT_PARAM_FILE}

sed -i '/^Omega$/ { s|$|           '"${OMEGA_M}"'      % Total matter density  (at z=0)| }' ${CURRENT_PARAM_FILE}
sed -i '/^OmegaLambda$/ { s|$|     '"${OMEGA_L}"'      % Cosmological constant (at z=0)| }' ${CURRENT_PARAM_FILE}
sed -i '/^OmegaBaryon$/ { s|$|     '"${OMEGA_B}"'      % Baryon density        (at z=0)| }' ${CURRENT_PARAM_FILE}
sed -i '/^HubbleParam$/ { s|$|     '"${h}"'      % Hubble paramater (may be used for power spec parameterization)| }' ${CURRENT_PARAM_FILE}

sed -i '/^Redshift$/ { s|$|        '"${START_Z}"'        % Starting redshift| }' ${CURRENT_PARAM_FILE}

sed -i '/^InputSpectrum_UnitLength_in_cm$/ { s|$|  '"${S_g}"'| }' ${CURRENT_PARAM_FILE}
sed -i '/^UnitLength_in_cm$/ { s|$|          '"${S_g}"'  % defines length unit of output (in cm/h)| }' ${CURRENT_PARAM_FILE}
sed -i '/^UnitMass_in_g$/ { s|$|             '"${M_g}"'  % defines mass unit of output (in g/cm)| }' ${CURRENT_PARAM_FILE}
sed -i '/^UnitVelocity_in_cm_per_s$/ { s|$|  '"${V_g}"'  % defines velocity unit of output (in cm/sec)| }' ${CURRENT_PARAM_FILE}


# >>>>>> START OF APPLYING PERTURBATIONS TO THE GLASS <<<<<<
# If output directory exists, delete it first to remove previous IC slices
if [[ ! -z ${IC_DIR} ]]; then
  rm -rf ${IC_DIR}
fi
# Create directory for glass (2LPT-IC output)
mkdir -p ${IC_DIR}

if [[ ${O_PHASE} = true ]]; then
  echo
  echo "[PERTURBATE] Adding perturbations to the glass with 2LPT-IC (Opposite phase)..." \
       | ts "[%x %X]"
  echo
  echo "[PERTURBATE] Glass file is : ${GLASS}" \
       | ts "[%x %X]"
  echo

  ${BUILDDIR}/2LPT-IC-OP/2LPTic-op ${CURRENT_PARAM_FILE} \
  |& tee >(ts "[%x %X]" > ${LOGDIR}/2LPT-IC/2lpt_OP_${SUFFIX}.log)
else
  echo
  echo "[PERTURBATE] Adding perturbations to the glass with 2LPT-IC (Normal phase)..." \
       | ts "[%x %X]"
  echo
  echo "[PERTURBATE] Glass file is : ${GLASS}" \
       | ts "[%x %X]"
  echo

  ${BUILDDIR}/2LPT-IC/2LPTic ${CURRENT_PARAM_FILE} \
  |& tee >(ts "[%x %X]" > ${LOGDIR}/2LPT-IC/2lpt_${SUFFIX}.log)
fi

echo
echo "[PERTURBATE] Restoring masses in the created IC and slicing them..." \
     | ts "[%x %X]"
echo

conda activate cosmo-nbody
${SIMDIR}/gadget_io/recover_gadget_mass.py ${IC} ${GLASS_IC}_Mass ${GLASSTILEFAC}
${SIMDIR}/gadget_io/slice_gadget.py ${IC} ${N_FILES}
conda deactivate

# Tidy up the final directory
rm ${IC}
for FILE in ${IC}_Mass*; do
  mv "${FILE}" "${FILE/_Mass/}"
done
# >>>>>> END OF APPLYING PERTURBATIONS TO THE GLASS <<<<<<


# Return to script directory
cd ${SCRIPTDIR}