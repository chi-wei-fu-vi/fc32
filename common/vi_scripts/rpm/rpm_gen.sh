#!/bin/bash
# rpm_gen.sh <rbf file>  <datetime>
# rpm_gen.sh fiji_top.rbf  1610261619
rm -rf rpmGen
mkdir rpmGen
mv fiji_top.rbf fiji-a7.rbf
cd rpmGen;cmake -DBUILDBOT_BUILD=1 -DFPGA_RBF_FILE=fiji-a7.rbf -DPROJECT_NAME=fiji -DRPM_PREFIX=nas -DREGMAP_VERSION=$2 -DSVN_COMMITDATE=$2 ..
make package
