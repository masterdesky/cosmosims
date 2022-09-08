#!/bin/bash

# ==============================================================================
#
#   parse_yaml.sh
#
#   Parses the different yaml files of the simulation modules to create
#   sourceable bash files.
#
#   This file parses the `${2}*.yml` file in a target `${1}` module directory
#   and writes it into a file named as `${2}*-temp.sh` to the same directory.
#
#
# ==============================================================================

# If target directory does not exists or isn't defined, then quit.
if [[ -z ${1} ]]; then
  echo "Directory of target 'parameters*.yml' file should be defined!" \
  | ts "[%x %X]"
  exit 5
elif [[ ! -d ${1} ]]; then
  echo "Given target directory does not exist!" \
  | ts "[%x %X]"
  exit 2
fi
# If target YAML file does not exists or isn't defined, then also quit.
if [[ -z ${2} ]]; then
  echo "Name of target YAML file should be defined!" \
  | ts "[%x %X]"
  exit 5
fi

# Count parameter files in the target directory
# Exit if there's none or more parameter files exist
PARCOUNT=$(ls ${1} | grep ${2}.*.yml | wc -l)
if [[ ${PARCOUNT} = 0 ]]; then
  echo "A `${2}*.yml` file in the `${1}` directory should exist!" \
  | ts "[%x %X]"
  exit 2
elif [[ ${PARCOUNT} > 1 ]]; then
  echo "There should be only a single `${2}*.yml` file exists in the \
       '${1}' directory!" \
  | ts "[%x %X]"
  exit 2
fi

# Get the name of the parameter file titled as `${2}*.yml`
PARFILE=$(ls ${1} | grep ${2}.*.yml)
PARFILE=${PARFILE%.*}

# Parses `${2}*.yml` and saves output as `${2}*-temp.sh`
## SED1: Changes all `:` in the YAML to `="` while excluding the `://` string
##       that can be part of an URL.
SED1='s/:[^:\/\/]/="/g;'
## SED2: Puts a `"` character at the end of each line that is not empty nor is
##       a comment line. Excludes those valid lines too that contain an inline
##       comment. Checks for trailing lines preceeding EOF too.
SED2='/((^(\r\n|\n|\r)$)|(^(\r\n|\n|\r))|^\s*$|^#|^.*#.*$)/ ! s/$/"/g;'
## SED3: Same as `SED2`, but handles lines with inline comments specifically.
SED3='/\S+\s+#\w*/ { s|\s+#|"  #|g; }'
## SED4: Puts `export` at the beginning of each line that is not empty nor is
##       a comment line. Checks for trailing lines preceeding EOF too.
SED4='/(^(\r\n|\n|\r)$)|(^(\r\n|\n|\r))|^\s*$|^#|^\w*#.*$/ ! s/^/export /g;'
## SED5: Clears all whitespace that precede `=` symbols.
SED5='s/\s*=/=/g;'

sed -Ee "${SED1}" -Ee "${SED2}" -Ee "${SED3}" -Ee "${SED4}" -Ee "${SED5}" \
        ${1}/${PARFILE}.yml > ${1}/${PARFILE}-temp.sh
chmod +x ${1}/${PARFILE}-temp.sh

# Sourcing to enable parameters
if [[ -f ${1}/${PARFILE}-temp.sh ]]; then
  source ${1}/${PARFILE}-temp.sh
else
  echo "${1}/${PARFILE}-temp.sh generation failed!" \
  | ts "[%x %X]"
  exit 5
fi