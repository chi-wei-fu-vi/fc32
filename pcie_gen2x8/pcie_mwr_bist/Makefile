#***************************************************************************
# Copyright (c) 2012 Virtual Instruments.
# 25 Metro Dr, STE#400, San Jose, CA 95110
# www.virtualinstruments.com
# $Archive: Makefile$
# $Author: honda.yang $
# $Date: 2012-11-13 16:10:30 -0800 (Tue, 13 Nov 2012) $
# $Revision: 555 $
# Description: Makefile for generating FCOE module registers using 
#              vgen.py utility
#
#**************************************************************************/
CMD = ../../../../vi_scripts/vgen.py
OPTIONS = -t

pcie_mwr_bist_regs: 
	chmod +x $(CMD)
	$(CMD) $(OPTIONS) pcie_mwr_bist_regs.xml
	$(CMD) pcie_mwr_bist_regs.xml

