#***************************************************************************
# Copyright (c) 2012 Virtual Instruments.
# 25 Metro Dr, STE#400, San Jose, CA 95110
# www.virtualinstruments.com
# $Archive: Makefile$
# $Author: honda.yang $
# $Date: 2013-01-02 14:06:44 -0800 (Wed, 02 Jan 2013) $
# $Revision: 961 $
# Description: Makefile for generating MTIP_IF module registers using 
#              vgen.py utility
#
#**************************************************************************/
CMD = ../../../vi_scripts/vgen.py
OPTIONS = -t

mtip_if_regs: 
	chmod +x $(CMD)
	$(CMD) $(OPTIONS) mtip_if_fc1_regs.xml
	$(CMD) mtip_if_fc1_regs.xml
	$(CMD) $(OPTIONS) mtip_if_fc2_regs.xml
	$(CMD) mtip_if_fc2_regs.xml

