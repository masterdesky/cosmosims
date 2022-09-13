#!/usr/bin/env python
import re
import sys
import fileinput
import subprocess
import numpy as np


import astropy.units as u
from astropy.units import cds
from astropy import constants as const
cds.enable()


def edit_variables(RES, LBOX_PER, ZINI, ZINC, ETPAR, ETRESPAR, SEED=None):
    '''
    Define some functions for FLRW analytic scale factor, redshift, evolution
    '''

    def aflrw(etaval, ainit, etainit):
        return ainit * (etaval / etainit)**2
    
    def get_z(aval, zinit):
        return (1. + zinit) / aval - 1.

    # Seed for the simulation (maximum of unsigned int32)
    if SEED is None:
        SEED = np.random.randint(low=0, high=(2_147_483_647 + 1), dtype=np.uint32)
    # Desired proper/comoving length of box at redshift z=0 in Gpc/h
    Lz0   = LBOX_PER/1000 * u.Gpc # /h
    # Initial redshift, scale factor, time (latter should stay the same)
    zini  = ZINI
    ainit = 1.0
    # Simulation (code units) box size, dtfac, res, etc
    boxL  = 1.0
    dtfac = 0.1
    dx    = boxL / RES
    dt    = dtfac * dx
    # Redshift after which you'd like to increase freq of 3D output
    zinc = ZINC
    
    print()
    print(f' Hello! finding initial FLRWSolver parameters for your choices: ')
    print(f'                   res = {RES}')
    print(f'    box length (z = 0) = {Lz0}/h')
    print(f'    box length  (code) = {boxL}')
    print(f'      initial redshift = {zini}')
    print(f'  initial scale factor = {ainit}')
    print(f'                 dtfac = {dtfac}')
    print()
    print(' ---------------------------------------------------------------')
    print()
    '''
    Use H_0 = 100 h km/s/Mpc such that [L]=Mpc/h
        & find HL at z=0
    '''
    H0    = 100. * u.km / (u.s * u.Mpc)
    dH_z0 = (const.c/H0).to('Mpc')
    HLz0  = (H0*Lz0/const.c).to('')

    print(f'                   H_0 = {H0.value} h {H0.unit}')
    print(f'  Hubble horizon (z=0) = {dH_z0}/h')
    print(f'               HL(z=0) = {HLz0}')
    print(' Assuming the EdS model and scaling back to initial redshift ...')
    '''
    Scale HL(z=0) back to desired initial redshift
    '''
    HL_zini = HLz0 * np.sqrt(1. + zini)
    Lz0mpc = Lz0.to('Mpc')
    H_zini = (const.c*HL_zini/Lz0mpc).to('km/s Mpc')
    print(f"                H_zini = {H_zini.value} h {H_zini.unit}")

    '''
    Find settings for final time, etc
        -- assume we want to run to z=0
        -- set up array of conformal times, translate to a_flrw
        -- then we can find final_time in conformal time to run to
    '''
    afinal      = 1. + zini  # final scale factor we want to run to
    Hinit       = HL_zini / boxL
    tinit       = 2./Hinit  # conformal time (2/3 is for proper time)
    rhostarinit = Hinit**2 * 3. * ainit / (8.*np.pi)
    etatest     = np.arange(tinit,1e2,dt)
    aflrwval    = aflrw(etatest,ainit,tinit)
    zvals       = get_z(aflrwval,zini)
    aidx_fin    = np.where(aflrwval>afinal)[0][0]
    zidx_inc    = np.where(zvals<zinc)[0][0]    # index where z<1 for the first time, when to increase output
    eta_inc     = etatest[zidx_inc]             # time at which we want to then increase freq. of 3D data
    etafinal    = etatest[aidx_fin]
    itfinal     = (etafinal-tinit)/dt
    itz1        = (etatest[zidx_inc]-tinit)/dt  # iteration where z=`zinc`
    print('')
    print(f' Running from a = {ainit} to a = {aflrwval[aidx_fin]} will take {int(itfinal)} iterations.')
    print(f' The sim will reach z={zvals[zidx_inc]:.4f} at eta = {etatest[zidx_inc]:.4f} after {int(itz1)} iterations')

    print(f'')
    print(f'    ---> Settings for par file: ')
    print(f' FLRWSolver::FLRW_init_HL            = {HL_zini}')
    print(f' FLRWSolver::FLRW_init_a             = {ainit}')
    print(f' FLRWSolver::FLRW_lapse_value        = {ainit}')
    print(f' FLRWSolver::FLRW_boxlength          = {Lz0mpc.value} (Mpc/h)')

    print('    ---> REMEMBER to use the matter power spectrum in synchronous gauge')

    print('')
    print(f' First run to z = {zinc}:')
    print('')
    print(f' Cactus::cctk_initial_time = {tinit}')
    print(f' Cactus::cctk_final_time   = {eta_inc}')
    print(f'   time::dtfac             = {dtfac} ')

    print('')
    print(' --- RESTART PARAMS ---')
    print(f' Cactus::cctk_final_time   = {etafinal}')
    print('')
    print(' Have a good simulation! Bye!')
    print()

    replace = {
        'CoordBase::dx' : dx,
        'CoordBase::dy' : dx,
        'CoordBase::dz' : dx,
        'Cactus::cctk_initial_time' : tinit,
        'Cactus::cctk_final_time'   : eta_inc,
        'time::dtfac'   : dtfac,
        'FLRWSolver::FLRW_lapse_value' : ainit,
        'FLRWSolver::FLRW_init_HL'     : HL_zini,
        'FLRWSolver::FLRW_init_a'      : ainit,
        'FLRWSolver::FLRW_random_seed' : SEED,
        'FLRWSolver::FLRW_boxlength'   : Lz0mpc.value,
    }
    replace_str = {
        'IO::recover_file' : f"\"checkpoint.chkpt\"", #.it_{int(itz1)+1}",
        'Cactus::cctk_final_time' : etafinal
    }
    
    # Change normal parameterfile
    file = ""
    with open(ETPAR, 'r') as f:
        for line in f:
            s = line.split('=')[0].strip()
            if replace.get(s) is not None:
                line = re.sub('=.*', f'= {replace[s]}', line)
            file += f'{line}'
    with open(ETPAR, 'w+') as f:
        f.write(file)
    
    # Change restart parameterfile
    file = ""
    with open(ETRESPAR, 'r') as f:
        for line in f:
            s = line.split('=')[0].strip()
            if replace_str.get(s) is not None:
                line = re.sub('=.*', f'= {replace_str[s]}', line)
            file += f'{line}'
    with open(ETRESPAR, 'w+') as f:
        f.write(file)
        

if __name__ == '__main__':

    RES = int(sys.argv[1])
    LBOX_PER = float(sys.argv[2])
    ZINI = float(sys.argv[3])
    ZINC = float(sys.argv[4])
    ETPAR = sys.argv[5]
    ETRESPAR = sys.argv[6]

    edit_variables(RES, LBOX_PER, ZINI, ZINC, ETPAR, ETRESPAR)