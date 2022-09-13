#!/bin/bash

cd ${BUILDDIR}/EinsteinToolkit/Cactus

# 1. Setup Python environment needed to run FLRWSolver
## `conda.sh` should be sourced first if `conda` is ran from a bash script
source ${CONDAROOT}/etc/profile.d/conda.sh
## Create and activate a conda environment for FLRWSolver
if { conda env list | grep 'et-flrw'; } >/dev/null 2>&1; then
  conda remove --name et-flrw --all -y
fi
conda create --name et-flrw python=3.8 numpy scipy cffi h5py astropy -y
conda activate et-flrw
## Path to python headers should be added to `LD_LIBRARY_PATH`
PYTHONPATH=$(which python3)
PYTHONPATH=${PYTHONPATH%/*/*}
if [[ ":${LD_LIBRARY_PATH}:" != *":${PYTHONPATH}/lib:"* ]]; then
  export LD_LIBRARY_PATH="${PYTHONPATH}/lib:${LD_LIBRARY_PATH}"
fi


# 2. Setup output directory
## Select a program name and output dir. name based on simulation parameters
PROGRAMNAME="flrw_R${RES}_L${LBOX_PER}"
OUTDIR=${DATADIR}/EinsteinToolkit/simulations/${PROGRAMNAME}
## Delete previous output directory generated during run with same parameters
if [[ -d ${OUTDIR} ]]; then
  rm -rf ${OUTDIR}
fi
mkdir -p ${OUTDIR}


# 3. Setup the parameter file template
## Get rootdir of the FLRWSolver thorn
FLRWSOLVERPATH=${BUILDDIR}/EinsteinToolkit/Cactus/repos/flrwsolver
## Get rootdir of EinsteinToolkit parameterfiles
ETPARFILEDIR=${ROOTDIR}/parameterfiles/EinsteinToolkit
## Create directory and template for parameterfiles used in the simulation
mkdir -p ${ETPARFILEDIR}/${PROGRAMNAME}
PARNAME=einsteintoolkit
ETPAR=${ETPARFILEDIR}/${PROGRAMNAME}/${PARNAME}.par
ETRESPAR=${ETPARFILEDIR}/${PROGRAMNAME}/${PARNAME}_restart.par
cp ${ETPARFILEDIR}/${PARNAME}.par ${ETPAR}
cp ${ETPARFILEDIR}/${PARNAME}_restart.par ${ETRESPAR}
## Location of parameter file used by Simfactory2 
SIMPAR=${OUTDIR}/SIMFACTORY/par/${PARNAME}.par


# 4. Determine and fill values to the parameterfile templates
## Calculating cosmological and simulation parameters
python3 ${SIMDIR}/edit_et_par.py ${RES} ${LBOX_PER} 1100 ${ZINC} ${ETPAR} ${ETRESPAR}

## Specifying location of power spectrum in parameterfile
PKPATH=${FLRWSOLVERPATH}/powerspectra/camb/FLRW_matterpower_z1100.dat
sed -i '/^FLRWSolver::FLRW_powerspectrum_file/ { s|=.*|= '"${PKPATH}"'| }' ${ETPAR}
## Specifying location of restart directory for restart parameter file
sed -i '/^IO::recover_dir/ { s|=.*|= \"'"${PARNAME}"'\/\"| }' ${ETRESPAR}

## Frequency of 3D outputs at high `z` values (iterations per output)
INIT_F=200
sed -i '/^IOHDF5::out3d_every/ { s|=.*|= '"${INIT_F}"'| }' ${ETPAR}
## Frequency of 3D outputs at low `z` values (iterations per output)
INCR_F=1
sed -i '/^IOHDF5::out3d_every/ { s|=.*|= '"${INCR_F}"'| }' ${ETRESPAR}


# 5. Run the simulation up to a selected `z` value, before steering parameters
./simfactory/bin/sim create-run ${PROGRAMNAME} \
        --parfile ${ETPAR} \
        --cores ${N_CPUS} \
        --walltime 24:00:00 \
|& tee >(ts "[%x %X]" > ${OUTDIR}/run.log)


# 6. Restart the simulation with a larger output frequency at low z values
## The `run` command, used to run an already initialized simulation, searches
## for a valid job ID, created during the initialization. While `create-submit`
## generates an ID, `create-run` does not. To abridge this issue, one can append
## an arbitrary job ID to the `properties.ini` file containing the job ID in
## case of submitted runs. This number should be larger than 65536 to do not
## mess with valid job IDs of the system.
echo "jobid = 99999" >> ${OUTDIR}/output-0000/SIMFACTORY/properties.ini
## Change parameters for restart by overwriting the parameter file in the
## control dir. of Simfactory2 for the `${PROGRAMNAME}` simulation
cp ${ETRESPAR} ${SIMPAR}

./simfactory/bin/sim run ${PROGRAMNAME} \
        --recover \
        --from-restart-id 0 \
        --cores ${N_CPUS} \
        --walltime 24:00:00 \
|& tee >(ts "[%x %X]" >> ${OUTDIR}/run.log)


# 7. Prepare simulation output for visualization with SPLASH
cd ${OUTDIR}/output-0000/${PARNAME}
python3 ${FLRWSOLVERPATH}/tools/split_HDF5_per_iteration3.py
cd ${OUTDIR}/output-0001/${PARNAME}
python3 ${FLRWSOLVERPATH}/tools/split_HDF5_per_iteration3.py
## Conda environment isn't needed anymore
conda deactivate


# 8. Visualize with splash
#Z=1200
#splash -cactus_hdf5 ${ETPARFILE}_it00${Z}.hdf5