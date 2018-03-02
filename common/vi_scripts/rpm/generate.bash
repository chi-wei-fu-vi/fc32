#!/bin/bash
# Convenience script for the CMake FPGA Bitfile RPM generation target
# Jacob Alexander 2014-2015

# Make sure needed arguments are given
#  Param 1:  Top-level register map .xml (used by vgen.py)
#  Param 2:  RPM Prefix    (e.g. nas)
#  Param 3:  Project name  (e.g. fiji)
#  Param 4+: RBF file path
if [ $# -lt 4 ]; then
	echo -e "\033[1;5;31mERROR\033[0m: Minimun 4 arguments necessary -> generate.bash <.xml register top-level> <rpm prefix> <project name> <.rbf path> [<.rbf path>..] "
	echo ""
	echo "Example: generate.bash /build/buildbot.fpga/fijiNightly/build.2014-06-26.0000-01/projects/fiji/top/doc/fiji_regs_top.xml nas fiji /build/buildbot.fpga/fijiNightly/build.2014-06-26.0000-01/projects/fiji/top/syn_best/fiji_top.rbf"
	exit 1
fi

# Assign the parameters
REGMAP=${1}
RPM_PREFIX=${2}
PROJECT=${3}
RBF_PATH=$(echo ${@:4} | sed -e 's/ /;/g') # Replace spaces with semicolons (CMake list)


# Find the current path of this script (used to find the CMakeLists.txt)
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
	SOURCE="$(readlink "$SOURCE")"
	[[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Locate vgen.py
VGEN=${SCRIPT_DIR}/../vgen.py

# Locate regmap version script
REGMAP_BASH=${SCRIPT_DIR}/regmap_versionDate.bash

# Locate tree version script
TREE_VERSION_BASH=${SCRIPT_DIR}/tree_versionDate.bash


# Determine regmap version
REGMAP_VERSION=$(${REGMAP_BASH} ${VGEN} ${REGMAP})

# Determine tree/svn version
TREE_VERSION=$(${TREE_VERSION_BASH} ${VGEN} ${REGMAP})


# Prepare rpm generation directory
mkdir -p rpmGen
cd rpmGen

# Prepare spec file for rpm generation
cmake -DBUILDBOT_BUILD=1 -DFPGA_RBF_FILE=${RBF_PATH} -DPROJECT_NAME=${PROJECT} -DRPM_PREFIX=${RPM_PREFIX} -DREGMAP_VERSION=${REGMAP_VERSION} -DSVN_COMMITDATE=${TREE_VERSION} ${SCRIPT_DIR}

# Generate rpm
make package

exit 0

