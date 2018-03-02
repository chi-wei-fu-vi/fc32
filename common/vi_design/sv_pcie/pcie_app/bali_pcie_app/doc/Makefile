#***************************************************************************
# Copyright (c) 2012 Virtual Instruments.
# 25 Metro Dr, STE#400, San Jose, CA 95110
# www.virtualinstruments.com
# $Archive: Makefile$
# $Author: leon.zhou $
# $Date: 2012-11-26 14:44:31 -0800 (Mon, 26 Nov 2012) $
# $Revision: 697 $
# Description: Makefile for generating LINK_ENGINE module registers using 
#              vgen.py utility
#
#**************************************************************************/
CMD = ../../../../../vi_scripts/vgen.py
OPTIONS = -t
FILES := $(wildcard *.xml)

link_regs: 
	chmod +x $(CMD)
	$(foreach FILE, $(FILES), $(CMD) $(FILE);)
	$(foreach FILE, $(FILES), $(CMD) $(OPTIONS) $(FILE);)
