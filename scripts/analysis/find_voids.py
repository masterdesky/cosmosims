import re
import os
import sys
import h5py

import numpy as np
import matplotlib.cm as cm
import matplotlib.pyplot as plt

import void_library as VL
from matplotlib.colors import LogNorm



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

    ############# void finder setup #############
    threshold = -0.5  # For delta(r)=-1*(1-(r/R)^3)
    Rmax = 100.0      # Maximum radius of the input voids
    Rmin = 15.0       # Minimum radius of the input voids
    bins = 50         # Number of radii between Rmin and Rmax to find voids

    threads1 = 8 #openmp threads
    threads2 = 4

    # find voids
    Radii = np.logspace(np.log10(Rmin), np.log10(Rmax), bins+1, dtype=np.float32)
    V = VL.void_finder(delta, LBOX_PER, threshold, Radii,
                       threads1, threads2, void_field=True)
    delta2 = V.in_void

    ############# plot voids #############
    nr, nc = 1, 2
    fig, (ax1, ax2) = plt.subplots(nr, nc, figsize=(nc*7, nr*7))

    # plot the density field of the random spheres
    ax1.imshow(delta[:, :, RES_T//2],
               cmap=cm.nipy_spectral, interpolation='bicubic',
               origin='lower', extent=[0, LBOX_PER, 0, LBOX_PER])

    # plot  the void field identified by the void finder
    ax2.imshow(np.mean(delta2[:,:,:],axis=0),
               cmap=cm.nipy_spectral_r,origin='lower',
               vmin=0, vmax=1.0, extent=[0, LBOX_PER, 0, LBOX_PER])

    plt.savefig('test.png', bbox_inches='tight')
    plt.show()

    return


if __name__ == "__main__":
    main()