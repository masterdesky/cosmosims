# HDF5 libraries

find_library(HDF5_LIBRARIES
  NAMES hdf5 libhdf5
  HINTS ENV LD_LIBRARY_PATH)

find_path(HDF5_INCLUDE_DIRS
  NAMES hdf5.h
  HINTS ENV CPLUS_INCLUDE_PATH)

if(NOT HDF5_LIBRARIES)
  message(FATAL_ERROR "${Red}The HDF5 libraries and include locations were not found. Please make sure you have HDF5 installed or loaded, and that the library and include directories can be found in CPLUS_INCLUDE_PATH and LD_LIBRARY_PATH environment variables.${ColorReset}")
else()
  set(HDF5_LINK_LIBRARY "${HDF5_LIBRARIES}")
  if(NOT DEFINED HDF5_C_LIBRARIES)
    message(STATUS " No HDF5_C_LIBRARIES. Trying HDF5_LIBRARIES: ${HDF5_LIBRARIES}")
    set(HDF5_LINK_LIBRARY "${HDF5_LIBRARIES}")
    if(NOT DEFINED HDF5_LIBRARIES)
      message(WARNING "${Yellow}The HDF5 libraries were not found. CMake will continue, but linking may not succeed. Please make sure you have HDF5 installed/loaded, and that the library and include directories can be found in, eg, CPLUS_INCLUDE_PATH and LD_LIBRARY_PATH.${ColorReset}")
    endif()
  endif()
  message(STATUS " HDF5_LIBRARIES: ${HDF5_LIBRARIES}")
  message(STATUS " HDF5_INCLUDE_DIRS: ${HDF5_INCLUDE_DIRS}")
  include_directories("${HDF5_INCLUDE_DIRS}")
endif()
