#!/bin/bash

## Path variables for StePS and glass generation
# - `GLASS_IC_DIR`  : Directory to contain generated ICs for StePS glass gen.
# - `GLASS_IC`      : File storing an IC for StePS glass gen.
# - `GLASS_DIR`     : Directory to contain the outputs of the glass gen.
# - `GLASS`         : File storing the generated glass

# Used only if glass generation is read from input file
GLASS_IC_DIR=${DATADIR}/StePS/Glass_ICs
GLASS_IC=${GLASS_IC_DIR}/Glass_IC_${SUFFIX}

# Prepare output directories
PREFIX=Glass_${SUFFIX}
GLASS_DIR=${DATADIR}/StePS/Simulations/Glasses/Glasses_${SUFFIX_DIR}
export GLASS=${GLASS_DIR}/${PREFIX}
mkdir -p ${GLASS_IC_DIR} ${GLASS_DIR}
mkdir -p ${LOGDIR}/StePS

# Export glass name to parameters file
sed -i '/^GLASS / { s|:.*|: '"${GLASS}"'| }' ${SIMDIR}/parameters*.yml


# Prepare the parameterfile for StePS
PARAM_DIR=${PIPELINEDIR}/parameters/StePS/parameterfiles
CURRENT_PARAM_DIR=${PARAM_DIR}/Glasses_N${NPART}_${LBOX}
CURRENT_PARAM_FILE=${CURRENT_PARAM_DIR}/${PREFIX}.param

mkdir -p ${CURRENT_PARAM_DIR}
cp ${PARAM_DIR}/StePS.param ${CURRENT_PARAM_FILE}


# Parameters for relevant files
sed -i '/^H0$/ { s|$| '"${H0}"'| }' ${CURRENT_PARAM_FILE}
sed -i '/^L_box$/ { s|$| '"${LBOX_H}"'| }' ${CURRENT_PARAM_FILE}
sed -i '/^IC_FILE$/ { s|$| .'"${GLASS_IC}"'.dat| }' ${CURRENT_PARAM_FILE}
sed -i '/^OUT_DIR$/ { s|$| .'"${GLASS_DIR}"'| }' ${CURRENT_PARAM_FILE}
sed -i '/^OUT_LST$/ { s|$| .'"${GLASS_DIR}"'/outtimes.txt| }' ${CURRENT_PARAM_FILE}


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
  conda deactivate

  echo
  echo "[GLASS GEN] Glass IC generation is complete!" \
       | ts "[%x %X]"
  echo
fi

if [[ ${GLASS_SIM} = true ]] && [[ ${FORCE_G2} != true ]]; then
  echo
  echo "[GLASS GEN] Generating glass using StePS..." \
       | ts "[%x %X]"
  echo

  # If output directory exists, delete it first, because StePS just appends
  # data at the end of files in it
  if [[ ! -z ${GLASS_DIR} ]]; then
    rm -rf ${GLASS_DIR}
  fi
  # (Re)create the directory for StePS outputs
  mkdir -p ${GLASS_DIR}
  
  # Create an `outtimes.txt` file and write "0" into it
  # This will tell StePS to write the current state of the simulation
  # into this file exclusively at z=0
  echo "0" >> ${GLASS_DIR}/outtimes.txt

  # Detect whether to run StePS on GPUs or CPUs
  if [[ -f ${GLASS_IC}.dat ]] && [[ -d ${GLASS_DIR} ]]; then
    # Number of threads per computing units (feasibly it equals to 1)
    export OMP_NUM_THREADS=1
    if [[ -f /usr/cuda/bin/nvcc ]] || [[ -f /usr/local/cuda/bin/nvcc ]]; then
      mpirun -n ${OMP_NUM_THREADS} ${BUILDDIR}/StePS/StePS/src/StePS_CUDA \
      ${CURRENT_PARAM_FILE} ${N_GPUS} \
      |& tee >(ts "[%x %X]" > ${LOGDIR}/StePS/${PREFIX}_GPU.log)
    else
      mpirun -np ${N_CPUS} --use-hwthread-cpus \
      ${BUILDDIR}/StePS/StePS/src/StePS \
      ${CURRENT_PARAM_FILE} ${OMP_NUM_THREADS} \
      |& tee >(ts "[%x %X]" > ${LOGDIR}/StePS/${PREFIX}_CPU.log)
    fi
  else
    echo
    echo "[GLASS GEN]" | ts "[%x %X]"
    echo "Input glass IC file"
    echo "    ${GLASS_IC}.dat"
    echo "or the output directory"
    echo "    ${GLASS_DIR}"
    echo "does not exist!"
    echo
    clean_up
    exit 1;
  fi

  echo
  echo "[GLASS GEN] Converting StePS output to Gadget format..." \
       | ts "[%x %X]"
  echo

  # Convert ASCII file to Gadget and rescale quantities from [Mpc] to [Mpc/h]
  conda activate cosmo
  ${SIMDIR}/gadget_io/ascii2gadget.py ${GLASS_DIR}/z0.dat ${GLASS} \
                                      ${LBOX} ${START_Z} \
                                      ${H0} ${OMEGA_M} ${OMEGA_L}
  conda deactivate

  echo
  echo "[GLASS GEN] StePS glass successfully created!" \
       | ts "[%x %X]"
  echo
fi
# >>>>>> END OF THE GLASS GENERATION <<<<<<