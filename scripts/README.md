## Prerequisites

#### Universally used dependencies
- Valid C, C++ and Fortran compilers, eg. GCC and GFortran:
    ```bash
    sudo apt install build-essential gfortran
    ```
    In various circumstances C headers have to be installed separately, but
    usually it isn't needed. But otherwise, they can be installed via
    ```bash
    sudo apt install libc-dev
    ```

- Git is used to download mostly simulation software and can be installed via
    ```bash
    sudo apt install git
    ```

- Wget and cURL used to download "base" software (like OpenMPI or FFTW) and can
be installed via
    ```bash
    sudo apt install wget curl
    ```

- Autotools is used to build virtually every software that contained in this
tools. Its binaries and libraries can be installed via
    ```bash
    sudo apt install automake autoconf libtool libedit
    ```

- Conda (Miniconda) is used to create temporary Python environments that are
used for installing specific software, running parameter calculations for
simulations or using the analysis scripts. It can be installed on Linux by
running the installations script provided on the Conda website:
    ```bash
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh
    ```
    and then follow the prompts on screen.

- Moreutils is used to display time in terminal info using `ts` and it can be
installed via
    ```bash
    sudo apt install moreutils
    ```

#### Requirements only for specific software
- For GadgetViewer, at least GTK+ 2.0 is required that can be installed via
    ```bash
    sudo apt install libgtk2.0-dev
    ```

- GadgetViewer also requires some additional libraries if compiled using
GCC 11.2+:
    ```bash
    sudo apt install libtool texinfo
    ```

- EinsteinToolkit requires the OpenBLAS library that can be installed via
    ```bash
    sudo apt install libopenblas-dev
    ```

- The *FLRWSolver* thorn of the EinsteinToolkit needs necessary C and C++
headers and libraries to be linked manually. Querying the correct paths to
these is possible with `pkg-config` that can be installed via
    ```bash
    sudo apt install pkg-config
    ```

- *FLRWSolver* also needs static Python libraries to be linked manually. This 
can be done by the `python3-config` program, and it requires the headers from
the development version of Python. If you're using `conda`, then Python headers
are automatically installed and this step can be skipped. Otherwise, they can
be installed system-wide via
    ```bash
    sudo apt install python3-dev
    ```
