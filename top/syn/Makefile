###################################################################
# Project Configuration: 
# 
# Specify the name of the design (project), the Quartus II Settings
# File (.qsf), and the list of source files used.
###################################################################
PROJECT = fc16_top
SOURCE_FILES =
ASSIGNMENT_FILES = ${PROJECT}.tcl ${PROJECT}.qip ${PROJECT}.xdc
FPGA_REV_ROM_DIR = ../../xilinx_ip/altsyncram/fpga_rev_rom.coe
SEED = 1  
all: make_vgen build
mk_coe: auto
	vivado -mode tcl -source  ../../common/vi_scripts/mk_coe.tcl | tee mk_coe.log
	echo "cp fpga_rev_rom.coe ${FPGA_REV_ROM_DIR}";cp fpga_rev_rom.coe ${FPGA_REV_ROM_DIR}
make_vgen: mk_coe
	../../common/vi_scripts/make_vgen_xilinx.py ../doc/fc16_regs_top.xml ${PROJECT} | tee make_vgen.log
	if test `wc -l make_vgen.log|awk '{print $$1}'` == 0 ; then exit 1; fi
	if test `grep Error make_vgen.log|wc -l` != 0 ; then exit 1; fi
build:
	pushd work;vivado -mode tcl -source ${PROJECT}.tcl
auto:
#	rm -rf ../../chipregs/rtl/auto
#	mkdir ../../chipregs/rtl/auto
	rm -rf ../../common/vi_design/ucstats/rtl/auto
	mkdir ../../common/vi_design/ucstats/rtl/auto
	../../common/vi_scripts/auto_reg_wire.pl ../../common/vi_design/ucstats/rtl/ucstats_wrap.sv ../../common/vi_design/ucstats/rtl/auto/ucstats_wrap_autoreg.vh
seed: make_vgen
	pushd work;make $(PROJECT).map.rpt;popd
	make -f make.seed
