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
MODULE = chipregs
#CMD = ../../../vi_scripts/vgen_1.py
CMD = ../../../../projects/bali/scripts/vgen.py
OPTIONS = -t

link_regs: 
	chmod +x $(CMD)
	$(CMD) $(OPTIONS) $(MODULE).xml
	$(CMD) $(MODULE).xml

