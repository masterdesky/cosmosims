import re
import os
import sys
import h5py

import numpy as np
import matplotlib.cm as cm
import matplotlib.pyplot as plt

import Pk_library as PKL


def main() -> None:
    
    RES = int(sys.argv[1])
    GHOST = 6
    RES_T = RES + GHOST
    LBOX_PER = int(sys.argv[2])
    HOME = os.environ['HOME']
    DATADIR = f'{HOME}/data/EinsteinToolkit/simulations/flrw_R{RES}_L{LBOX_PER}/output-0001/einsteintoolkit'
    FBASE = "einsteintoolkit_it"  # Base name of the output files
    FILES = sorted([f for f in os.listdir(DATADIR) if re.match(f'^{FBASE}', f)])
    FNAME = os.path.join(DATADIR, FILES[-1])
    FILE = h5py.File(FNAME, 'r')

    keylist = list(FILE.keys())[:-1]
    delta = np.array(FILE[keylist[13]], dtype=np.float32)
    FILE.close()

    ############# calculate power spectrum #############
    Pk = PKL.Pk(delta,
                BoxSize=LBOX_PER,
                axis=0,
                MAS='CIC',
                threads=8,
                verbose=True
            )
    k   = Pk.k3D

    ############# plot power spectrum #############
    fig = plt.figure(figsize=(10, 7))
    plt.grid(True, ls='-', alpha=0.6)

    plt.xscale('log')
    plt.xlim(1e-3, 1e0)

    # Power spectrum multipole components
    plt.plot(k, Pk.Pk[:, 0], label='Monopole component',
             color='tab:red', ls='--', lw=2)
    plt.plot(k, Pk.Pk[:, 1], label='Quadrupole component',
             color='tab:green', ls='--', lw=2)
    plt.plot(k, Pk.Pk[:, 2], label='Hexadecapole component',
             color='tab:orange', ls='--', lw=2)
    # Sum of multipole components
    #plt.plot(k, np.sum(Pk.Pk, axis=1), label='Sum', color='black', lw=3)

    plt.legend(loc='upper left', fontsize=12)

    plt.show()

    return


if __name__ == "__main__":
    main()