#!/usr/bin/env python2
import re
import copy
from pprint import pprint
from pprint import pformat
from veriloglang import *
class verilogreport(object):
  def code2msgdictgen(self):
    lines="""
E00001  Un-synthesizable syntax
E00002  verilog-1995 port declaration   input/output/inout statement end with semicolon
E00003  verilog-1995 function style
E00004  parameter in module body
E00005  wire and reg declaration
E00006  `timescale in file
E00007  always statement
E00008  case without preceding priority and unique keywords
E00009  instant without dot-name format
E00010  initial statement
E00011  unpacked array not in C-style format
E00012  use integer instead of genvar
E00013  embedded synthesis/timing directives in comment
E00014  sdc timing constraints
E00015  No module, instant, logic following the (* *) directive 
E00016  syntheis directive not recognized
E00017  signal name convention violation
E00018  negative assert reset signal not ends with _n
E00019  clock signal not ends with clk, clkp and clkn
E00020  tick define
E00021  blocking and non-blocking assignments
E00022  assert property
E00023  double slash with synthesis directives or altera directives or sdc directives
E00024  slash star with synthesis directives or altera directives or sdc directives
E00025  parentheses star with sdc directives
E00026  parentheses star with sythesis directives or altera directives without following module or instant or logic

W00001  unpacked array
W00002  use int
W00003  use {with{1'b1}} to set all bits to 1 instead of '{default:'1}
W00004  enum construct is not used in state signal
    """
    self.code2msg={}
    for line in lines.split('\n'):
      line=line.strip()
      if line!='':
        idx=line.index(' ')
        code=line[:idx]
        msg=line[idx+1:]   
        self.code2msg[code]=msg
      
