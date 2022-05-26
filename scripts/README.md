## Prerequisites
- conda installed for user with an environment called `steps`,  containing
python, numpy, pandas, scipy, future, matplotlib, seaborn, astropy and h5py.
This can be setup via
    ```bash
    conda create --name steps python numpy pandas scipy future matplotlib seaborn astropy h5py
    ```

- Valid C, C++ and Fortran compilers, eg. GCC and GFortran that can be installed via
    ```bash
    sudo apt install build-essential gfortran
    ```
- I various circumstances C headers may be installed separately via
    ```bash
    sudo apt install libc-dev
    ```

- Autotools, whose binaries and libraries can be installed via
    ```bash
    sudo apt install automake autoconf libtool libedit
    ```

- `pkg-config` that can be installed via
    ```bash
    sudo apt install pkg-config
    ```

- Git that can be installed via
    ```bash
    sudo apt install git
    ```

- Wget and cURL that can be installed via
    ```bash
    sudo apt install wget curl
    ```

- Conda that can be installed on Linux using the install script from conda's website via
    ```bash
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh
    ```
    and then following the prompts

- Moreutils to display time in terminal info using `ts` can be installed via
    ```bash
    sudo apt install moreutils
    ```

- For GadgetViewer, at least GTK+ 2.0 is required that can be installed via
    ```bash
    sudo apt install libgtk2.0-dev
    ```

- GadgetViewer also requires some additional libraries if compiled using GCC 11.2+:
    ```bash
    sudo apt install libtool texinfo
    ```

- EinsteinToolkit requires the OpenBLAS library that can be installed via
    ```bash
    sudo apt install libopenblas-dev
    ```

- The FLRWSolver thorn for the Cactus framework requires the linking of static
Python libraries manually. This is done by the `python3-config` executable, and
it requires Python headers to be installed on the corresponding include paths.
If you're using `conda`, then Python headers are automatically installed and
this step can be skipped. Otherwise, Python headers can be installed system-wide
via
    ```bash
    sudo apt install python3-dev
    ```
