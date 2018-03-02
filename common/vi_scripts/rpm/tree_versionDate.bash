#!/bin/bash
# Determines the last modified date for the SVN tree as defined by the vgen register map
# e.g. common, and project/emerald for the emerald project
# Needs a path to vgen and the top-level register .xml
# Requires SVN to function
#
# Jacob Alexander 2014

VGEN=${1} # common/vi_scripts/vgen.py
XML=${2}  # projects/fiji/top/doc/fiji_regs_top.xml

if ! [ -x  $(command -v realpath) ]; then
  COMMON_PATH=$(${VGEN} ${XML} --list-xml-files | xargs realpath | grep -o ".*/common/" | sort -u)
  PROJECT_PATHS=$(${VGEN} ${XML} --list-xml-files | xargs realpath | grep -P -o ".*/projects/.*?/" | sort -u)
else
  cat << EOT > realpath.py
#!/usr/bin/env python
import sys
import os

if len(sys.argv) <= 1:
        print os.path.realpath(os.getcwd())
else:
        print os.path.realpath(sys.argv[1])
EOT
  chmod 777 realpath.py
  COMMON_PATH=$(${VGEN} ${XML} --list-xml-files | xargs ./realpath.py | grep -o ".*/common/" | sort -u)
  PROJECT_PATHS=$(${VGEN} ${XML} --list-xml-files | xargs ./realpath.py | grep -P -o ".*/projects/.*?/" | sort -u)
fi

# PROJECT_PATHS may contain 1 or more paths depending on how the project is setup (ideally just 1)

MODIFIED_DATE=$(svn info ${COMMON_PATH} ${PROJECT_PATHS} | grep "Last Changed Date:" | sed -e "s|^Last Changed Date: \(.\+\) (.\+).*$|\1|" | sort -r | head -n 1)

date +%y%m%d%H%M -d "${MODIFIED_DATE}"

exit 0

