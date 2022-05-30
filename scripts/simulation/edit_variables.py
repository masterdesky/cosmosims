#!/usr/bin/env python
import os
import sys
import fileinput
import numpy as np

import astropy.units as u
from astropy.units import cds
cds.enable()

def replace_a_line(original_line, new_line, file):
  print('new line: \" {0} \"'.format(new_line))

  with fileinput.FileInput(file, inplace=True) as f:
    for line in f:
      if original_line in line:
        print(line.replace(original_line, new_line), end ='')
      else:
        print(line, end ='')

def edit_variables(H0, RES, LBOX, LBOX_PER, path):
  """
  Calculates cosmological units, which are needed for the whole simulation
  pipeline. Needed variables are the following:
  
      - S_unit : Mpc / h
      - M_unit : 1.0e11*M_Sun / h
      - V_unit : cm / s

  The "V_unit" is exclusively used by GADGET to ensure that the Hubble parameter
  equals to exactly `H_0 = 100` in GADGET's internal units.
  """
  # The V_unit value is only compatible with
  # GADGET but not with StePS
    
  h = H0 / 100                    # Hubble parameter
  G = 1.0*cds.G                   # G in SI
  S = 1.0*u.Mpc                   # Unit length in [Mpc]
  M = 1.0e11*u.solMass            # Unit mass in [Sol mass]
  T_nom = S.to(u.m)**3
  T_den = M.to(u.kg) * G.unit.si
  T = np.sqrt(T_nom / T_den)      # Unit time in [s]
  #V = S / T                       # Unit velocity in [cm/s]

  S_unit = S.cgs.value            # Unit length in cm
  M_unit = M.cgs.value            # Unit mass in g
  V_unit = 1e05                   # Unit velocity in cm/s

  # Get name of the parameterfile, named as `parameters-*.sh`
  files = np.array(os.listdir(path))
  mask_a = np.array(['parameters-sim' in f for f in files])
  mask_b = np.array(['.sh' in f for f in files])
  parfile = files[mask_a & mask_b][0]

  # Placeholder strings for lines to be changed
  line_change = "export {0}=\"TO_BE_CALC\""
  line_target = "export {0}=\"{1:.6e}\""

  # Add `h`
  replace_a_line(line_change.format('h'),
                 line_target.format('h', h),
                 file=os.path.join(path, parfile))
  # Calculate `NPART`, the number of particles
  replace_a_line(line_change.format('NPART'),
                 line_target.format('NPART', RES**3),
                 file=os.path.join(path, parfile))
  # Add `LBOX_H` ([LBOX / h] = [Mpc])
  replace_a_line(line_change.format('LBOX_H'),
                 line_target.format('LBOX_H', LBOX/h),
                 file=os.path.join(path, parfile))
  # Add `LBOX_PER_H` ([LBOX_PER / h] = [Mpc])
  replace_a_line(line_change.format('LBOX_PER_H'),
                 line_target.format('LBOX_PER_H', LBOX_PER/h),
                 file=os.path.join(path, parfile))

  # Add `S_unit`
  replace_a_line(line_change.format('S_g'),
                 line_target.format('S_g', S_unit),
                 file=os.path.join(path, parfile))
  # Add `M_unit`
  replace_a_line(line_change.format('M_g'),
                 line_target.format('M_g', M_unit),
                 file=os.path.join(path, parfile))
  # Add `V_unit`
  replace_a_line(line_change.format('V_g'),
                 line_target.format('V_g', V_unit),
                 file=os.path.join(path, parfile))

if __name__ == '__main__':

  H0 = float(sys.argv[1])         # 
  RES = int(sys.argv[2])          # Resolution of the simulation box
  LBOX = float(sys.argv[3])       # Boxsize of the simulation in [Mpc/h]
  LBOX_PER = float(sys.argv[4])   # Boxsize of the multiplied simulation in [Mpc/h]
  path = sys.argv[5]              # 

  edit_variables(H0, RES, LBOX, LBOX_PER, path)
