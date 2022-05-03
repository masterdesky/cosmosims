#!/usr/bin/env python

import os
import sys
import numpy as np

b = float(sys.argv[1])
t = float(sys.argv[2])
outputs = np.linspace(b, t, int(sys.argv[3]))

with open(os.path.join(sys.argv[4], 'outputs.txt'), 'w+') as f:
  for o in outputs:
    print(f'{o:.6f}', file=f)
