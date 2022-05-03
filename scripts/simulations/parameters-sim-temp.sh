# BUILD LOCATION OF SOFTWARES USED FOR THE SIMULATIONS
export CONDAROOT="${HOME}"
export BUILDDIR="${HOME}/apps"
export LOGDIR="${PIPELINEDIR}/logs"
export COMPUTER="my_comp"

# LOCATIONS OF VOLUME FILES THAT ARE IMPORTANT FOR THE SIMULATION
## Automatically filled
export GLASS_IC="/home/masterdesky/data/GADGET2/Glass_ICs/Glass_IC_N262144_L500_M1_min1"
export GLASS="/home/masterdesky/data/GADGET2/Simulations/Glasses/Glasses_N262144_L500_M1/output/Glass_N262144_L500_M1_min1"
export IC="/home/masterdesky/data/2LPT-IC/ICs/IC_N262144_L1000_M1/IC_N262144_L500_M1_min1"

# TECHNICAL PARAMETERS
export N_CPUS="4"
export N_GPUS="1"
export CUDA_VISIBLE_DEVICES="0,1,2"

# PARAMETERS FOR GLASS IC GENERATION
export NPART="262144"
export LBOX="500"
export LBOX_H="TO_BE_CALC"
export MBINS="1"
export PARTMIN="150"

# PARAMETERS FOR NBODY IC GENERATION AND SIMULATION
export NMESH="128"
export LBOX_PER="1000"
export LBOX_PER_H="TO_BE_CALC"
export GLASSTILEFAC="2"
export START_Z="127"
export END_Z="0"
export N_SNAPSHOTS="2"
export N_FILES="1"

# COSMOLOGICAL VARIABLES
export H0="67.66"
export h="TO_BE_CALC"
export S_g="TO_BE_CALC"
export M_g="TO_BE_CALC"
export V_g="TO_BE_CALC"
export OMEGA_B="0.0490"
export OMEGA_C="0.2607"
export OMEGA_M="0.3111"
export OMEGA_L="0.6889"
