#!/usr/bin/env python
import sys
import numpy as np

import astropy.units as u
from astropy.units import cds
cds.enable()

np.random.seed(2021)


def cosmological_parameters(H0 : float):
  """
  Calculates the parameters of the background cosmology for the glass creation.

  Returns only the `rho_mean` parameter since that the only one needed for the
  mass generation.

  Parameters:
  -----------
  H0 : float
    Value of the Hubble constant at z=0

  Returns:
  --------
  rho_mean : float
    Average matter density in the given cosmology
  """
  G = 1.0*cds.G                     # G in SI
  S = 1.0*u.Mpc                     # Unit length in [Mpc]
  M = 1.0e11*u.solMass              # Unit mass in [Sol mass]
  T_nom = S.to(u.m)**3
  T_den = M.to(u.kg) * G.unit.si
  T = np.sqrt(T_nom / T_den)        # Unit time in [s]
  V = S / T                         # Unit velocity in [cm/s]

  # Glass generation is always performed by assuming
  # an Einstein de-Sitter universe
  OMEGA_M = 1.0
  # Norm factor for StePS/Gadget2 internal units
  a = (1.0 / V.to(u.km/u.s)).value
  # Scaled critical density [3*H0^2 / (8*G*Pi) * a^2 and G = 1]
  rho_crit = 3*H0**2 / (8*G.si.unit*np.pi) * a*a
  # Scaled mean denstiy [rho_c * Omega_m * a^2 and G = 1]
  rho_mean = rho_crit*OMEGA_M

  return rho_mean.value


def get_masses(NPART : int, LBOX_H : float, MBINS : int, PARTMIN : int,
               rho_mean : float):
  """
  Creates variable mass bins for the initial condition. This function generates
  the number of particles and the actual physical masses in `MBINS` number of
  mass bins for a cosmological simulation with variable masses.

  Parameters:
  -----------
  NPART : int
    Number of particles in the glass IC
  LBOX_H : float
    Boxsize of the glass IC [Mpc]
  MBINS : int
    Number of mass bins in the glass IC
  PARTMING : int
    Minimum number of particles in a mass bin
  rho_mean : float
    Average matter density in the given cosmology

  Returns:
  --------
  mass_list : numpy.array
    Array containing the actual physical masses of particles in each mass bin
  """

  # Decorator functions for the MDF to be used to sample masses from
  def f(X):
    P = 2**X
    return P[::-1]
  def get_MDF(_f, X):
    X = np.array(X)
    P = np.nan_to_num(_f(X), posinf=0, neginf=0)
    return P/P.sum()

  # Indexing mass bins
  mass_idx = np.arange(0,MBINS,1)
  # Array containing the relative masses of particles in each mass bin
  mass_list = 2**np.arange(0, MBINS, 1)
  # Assure there are always enough number of objects in every mass bin
  # All mass bins should contain at least `PARTMIN` particle in every case!
  mass_assure = np.ones(MBINS, dtype=int) + (PARTMIN-1)

  # Randomly choose particles sizes from the given distribution
  #
  ## Probabilities to choose a specific mass
  MDF = get_MDF(_f=f, X=mass_idx)  
  ## Sample masses from a given distribution
  C = np.random.choice(mass_idx, size=(NPART - mass_assure.sum()), replace=True,
                       p=MDF)
  
  # Array containing the number of particles in each mass bin
  part_list = mass_assure + \
              np.array([(C == i).sum() for i in mass_idx])

  # Setting the physical masses for each particle type
  #
  ## Total physical mass inside the cosmological volume [given in unit mass]
  Mtot = rho_mean*LBOX_H**3
  ## Unit mass in the given cosmology for the given number of particles and
  ## relative masses
  mass_unit = mass_list / np.sum(mass_list*part_list)
  ## Array containing the actual physical masses of particles in each mass bin
  mass_list = mass_unit * Mtot

  return part_list, mass_list


def create_IC(NPART : int, LBOX_H : float,
              part_list, mass_list):
  """
  Creates the array representing the glass IC that contains coordinates,
  velocities and masses of particles.
  
  Parameters:
  -----------
  NPART : int
    Number of particles in the glass IC
  LBOX_H : float
    Boxsize of the glass IC [Mpc]
  part_list : numpy.ndarray
    Array containing the number of particles in each mass bin
  mass_list : numpy.ndarray
    Array containing the actual physical masses of particles in each mass bin
  """
  # Random initial coordinates given in [Mpc]
  coordinates = np.random.rand(NPART,3) * LBOX_H
  # Zero initial velocities in [cm/s]
  velocities = np.zeros((NPART,3), dtype=np.float64)

  GLASS_IC = np.concatenate((coordinates, velocities), axis=1)
  GLASS_IC = np.concatenate((GLASS_IC, np.ones((NPART,1), dtype=np.float64)), axis=1)

  # Setting the physical masses for the particles
  j = 0
  for i, m in enumerate(mass_list):
    GLASS_IC[j:j+part_list[i], 6] = m
    j += part_list[i]
  
  return GLASS_IC


def save_IC(GLASS_IC, outfile : str):
  """
  Saves the generated glass IC.

  Parameters:
  -----------
  GLASS_IC : numpy.ndarray
    The 3D generated initial conditions for the glass creation
  outfile: str
    File to save the generated IC into
  """
  np.savetxt(outfile, GLASS_IC, delimiter='\t')


if __name__ == '__main__':

  # Input parameters
  NPART = int(sys.argv[1])    # Total number of particles
  LBOX_H = float(sys.argv[2]) # Boxsize of the glass IC [Mpc]
  MBINS = int(sys.argv[3])    # Total number of mass bins
  PARTMIN = int(sys.argv[4])  # Minimum number of particles in a mass bin

  H0 = float(sys.argv[5])     # Hubble constant [km/s/Mpc]
  outfile = sys.argv[6]       # Target file for the created glass IC

  rho_mean = cosmological_parameters(H0)
  part_list, mass_list = get_masses(NPART, LBOX_H, MBINS, PARTMIN,
                                    rho_mean)
  GLASS_IC = create_IC(NPART, LBOX_H, part_list, mass_list)
  save_IC(GLASS_IC, outfile)