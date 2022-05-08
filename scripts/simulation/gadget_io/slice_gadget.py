#!/usr/bin/env python

# ==============================================================================
#
#   slice_gadget.py
#
#   Slicing up a file in Gadget Legacy 1 format to multiple smaller files,
#   however identical in its size.
#
#
# ==============================================================================


import os
import sys
import numpy as np

import astropy.units as u
from astropy.units import cds
cds.enable()

# Using `glio` (written in Python 2.x) in Python 3.x
glio_path = os.path.abspath("../../../lib")
#print(f'Abs path to glio: {glio_path}')
if glio_path not in sys.path: sys.path.append(glio_path)
from past.translation import autotranslate
autotranslate(['glio'])
import glio


def slice_IC(s, infile, N_FILES):

  NPART = len(s.ID[1])
  for i in range(N_FILES):
    if i == N_FILES-1:
      mask = slice(i*NPART//N_FILES, None)
    else:
      mask = slice(i*NPART//N_FILES, (i+1)*NPART//N_FILES)

    # Give relevant tables new aliases
    X = s.pos[1][mask,:]
    V = s.vel[1][mask,:]
    I = s.ID[1][mask]
    M = s.mass[1][mask]


    if N_FILES == 1:
      s_sl = glio.GadgetSnapshot(f'{infile}_Mass')
    else:
      s_sl = glio.GadgetSnapshot(f'{infile}_Mass.{i}')
    s_sl.header.npart = np.array([0,NPART,0,0,0,0], dtype=np.int32)
    s_sl.header.mass = s.header.mass
    s_sl.header.time = s.header.time
    s_sl.header.redshift = s.header.redshift
    s_sl.header.flag_sfr = s.header.flag_sfr
    s_sl.header.flag_feedback = s.header.flag_feedback
    s_sl.header.npartTotal =  s.header.npartTotal
    s_sl.header.flag_cooling = s.header.flag_cooling
    s_sl.header.num_files = np.array([N_FILES], dtype=np.int32)
    s_sl.header.BoxSize = s.header.BoxSize
    s_sl.header.Omega0 =  s.header.Omega0
    s_sl.header.OmegaLambda =  s.header.OmegaLambda
    s_sl.header.HubbleParam = s.header.HubbleParam
    s_sl.header.flag_stellarage = s.header.flag_stellarage
    s_sl.header.flag_metals = s.header.flag_metals
    s_sl.header.npartTotalHighWord = s.header.npartTotalHighWord
    s_sl.header.flag_entropy_instead_u = s.header.flag_entropy_instead_u
    s_sl.header._padding = s.header._padding

    s_sl.pos[1] = np.array(X, dtype=np.float32)
    s_sl.vel[1] = np.array(V, dtype=np.float32)
    s_sl.ID[1] = np.array(I, dtype=np.uint32)
    s_sl.mass[1] = np.array(M, dtype=np.float32)

    # Saving the multiplied glass with masses included
    s_sl.save()


if __name__ == '__main__':

  infile = sys.argv[1]              # Input Gadget file (perturbed glass) with S in [Mpc/h]
  N_FILES = int(sys.argv[2])        # Number of files to slice the IC into

  s = glio.GadgetSnapshot(infile); s.load()
  slice_IC(s=s, infile=infile, N_FILES=N_FILES)