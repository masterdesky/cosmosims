#!/usr/bin/env python

# ==============================================================================
#
#   ascii2gadget.py
#
#   Converts an ASCII file to the Gadget Legacy 1 format using the `glio`
#   Python 2.X package. Latter runs on Python 3.X using the `future` package.
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


def recover_masses(s, massfile, GLASSTILEFAC):

  # Loading mass array
  M = np.genfromtxt(massfile, dtype=np.float32)

  # Transforming mass array to match the size of the multiplied glass
  M = np.tile(M, GLASSTILEFAC**3)

  # Correct masses to match the different cosmology introduced after the
  # glass generation and multiplication
  M *= s.mass[1].sum() / M.sum()

  # Adding final mass block to the input Gadget file
  s.mass[1] = M

  return s

def correct_ids(s):
  """
  In some cases, 2LPT-IC can mess up indeces of a multiplied volume, rendering
  it unreadable by GADGET or other softwares. This function ensures that the
  output IC contains a valid ID block in any case.

  Parameter:
  ----------
  s : Gadget-format file
    The Gadget file with (conceivably) incorrect s.ID[1] values
  
  Returns:
  --------
  s : Gadget-format file
    The Gadget file with valid s.ID[1] values
  """
  s.ID[1] = np.arange(0, len(s.ID[1]), dtype='uint32')

  return s

if __name__ == '__main__':

  infile = sys.argv[1]              # Input Gadget file (perturbed glass) with S in [Mpc/h]
  massfile = sys.argv[2]            # Input ASCII file containing the particle masses

  GLASSTILEFAC = int(sys.argv[3])   # How many times the glass was multiplied
                                    # into every direction

  
  s = glio.GadgetSnapshot(infile); s.load()
  s = recover_masses(s=s, massfile=massfile, GLASSTILEFAC=GLASSTILEFAC)
  s = correct_ids(s=s)
  s.save()