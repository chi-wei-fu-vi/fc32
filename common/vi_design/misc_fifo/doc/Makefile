#***************************************************************************
# Copyright (c) 2012 Virtual Instruments.
# 25 Metro Dr, STE#400, San Jose, CA 95110
# www.virtualinstruments.com
# $Archive: Makefile$
# $Author: $
# $Date: $
# $Revision: $
# Description: Makefile for generating MISC_FIFO module registers using 
#              vgen.py utility
#
#**************************************************************************/
CMD = ../../../../common/vi_scripts/vgen.py
OPTIONS = -t
FILES := $(wildcard *.xml)

link_regs: 
	chmod +x $(CMD)
	$(foreach FILE, $(FILES), $(CMD) $(FILE);)
	$(foreach FILE, $(FILES), $(CMD) $(OPTIONS) $(FILE);)
