#!/bin/bash

## Path variables for GADGET2 and glass generation
# - `GLASS_IC_DIR`  : Directory to contain generated ICs for StePS glass gen.
# - `GLASS_IC`      : File storing an IC for StePS glass gen.
# - `GLASS_DIR`     : Directory to contain the outputs of the glass gen.
# - `GLASS`         : File storing the generated glass

# Used only if glass generation is read from input file
GLASS_IC_DIR=${DATADIR}/GADGET2/Glass_ICs
GLASS_IC=${GLASS_IC_DIR}/Glass_IC_${SUFFIX}

# Prepare output directories
PREFIX=Glass_${SUFFIX}
GLASS_DIR=${DATADIR}/GADGET2/Simulations/Glasses/Glasses_${SUFFIX_DIR}
export GLASS=${GLASS_DIR}/output/${PREFIX}                # In contrary to StePS, GADGET2 
mkdir -p ${GLASS_IC_DIR} ${GLASS_DIR} ${GLASS_DIR}/output # requires an extra `/output` directory!
mkdir -p ${LOGDIR}/GADGET2

# Export glass and glass IC's name to parameters file
sed -i '/^GLASS / { s|:.*|: '"${GLASS}"'| }' ${SIMDIR}/parameters*.yml
sed -i '/^GLASS_IC / { s|:.*|: '"${GLASS_IC}"'| }' ${SIMDIR}/parameters*.yml


# Prepare the parameterfile for GADGET2
PARAM_DIR=${PIPELINEDIR}/parameters/GADGET2/parameterfiles
CURRENT_PARAM_DIR=${PARAM_DIR}/Glasses_N${NPART}_L${LBOX}
CURRENT_PARAM_FILE=${CURRENT_PARAM_DIR}/${PREFIX}.param

mkdir -p ${CURRENT_PARAM_DIR}
cp ${PARAM_DIR}/GADGET2.param ${CURRENT_PARAM_FILE}


# Parameters for relevant files
if [[ ${FORCE_G2} = true ]]; then
  sed -i '/^InitCondFile/ { s|$|       /dev/null/| }' ${CURRENT_PARAM_FILE}
else
  sed -i '/^InitCondFile/ { s|$|       '"${GLASS_IC}"'| }' ${CURRENT_PARAM_FILE}
fi
sed -i '/^OutputDir/ { s|$|          '"${GLASS_DIR}"'/output| }' ${CURRENT_PARAM_FILE}
sed -i '/^SnapshotFileBase/ { s|$|   '"${PREFIX}"'| }' ${CURRENT_PARAM_FILE}
sed -i '/^OutputListFilename/ { s|$| '"${GLASS_DIR}"'/outputs.txt| }' ${CURRENT_PARAM_FILE}
# 2. Cosmological parameters
sed -i '/^HubbleParam/ { s|$|   '"${h}"'| }' ${CURRENT_PARAM_FILE}
sed -i '/^BoxSize/ { s|$|       '"${LBOX}"'| }' ${CURRENT_PARAM_FILE}
# 3. Cosmological units
sed -i '/^UnitLength_in_cm/ { s|$|         '"${S_g}"'   ;  Mpc / h | }' ${CURRENT_PARAM_FILE}
sed -i '/^UnitMass_in_g/ { s|$|            '"${M_g}"'   ;  1e11*M_Sun / h| }' ${CURRENT_PARAM_FILE}
sed -i '/^UnitVelocity_in_cm_per_s/ { s|$| '"${V_g}"'   ;  cm / s| }' ${CURRENT_PARAM_FILE}


# >>>>>> START OF THE GLASS GENERATION <<<<<<
if [[ ${GLASS_IC_GEN} = true ]]; then
  echo
  echo "[GLASS GEN] Generating IC for the glass generation..." \
       | ts "[%x %X]"
  echo

  # Activate environment containing astropy and the basic packages
  conda activate cosmo
  # Generate IC for StePS glass generation
  ${SIMDIR}/glass_linear/generate_glass_IC.py ${NPART} ${LBOX_H} ${MBINS} \
                                              ${PARTMIN} ${H0} ${GLASS_IC}.dat

  echo
  echo "[GLASS GEN] Converting glass IC generation output to Gadget format..." \
       | ts "[%x %X]"
  echo

  # Convert ASCII file to Gadget and rescale quantities from [Mpc] to [Mpc/h]
  ${SIMDIR}/gadget_io/ascii2gadget.py ${GLASS_IC}.dat ${GLASS_IC} \
                                      ${LBOX} ${START_Z} \
                                      ${H0} "1.0" "0.0"
  conda deactivate

  echo
  echo "[GLASS GEN] Glass IC generation is complete!" \
       | ts "[%x %X]"
  echo
fi

if [[ ${GLASS_SIM} = true ]] && [[ ${FORCE_STEPS} != true ]]; then
  echo
  echo "[GLASS GEN] Generating glass using GADGET2..." \
       | ts "[%x %X]"
  echo
  
  # Compile GADGET-2 with the set parameters
  ${SCRIPTDIR}/environment/start_top.sh --ig2

  # Create an `outputs.txt` file and write "1.0" into it
  # This will tell GADGET2 to write the current state of the simulation
  # into this file exclusively at z=0
  echo "1.0" > ${GLASS_DIR}/outputs.txt

  cd ${GLASS_DIR}
  mpirun -np ${N_CPUS} --use-hwthread-cpus \
         ${BUILDDIR}/GADGET2/Gadget2/Gadget2 ${CURRENT_PARAM_FILE} \
  |& tee >(ts "[%x %X]" > ${LOGDIR}/GADGET2/${PREFIX}.log)

  if [[ ! -f ${GLASS}_000 ]]; then
    echo "[GLASS GEN] Glass generation failed! No output was generated!" \
         | ts "[%x %X]"
    clean_up
    exit 2;
  fi
  mv ${GLASS}_000 ${GLASS}

  echo
  echo "[GLASS GEN] GADGET2 glass successfully created!" \
       | ts "[%x %X]"
  echo
fi
# >>>>>> END OF THE GLASS GENERATION <<<<<<
