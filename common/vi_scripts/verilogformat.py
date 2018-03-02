#!/usr/bin/env python2
import re
from pprint import pprint
from veriloglang import *
from verilogparse import *
class verilogformat(veriloglang,verilogparse):
   """
   """
   def __init__(self):
     """
     """
if __name__=='__main__':
  import sys
  argc=len(sys.argv)
  if argc > 1: infile=sys.argv[1]
