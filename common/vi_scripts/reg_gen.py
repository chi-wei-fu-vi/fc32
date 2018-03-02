#!/usr/bin/env python2
import xml.dom.minidom
import sys, os
import re

libdir = os.path.dirname(os.path.realpath(__file__)) + "/lib"
sys.path.append(libdir)  # for lib/xlwt module

import argparse
import xml.etree.ElementTree as ET
import string

parser = argparse.ArgumentParser()
parser.add_argument("-f", "--filename", help="File name")
args = parser.parse_args()


tree = ET.parse(args.filename)
regSet = tree.getroot()

for reg in regSet:
  regName = reg.get('name')
  regOffset = reg.get('offset')
  print "`define {0}  {1}".format(string.capitalize(regName), regOffset)

