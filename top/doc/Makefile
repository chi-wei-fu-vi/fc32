#***************************************************************************
# Copyright (c) 2012 Virtual Instruments.
# 25 Metro Dr, STE#400, San Jose, CA 95110
# www.virtualinstruments.com
# $Archive: Makefile$
# $Author: honda.yang $
# $Date: 2012-11-26 14:44:31 -0800 (Mon, 26 Nov 2012) $
# $Revision: 697 $
# Description: Makefile for generating LINK_ENGINE module registers using 
#              vgen.py utility
#
#**************************************************************************/
CMD = ../../../../common/vi_scripts/vgen.py
DEC_OPTIONS = 0 3 -addr
C_HDR_OPTIONS = -c
P_HDR_OPTIONS = -p
DMP_OPTIONS = -reg_dump
REV = $(shell svn info fc16_regs_top.xml | grep Revision |sed 's/Revision: //')

top_regs: 
	chmod +x $(CMD)
	$(CMD) fc16_regs_top.xml $(DEC_OPTIONS)
	$(CMD) $(C_HDR_OPTIONS) fc16_regs_top.xml 
	$(CMD) $(P_HDR_OPTIONS) fc16_regs_top.xml 
	$(CMD) $(DMP_OPTIONS) fc16_regs_top.xml |tee fc16_regs_top.reg_dump 
	$(CMD) -dn fc16_regs_top.xml 2
	$(CMD) fc16_regs_top.xml
	mv reg_map0.c fc16_regs_top.c
	mv bitfields.py fc16_regs_top.py
	/usr/bin/svn info fc16_regs_top.xml |tee fc16_regs_top.version
	/usr/bin/zip fc16_regs_top.zip fc16_regs_top.c fc16_regs_top.py fc16_regs_top.reg_dump fc16_regs_top.version

