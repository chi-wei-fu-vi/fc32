#!/bin/bash
# Determines the last modified date for the entire vgen register map tree
# Needs a path to vgen and the top-level register .xml
# Requires SVN to function
#
# Jacob Alexander 2014

VGEN=${1} # common/vi_scripts/vgen.py
XML=${2}  # projects/fiji/top/doc/fiji_regs_top.xml

XML_FILES=$(${VGEN} ${XML} --list-xml-files)

MODIFIED_DATE=$(svn info ${XML_FILES} | grep "Last Changed Date:" | sed -e "s|^Last Changed Date: \(.\+\) (.\+).*$|\1|" | sort -r | head -n 1)

date +%y%m%d%H%M -d "${MODIFIED_DATE}"

exit 0

