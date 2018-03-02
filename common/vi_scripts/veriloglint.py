#!/usr/bin/env python2
import re
from pprint import pprint
from veriloglang import *
from verilogparse import *
from verilogcheck import *
from verilogreport import *
from verilogformat import *
class veriloglint(veriloglang,verilogparse,verilogcheck,verilogreport):
  """
  """
  def __init__(self,infile,outfile):
    """
    """
    self.standard2keywords('1800-2012')
    self.read(infile)
    self.parse_function(self.lines_w_annotate)
    self.gen_topdb()
    self.check()
    self.put_w_beginblock(outfile)

  def check(self,debug=False):
    checkobj=verilogcheck()
    self.slashstars=checkobj.check_slashstar(self.slashstars)
    self.slashdoubles=checkobj.check_slashdouble(self.slashdoubles)
    self.parenthesesstars=checkobj.check_parenthesesstar(self.parenthesesstars)
    if debug:
      print filter(lambda x: x[1]!="",self.slashstars)
      print filter(lambda x: x[1]!="",self.slashdoubles)
      print filter(lambda x: x[2]!="",self.parenthesesstars)

  def put_w_beginblock(self,file,debug=False):
    self.rpts=[]
    top=self.topgen_w_beginblock(debug=False)
    if False and debug:
      print top.get_w_beginblock()
      print filter(lambda x: ' REPORTE0' in x or ' REPORTW0' in x,top.get_w_beginblock().split('\n'))
    self.code2msgdictgen()
    for lineno,line in enumerate(top.get_w_beginblock().split('\n'),1):
      if   ' REPORTE0' in line:
        idx=line.index(' REPORTE0')
        code=line[idx+7:idx+13]
        if debug:
          print "Error  : line %d (%s) %s"%(lineno,code,self.code2msg[code])
        self.rpts.append("Error  : line %d (%s) %s"%(lineno,code,self.code2msg[code]))
      elif ' REPORTW0' in line:
        idx=line.index(' REPORTW0')
        code=line[idx+7:idx+13]
        if debug:
          print "Warning: line %d (%s) %s"%(lineno,code,self.code2msg[code])
        self.rpts.append("Warning: line %d (%s) %s"%(lineno,code,self.code2msg[code]))
        
      
    with open(file,'w') as f:
      f.write(top.get_w_beginblock())
    f.close()

  def topgen_w_beginblock(self,debug=False):
    """
    with error message
    """
    def dfs(funcs,count):
      """
      """
      attrs=[]
      if type(funcs)!=type(list()):
        return funcs.get_w_beginblock()
      elif len(funcs)==1:
        return funcs[0].get_w_beginblock()
      elif len(funcs)==2 and type(funcs[0])!=type(list()) and type(funcs[1])==type(list()):
        if debug:
          print count,funcs
        top,subfuncs=funcs
        for i,func in enumerate(subfuncs):
          rtns=dfs(func,count+1)
          if debug:
            print i,count,pformat(rtns).replace('\\n','\n')
          if type(rtns)==type(list()):
            attrs.extend(rtns)
          else:
            attrs.append(rtns)
        if debug:
          print '\n'.join(map(lambda x: pformat(x).replace('\\n','\n'),attrs))
        top.lines_w_beginblock=top.backannotate_func(top.lines_w_beginblock,attrs)
        #top.lines_w_beginblock=top.backannotate_parenthesesstar(top.lines_w_beginblock,self.parenthesesstars)
        #top.lines_w_beginblock=top.backannotate_slashdouble(top.lines_w_beginblock,self.slashdoubles)
        #top.lines_w_beginblock=top.backannotate_slashstar(top.lines_w_beginblock,self.slashstars)
        return top.get_w_beginblock()
      else:
        for func in funcs:
          attrs.append(dfs(func,count+1))
        return attrs
    self.topdb_w_beginblock=copy.deepcopy(self.topdb)
    top,funcs=self.topdb_w_beginblock
    top.lines_w_beginblock=top.backannotate_func(top.lines_w_beginblock,[dfs(funcs,0)])
    top.lines_w_beginblock=top.backannotate_parenthesesstar(top.lines_w_beginblock,self.parenthesesstars,report=True)
    top.lines_w_beginblock=top.backannotate_slashdouble(top.lines_w_beginblock,self.slashdoubles,report=True)
    top.lines_w_beginblock=top.backannotate_slashstar(top.lines_w_beginblock,self.slashstars,report=True)
    return top


     
if __name__=='__main__':
  import sys
  argc=len(sys.argv)
  if argc > 1: infile =sys.argv[1]
  if argc > 2: outfile=sys.argv[2]
  obj=veriloglint(infile,outfile)
